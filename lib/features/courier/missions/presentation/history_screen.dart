import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../orders/presentation/order_widgets.dart';
import '../missions_providers.dart';

/// L-09 : missions (date, type, trajet, gain, statut) et gains du jour et des 7 derniers jours (MIS-10).
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  static const path = '/courier/history';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final history = ref.watch(missionHistoryProvider);
    final today = DateUtils.dateOnly(DateTime.now());
    int earned(DateTime since) => (history.value ?? const <MissionRecord>[])
        .where(
          (m) =>
              m.status == OrderStatus.delivered &&
              m.closedAt != null &&
              !m.closedAt!.toLocal().isBefore(since),
        )
        .fold(0, (sum, m) => sum + m.courierEarning);
    final date = DateFormat('d MMM, HH:mm', 'fr');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: switch (history) {
        AsyncData(value: final missions) when missions.isEmpty => EmptyState(
          icon: Icons.history,
          title: l10n.historyEmpty,
        ),
        AsyncData(value: final missions) => ListView(
          padding: const EdgeInsets.all(Space.screen),
          children: [
            Row(
              children: [
                for (final (label, since) in [
                  (l10n.historyToday, today),
                  (l10n.historyWeek, today.subtract(const Duration(days: 6))),
                ])
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(Space.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatMoney(earned(since)),
                              style: text.titleLarge!.copyWith(
                                color: tokens.success,
                              ),
                            ),
                            Text(
                              label,
                              style: text.bodySmall!.copyWith(
                                color: tokens.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Space.lg),
            for (final m in missions)
              Card(
                child: ListTile(
                  leading: Icon(
                    m.type == OrderType.parcel
                        ? Icons.inventory_2_outlined
                        : Icons.shopping_bag_outlined,
                    color: tokens.primary,
                  ),
                  title: Text('${m.pickupDistrict} → ${m.dropoffDistrict}'),
                  subtitle: Text(
                    '${m.number} · '
                    '${date.format((m.closedAt ?? m.assignedAt ?? DateTime.now()).toLocal())}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        m.status == OrderStatus.delivered
                            ? '+${formatMoney(m.courierEarning)}'
                            : '',
                        style: text.titleMedium!.copyWith(
                          color: tokens.success,
                        ),
                      ),
                      Text(
                        m.status.label(l10n),
                        style: text.bodySmall!.copyWith(color: tokens.muted),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        AsyncError(:final error) => Center(
          child: Text(failureMessage(l10n, error)),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
