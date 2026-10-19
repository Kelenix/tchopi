import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../orders/presentation/order_widgets.dart';
import '../../admin_scaffold.dart';
import '../../payments/presentation/transactions_admin_screen.dart';
import '../supervision_providers.dart';
import 'supervision_screen.dart';

/// A-01 : indicateurs d'une période (aujourd'hui, 7 ou 30 jours) et bandeau d'alertes cliquables (ADM-06, ADM-03).
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  static const path = '/admin/dashboard';

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _days = 1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final stats = ref.watch(adminStatsProvider(_days));
    final orders = ref.watch(activeOrdersProvider).value ?? const <Order>[];
    final settings = ref.watch(platformSettingsProvider).value;
    final now = DateTime.now();
    final alerted = orders
        .where((o) => orderAlerts(o, settings, now).isNotEmpty)
        .length;

    Widget kpi(
      String label,
      String value, {
      VoidCallback? onTap,
      bool warn = false,
    }) => Card(
      color: warn ? tokens.warningSoft : null,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Space.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

    return AdminScaffold(
      current: DashboardScreen.path,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adminStatsProvider(_days).future),
        child: ListView(
          padding: const EdgeInsets.all(Space.screen),
          children: [
            if (alerted > 0) ...[
              Material(
                color: tokens.warningSoft,
                borderRadius: BorderRadius.circular(Radii.card),
                child: ListTile(
                  leading: Icon(
                    Icons.warning_amber_rounded,
                    color: tokens.warning,
                  ),
                  title: Text(l10n.adminSupervision),
                  trailing: Text('$alerted', style: text.titleLarge),
                  onTap: () => context.go(SupervisionScreen.path),
                ),
              ),
              const SizedBox(height: Space.lg),
            ],
            Wrap(
              spacing: Space.sm,
              children: [
                for (final (days, label) in [
                  (1, l10n.periodDay),
                  (7, l10n.periodWeek),
                  (30, l10n.periodMonth),
                ])
                  ChoiceChip(
                    label: Text(label),
                    selected: _days == days,
                    onSelected: (_) => setState(() => _days = days),
                  ),
              ],
            ),
            const SizedBox(height: Space.md),
            switch (stats) {
              AsyncData(value: final s) => () {
                int n(String key) => (s[key] as num?)?.toInt() ?? 0;
                final byStatus = (s['by_status'] as Map?) ?? const {};
                final byType = (s['by_type'] as Map?) ?? const {};
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      // Hauteur fixe : un libellé sur deux lignes tient sans déborder.
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 104,
                            mainAxisSpacing: Space.sm,
                            crossAxisSpacing: Space.sm,
                          ),
                      children: [
                        kpi(l10n.statOrders, '${n('orders')}'),
                        kpi(l10n.statRevenue, formatMoney(n('revenue'))),
                        kpi(l10n.statFees, formatMoney(n('delivery_fees'))),
                        kpi(
                          l10n.statCommissions,
                          formatMoney(n('commissions')),
                        ),
                        kpi(
                          l10n.statCourierEarnings,
                          formatMoney(n('courier_earnings')),
                        ),
                        kpi(l10n.statPlatform, formatMoney(n('platform'))),
                        kpi(
                          l10n.statCash,
                          formatMoney(n('cash_to_reconcile')),
                          warn: n('cash_to_reconcile') > 0,
                          onTap: () => context.go(TransactionsAdminScreen.path),
                        ),
                        kpi(
                          l10n.statRefunds,
                          '${n('refunds_pending')}',
                          warn: n('refunds_pending') > 0,
                          onTap: () => context.go(TransactionsAdminScreen.path),
                        ),
                        kpi(l10n.statCouriersOnline, '${n('couriers_online')}'),
                      ],
                    ),
                    Text(
                      l10n.statDeliveredOnly,
                      style: text.bodySmall!.copyWith(color: tokens.muted),
                    ),
                    SectionHeader(title: l10n.statByType),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(Space.md),
                        child: Column(
                          children: [
                            for (final (type, label) in [
                              ('food', l10n.homeServiceFood),
                              ('parcel', l10n.homeServiceParcel),
                            ])
                              AmountRow(
                                label: label,
                                value: '${byType[type] ?? 0}',
                              ),
                          ],
                        ),
                      ),
                    ),
                    SectionHeader(title: l10n.statByStatus),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(Space.md),
                        child: Column(
                          children: [
                            for (final status in OrderStatus.values)
                              if (byStatus[status.wireName] case final count?)
                                AmountRow(
                                  label: status.label(l10n),
                                  value: '$count',
                                ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }(),
              AsyncError(:final error) => Text(failureMessage(l10n, error)),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ],
        ),
      ),
    );
  }
}
