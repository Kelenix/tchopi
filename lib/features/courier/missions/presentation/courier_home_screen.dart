import 'package:core/core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../courier_nav_bar.dart';
import '../missions_providers.dart';
import 'mission_screen.dart';
import 'offer_screen.dart';

/// L-03 : tableau de bord du livreur approuvé — interrupteur En ligne / Hors ligne, gains et livraisons du
/// jour, espèces à reverser, mission en cours, commandes prêtes à récupérer ; chaque nouvelle commande proposée
/// s'ouvre aussi en plein écran (COU-05, DIS-02, MIS-01).
class CourierHomeScreen extends ConsumerStatefulWidget {
  const CourierHomeScreen({super.key});

  static const path = '/courier';

  @override
  ConsumerState<CourierHomeScreen> createState() => _CourierHomeScreenState();
}

class _CourierHomeScreenState extends ConsumerState<CourierHomeScreen> {
  bool _busy = false;
  final _shownOffers = <String>{};

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

  /// [auto] : ouverture à l'arrivée d'une commande, une seule fois par commande.
  Future<void> _showOffer(DeliveryOffer offer, {bool auto = false}) async {
    if (auto && !_shownOffers.add(offer.id)) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    final accepted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => OfferScreen(offer: offer),
      ),
    );
    if ((accepted ?? false) && mounted) {
      await context.push(MissionScreen.location(offer.orderId));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(pendingOffersProvider, (_, next) {
      final fresh = (next.value ?? const <DeliveryOffer>[]).where(
        (offer) => !_shownOffers.contains(offer.id),
      );
      if (fresh.isNotEmpty && ref.read(currentMissionProvider).value == null) {
        _showOffer(fresh.first, auto: true);
      }
    });
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final firstName = ref.watch(currentProfileProvider).value?.firstName;
    final online = ref.watch(courierPresenceProvider).value ?? false;
    final mission = ref.watch(currentMissionProvider).value;
    final summary = ref.watch(courierSummaryProvider).value;
    final offers = ref.watch(pendingOffersProvider).value ?? const [];

    return Scaffold(
      bottomNavigationBar: const CourierNavBar(current: 0),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          firstName == null
              ? l10n.homeGreetingAnonymous
              : l10n.homeGreeting(firstName),
        ),
        actions: [
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
          // Carte d'état : dégradé de la marque en ligne, carte neutre hors ligne ; un appui bascule l'état.
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.card),
              border: Border.all(
                color: online ? Colors.transparent : tokens.border,
              ),
              gradient: online
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        tokens.primary,
                        Color.alphaBlend(
                          Colors.black.withValues(alpha: 0.25),
                          tokens.primary,
                        ),
                      ],
                    )
                  : null,
              color: online ? null : tokens.surface,
              boxShadow: online
                  ? [
                      BoxShadow(
                        color: tokens.primary.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              type: MaterialType.transparency,
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
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(right: Space.md),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: online ? tokens.onPrimary : tokens.muted,
                            ),
                          ),
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
                                color: online
                                    ? tokens.onPrimary
                                    : tokens.primary,
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
                        online
                            ? l10n.courierOnlineBody
                            : l10n.courierOfflineBody,
                        style: text.bodyMedium!.copyWith(
                          color: online ? tokens.onPrimary : tokens.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Space.xl),
          if (summary != null) ...[
            SectionHeader(title: l10n.courierTodayTitle),
            Row(
              children: [
                _Kpi(
                  icon: Icons.payments_outlined,
                  value: formatMoney(summary.earningsToday),
                  label: l10n.kpiEarnings,
                ),
                const SizedBox(width: Space.sm),
                _Kpi(
                  icon: Icons.check_circle_outline,
                  value: '${summary.deliveriesToday}',
                  label: l10n.kpiDeliveries,
                ),
                const SizedBox(width: Space.sm),
                _Kpi(
                  icon: Icons.account_balance_wallet_outlined,
                  value: formatMoney(summary.cashDue),
                  label: l10n.kpiCash,
                  warn: summary.cashDue > 0,
                ),
              ],
            ),
          ],
          const SizedBox(height: Space.xl),
          if (mission != null)
            _MissionCard(order: mission)
          else if (offers.isNotEmpty) ...[
            SectionHeader(title: l10n.courierAvailableTitle),
            for (final offer in offers)
              _OfferTile(offer: offer, onTap: () => _showOffer(offer)),
          ] else
            EmptyState(
              icon: online
                  ? Icons.notifications_active_outlined
                  : Icons.power_settings_new_rounded,
              title: online ? l10n.courierWaitingTitle : l10n.courierReadyTitle,
              body: online ? l10n.courierWaitingBody : l10n.courierReadyBody,
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
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push(MissionScreen.location(order.id)),
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
                        style: text.titleMedium!.copyWith(
                          color: tokens.success,
                        ),
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
                  if (order.paymentMethod == PaymentMethod.cash &&
                      order.paymentStatus == OrderPaymentStatus.unpaid)
                    Text(
                      l10n.offerCash(formatMoney(order.total)),
                      style: text.labelLarge!.copyWith(color: tokens.warning),
                    ),
                  const SizedBox(height: Space.md),
                  FilledButton(
                    onPressed: () =>
                        context.push(MissionScreen.location(order.id)),
                    child: Text(l10n.missionOpen),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Indicateur du jour (MIS-01) ; en orange s'il appelle une action (espèces à reverser).
class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.icon,
    required this.value,
    required this.label,
    this.warn = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        color: warn ? tokens.warningSoft : null,
        child: Padding(
          padding: const EdgeInsets.all(Space.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 20,
                color: warn ? tokens.warning : tokens.primary,
              ),
              const SizedBox(height: Space.sm),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value, style: text.titleLarge),
              ),
              Text(
                label,
                maxLines: 2,
                style: text.bodySmall!.copyWith(color: tokens.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Commande prête à récupérer, proposée au livreur : retrait, distance, gain ; ouvre le détail pour accepter.
class _OfferTile extends StatelessWidget {
  const _OfferTile({required this.offer, required this.onTap});

  final DeliveryOffer offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final s = offer.summary;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Space.lg,
          vertical: Space.sm,
        ),
        leading: Icon(
          s.type == 'parcel'
              ? Icons.inventory_2_outlined
              : Icons.shopping_bag_outlined,
          color: tokens.primary,
        ),
        title: Text(
          '${s.number} · ${s.pickupName ?? s.pickupDistrict}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          l10n.courierOfferLine(
            formatDecimal(s.toPickupM / 1000),
            s.dropoffDistrict,
          ),
        ),
        trailing: Text(
          '+${formatMoney(s.earning, currency: s.currency)}',
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(color: tokens.success),
        ),
        onTap: onTap,
      ),
    );
  }
}
