import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/alert_sound.dart';
import '../missions_providers.dart';

/// L-04 : commande à récupérer, en plein écran — gain, trajet, espèces à encaisser (DIS-02). Proposée à tous les
/// livreurs disponibles : le premier qui accepte l'obtient. Son et vibration à l'arrivée ; app fermée : notification.
class OfferScreen extends ConsumerStatefulWidget {
  const OfferScreen({super.key, required this.offer});

  final DeliveryOffer offer;

  @override
  ConsumerState<OfferScreen> createState() => _OfferScreenState();
}

enum _Outcome { deciding, sending, accepted, declined, unavailable }

class _OfferScreenState extends ConsumerState<OfferScreen> {
  _Outcome _outcome = _Outcome.deciding;

  @override
  void initState() {
    super.initState();
    playAlertSound();
    HapticFeedback.heavyImpact();
  }

  Future<void> _respond(bool accept) async {
    // Double appui avant le rafraîchissement de l'écran : une seule réponse part.
    if (_outcome != _Outcome.deciding) return;
    setState(() => _outcome = _Outcome.sending);
    try {
      await ref
          .read(missionRepositoryProvider)
          .respond(widget.offer.id, accept: accept);
      if (mounted) {
        setState(
          () => _outcome = accept ? _Outcome.accepted : _Outcome.declined,
        );
      }
    } on AppFailure catch (failure) {
      if (!mounted) return;
      if (failure.code == 'offer_unavailable') {
        setState(() => _outcome = _Outcome.unavailable);
      } else {
        setState(() => _outcome = _Outcome.deciding);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failureMessage(AppLocalizations.of(context), failure),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Offre retirée par le serveur (commande annulée, attribuée par l'admin) pendant la décision.
    ref.listen(pendingOffersProvider, (_, next) {
      if (_outcome == _Outcome.deciding &&
          next.hasValue &&
          !next.value!.any((offer) => offer.id == widget.offer.id)) {
        setState(() => _outcome = _Outcome.unavailable);
      }
    });
    final deciding =
        _outcome == _Outcome.deciding || _outcome == _Outcome.sending;
    return PopScope(
      canPop: !deciding,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Space.screen),
            child: deciding ? _offer(context) : _result(context),
          ),
        ),
      ),
    );
  }

  Widget _offer(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final s = widget.offer.summary;
    final parcel = s.type == 'parcel';
    final sending = _outcome == _Outcome.sending;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Chip(
              avatar: Icon(
                parcel
                    ? Icons.inventory_2_outlined
                    : Icons.shopping_bag_outlined,
                size: 16,
                color: tokens.primary,
              ),
              label: Text(parcel ? l10n.offerParcel : l10n.offerFood),
            ),
            const Spacer(),
            Text(
              l10n.offerTotalDistance(
                formatDecimal((s.toPickupM + s.tripM) / 1000),
              ),
              style: text.bodySmall!.copyWith(color: tokens.muted),
            ),
          ],
        ),
        const Spacer(),
        Text(
          l10n.offerEarning,
          textAlign: TextAlign.center,
          style: text.bodyMedium!.copyWith(color: tokens.muted),
        ),
        Text(
          '+${formatMoney(s.earning, currency: s.currency)}',
          textAlign: TextAlign.center,
          style: text.displaySmall!.copyWith(color: tokens.success),
        ),
        const Spacer(),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Space.lg),
            child: Column(
              children: [
                _Stop(
                  color: tokens.ink,
                  label: l10n.offerPickup(
                    s.pickupName ?? l10n.orderPickupTitle,
                  ),
                  place: '${s.pickupDistrict}, ${s.pickupLandmark}',
                  distance: s.toPickupM,
                ),
                const SizedBox(height: Space.md),
                _Stop(
                  color: tokens.primary,
                  label: l10n.offerDropoff(s.recipientName),
                  place: '${s.dropoffDistrict}, ${s.dropoffLandmark}',
                  distance: s.tripM,
                ),
              ],
            ),
          ),
        ),
        if (s.cashAmount > 0) ...[
          const SizedBox(height: Space.md),
          DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.warningSoft,
              borderRadius: BorderRadius.circular(Radii.field),
            ),
            child: Padding(
              padding: const EdgeInsets.all(Space.md),
              child: Row(
                children: [
                  Icon(Icons.payments_outlined, color: tokens.warning),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Text(
                      l10n.offerCash(
                        formatMoney(s.cashAmount, currency: s.currency),
                      ),
                      style: text.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: Space.xl),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: sending ? null : () => _respond(false),
                child: Text(l10n.offerDecline),
              ),
            ),
            const SizedBox(width: Space.md),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: sending ? null : () => _respond(true),
                child: sending
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Text(l10n.offerAccept),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _result(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = widget.offer.summary;
    final (icon, title, body) = switch (_outcome) {
      _Outcome.accepted => (
        Icons.check_circle_outline,
        l10n.offerAcceptedTitle,
        l10n.offerAcceptedBody(
          s.pickupName ?? s.pickupDistrict,
          formatDecimal(s.toPickupM / 1000),
        ),
      ),
      _Outcome.declined => (
        Icons.do_not_disturb_on_outlined,
        l10n.offerDeclinedTitle,
        l10n.offerDeclinedBody,
      ),
      _ => (Icons.info_outline, l10n.failureOfferUnavailable, null),
    };
    return Column(
      children: [
        Expanded(
          child: EmptyState(icon: icon, title: title, body: body),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(_outcome == _Outcome.accepted),
          child: Text(l10n.actionContinue),
        ),
      ],
    );
  }
}

class _Stop extends StatelessWidget {
  const _Stop({
    required this.color,
    required this.label,
    required this.place,
    required this.distance,
  });

  final Color color;
  final String label;
  final String place;
  final int distance;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final small = text.bodySmall!.copyWith(color: tokens.muted);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(Icons.circle, size: 12, color: color),
        ),
        const SizedBox(width: Space.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: small),
              Text(place, style: text.titleMedium),
            ],
          ),
        ),
        Text(
          l10n.parcelDistanceValue(formatDecimal(distance / 1000)),
          style: small,
        ),
      ],
    );
  }
}
