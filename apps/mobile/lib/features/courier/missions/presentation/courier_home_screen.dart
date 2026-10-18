import 'package:core/core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../profile/presentation/courier_profile_screen.dart';
import '../missions_providers.dart';
import 'offer_screen.dart';

/// L-03 : tableau de bord du livreur approuvé — interrupteur En ligne / Hors ligne, mission en cours ;
/// chaque nouvelle offre s'ouvre en plein écran (COU-05, DIS-02). Gains et espèces : Inc-8.
class CourierHomeScreen extends ConsumerStatefulWidget {
  const CourierHomeScreen({super.key});

  static const path = '/courier';

  @override
  ConsumerState<CourierHomeScreen> createState() => _CourierHomeScreenState();
}

class _CourierHomeScreenState extends ConsumerState<CourierHomeScreen> {
  bool _busy = false;
  String? _shownOffer;

  Future<void> _toggle(bool online) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    // Explication avant la demande d'autorisation du système (COU-05).
    final presence = ref.read(courierPresenceProvider.notifier);
    if (online && await presence.needsPermission()) {
      if (!mounted || !await _explainLocation()) return;
    }
    setState(() => _busy = true);
    try {
      await presence.setOnline(online);
    } on PresenceException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.problem == PresenceProblem.serviceOff
                ? l10n.courierGpsOff
                : l10n.courierLocationDenied,
          ),
          // Avec une action, le message resterait affiché jusqu'à être balayé, par-dessus les offres.
          persist: false,
          action: e.problem == PresenceProblem.deniedForever && !kIsWeb
              ? SnackBarAction(
                  label: l10n.courierOpenSettings,
                  onPressed: presence.openSettings,
                )
              : null,
        ),
      );
    } on AppFailure catch (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _explainLocation() async {
    final l10n = AppLocalizations.of(context);
    return await showConfirmSheet(
      context,
      icon: Icons.my_location_rounded,
      title: l10n.courierLocationTitle,
      body: l10n.courierLocationBody,
      confirmLabel: l10n.actionContinue,
    );
  }

  void _showOffer(DeliveryOffer offer) {
    if (offer.id == _shownOffer || !offer.expiresAt.isAfter(DateTime.now())) {
      return;
    }
    _shownOffer = offer.id;
    ScaffoldMessenger.of(context).clearSnackBars();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => OfferScreen(offer: offer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(pendingOfferProvider, (_, next) {
      if (next.value case final offer?) _showOffer(offer);
    });
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final firstName = ref.watch(currentProfileProvider).value?.firstName;
    final online = ref.watch(courierPresenceProvider).value ?? false;
    final mission = ref.watch(currentMissionProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          firstName == null
              ? l10n.homeGreetingAnonymous
              : l10n.homeGreeting(firstName),
        ),
        actions: [
          IconButton(
            tooltip: l10n.courierEditProfile,
            icon: const Icon(Icons.badge_outlined),
            onPressed: () => context.push(CourierProfileScreen.path),
          ),
          IconButton(
            tooltip: l10n.accountTitle,
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(AppRoutes.account),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.screen),
        children: [
          Material(
            color: online ? tokens.primary : tokens.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.card),
              side: BorderSide(color: online ? tokens.primary : tokens.border),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(Radii.card),
              onTap: _busy ? null : () => _toggle(!online),
              child: Padding(
                padding: const EdgeInsets.all(Space.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            online ? l10n.courierOnline : l10n.courierOffline,
                            style: text.headlineMedium!.copyWith(
                              color: online ? tokens.onPrimary : tokens.ink,
                            ),
                          ),
                        ),
                        if (_busy)
                          SizedBox.square(
                            dimension: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: online ? tokens.onPrimary : tokens.primary,
                            ),
                          )
                        else
                          Switch(
                            value: online,
                            onChanged: _toggle,
                            activeThumbColor: tokens.primary,
                            activeTrackColor: tokens.onPrimary,
                          ),
                      ],
                    ),
                    const SizedBox(height: Space.sm),
                    Text(
                      online ? l10n.courierOnlineBody : l10n.courierOfflineBody,
                      style: text.bodyMedium!.copyWith(
                        color: online ? tokens.onPrimary : tokens.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: Space.xxl),
          if (mission != null)
            _MissionCard(order: mission)
          else if (online)
            EmptyState(
              icon: Icons.notifications_active_outlined,
              title: l10n.courierWaitingTitle,
              body: l10n.courierWaitingBody,
            ),
        ],
      ),
    );
  }
}

/// Mission en cours : retrait, destination, gain et espèces à encaisser (le déroulé arrive à l'Inc-8).
class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final small = text.bodySmall!.copyWith(color: tokens.muted);
    Widget stop(Color color, String label, String district, String landmark) =>
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.circle, size: 12, color: color),
          minLeadingWidth: 12,
          title: Text(label, style: small),
          subtitle: Text('$district, $landmark', style: text.titleMedium),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.courierMissionTitle),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Space.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.orderNumber(order.number),
                        style: text.titleMedium,
                      ),
                    ),
                    Text(
                      l10n.courierMissionEarning(
                        formatMoney(order.courierEarning),
                      ),
                      style: text.titleMedium!.copyWith(color: tokens.success),
                    ),
                  ],
                ),
                stop(
                  tokens.ink,
                  l10n.offerPickup(order.pickupName),
                  order.pickupDistrict,
                  order.pickupLandmark,
                ),
                stop(
                  tokens.primary,
                  l10n.offerDropoff(order.recipientName),
                  order.dropoffDistrict,
                  order.dropoffLandmark,
                ),
                if (order.paymentMethod == PaymentMethod.cash)
                  Text(
                    l10n.offerCash(formatMoney(order.total)),
                    style: text.labelLarge!.copyWith(color: tokens.warning),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
