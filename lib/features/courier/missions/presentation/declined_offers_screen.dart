import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/mission_repository.dart';
import '../missions_providers.dart';

/// Offres refusées des 7 derniers jours ; tant que la commande attend un livreur, le refus peut être annulé et l'offre
/// revient sur l'accueil, à accepter comme les autres.
class DeclinedOffersScreen extends ConsumerStatefulWidget {
  const DeclinedOffersScreen({super.key});

  static const path = '/courier/declined';

  @override
  ConsumerState<DeclinedOffersScreen> createState() =>
      _DeclinedOffersScreenState();
}

class _DeclinedOffersScreenState extends ConsumerState<DeclinedOffersScreen> {
  late Future<List<DeclinedOffer>> _offers = _load();
  String? _busy;
  Object? _error;

  Future<List<DeclinedOffer>> _load() =>
      ref.read(missionRepositoryProvider).declinedOffers();

  Future<void> _reconsider(DeclinedOffer offer) async {
    setState(() {
      _busy = offer.id;
      _error = null;
    });
    try {
      await ref.read(missionRepositoryProvider).reconsider(offer.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).declinedReopened)),
      );
      await Navigator.of(context).maybePop();
    } on AppFailure catch (failure) {
      if (mounted) {
        setState(() {
          _error = failure;
          _offers = _load();
        });
      }
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final date = DateFormat('d MMM, HH:mm', 'fr');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.declinedTitle)),
      body: FutureBuilder(
        future: _offers,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(failureMessage(l10n, snapshot.error)));
          }
          final offers = snapshot.data;
          if (offers == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (offers.isEmpty) {
            return EmptyState(
              icon: Icons.do_not_disturb_on_outlined,
              title: l10n.declinedEmpty,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _offers = _load());
              await _offers;
            },
            child: ListView(
              padding: const EdgeInsets.all(Space.screen),
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.md),
                    child: Text(
                      failureMessage(l10n, _error),
                      style: text.labelLarge!.copyWith(color: tokens.danger),
                    ),
                  ),
                for (final o in offers)
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
                                  '${o.summary.pickupName ?? o.summary.pickupDistrict} → ${o.summary.dropoffDistrict}',
                                  style: text.titleMedium,
                                ),
                              ),
                              Text(
                                formatMoney(o.summary.earning),
                                style: text.titleMedium!.copyWith(
                                  color: tokens.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: Space.xs),
                          Text(
                            '${o.summary.number} · ${formatDecimal(o.summary.tripM / 1000)} km · ${date.format(o.respondedAt.toLocal())}',
                            style: text.bodySmall!.copyWith(
                              color: tokens.muted,
                            ),
                          ),
                          const SizedBox(height: Space.md),
                          if (o.reopenable)
                            FilledButton.tonal(
                              onPressed: _busy == null
                                  ? () => _reconsider(o)
                                  : null,
                              child: _busy == o.id
                                  ? const SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(l10n.declinedReconsider),
                            )
                          else
                            Text(
                              l10n.declinedTaken,
                              style: text.bodySmall!.copyWith(
                                color: tokens.muted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
