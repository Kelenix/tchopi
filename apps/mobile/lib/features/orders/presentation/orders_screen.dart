import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../client/client_nav_bar.dart';
import '../orders_providers.dart';
import 'order_detail_screen.dart';
import 'order_widgets.dart';

/// C-10 : mes commandes — en cours en haut, puis l'historique (ORD-12).
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  static const path = ClientNavBar.ordersPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final orders = ref.watch(myOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ordersTitle)),
      bottomNavigationBar: const ClientNavBar(current: 1),
      body: switch (orders) {
        AsyncData(:final value) when value.isEmpty => EmptyState(
          icon: Icons.receipt_long_outlined,
          title: l10n.ordersEmpty,
          body: l10n.ordersEmptyBody,
        ),
        AsyncData(:final value) => RefreshIndicator(
          onRefresh: () => ref.refresh(myOrdersProvider.future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              Space.screen,
              Space.sm,
              Space.screen,
              Space.huge,
            ),
            children: [
              for (final (title, group) in [
                (l10n.ordersActive, value.where((o) => !o.status.isClosed)),
                (l10n.ordersPast, value.where((o) => o.status.isClosed)),
              ])
                if (group.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      top: Space.lg,
                      bottom: Space.sm,
                    ),
                    child: Text(title, style: text.titleMedium),
                  ),
                  for (final order in group) ...[
                    OrderTile(order: order),
                    const SizedBox(height: Space.md),
                  ],
                ],
            ],
          ),
        ),
        AsyncError(:final error) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(failureMessage(l10n, error)),
              const SizedBox(height: Space.md),
              OutlinedButton(
                onPressed: () => ref.invalidate(myOrdersProvider),
                child: Text(l10n.actionRetry),
              ),
            ],
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// Commande résumée : restaurant, date, total, statut ; ouvre le détail.
class OrderTile extends StatelessWidget {
  const OrderTile({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final date = DateFormat('d MMM · HH:mm', 'fr');
    return Card(
      child: InkWell(
        onTap: () => context.push(OrderDetailScreen.location(order.id)),
        child: Padding(
          padding: const EdgeInsets.all(Space.lg),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: tokens.surfaceAlt,
                child: Icon(Icons.restaurant_rounded, color: tokens.ink),
              ),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.pickupName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${date.format(order.createdAt.toLocal())} · ${formatMoney(order.total)}',
                      style: text.bodySmall!.copyWith(color: tokens.muted),
                    ),
                    const SizedBox(height: Space.sm),
                    OrderStatusChip(status: order.status),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: tokens.muted),
            ],
          ),
        ),
      ),
    );
  }
}
