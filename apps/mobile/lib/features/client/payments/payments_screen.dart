import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../orders/orders_providers.dart';
import '../../orders/presentation/order_detail_screen.dart';
import '../client_nav_bar.dart';

/// C-12 : paiements — moyens disponibles et paiements des commandes (Mobile Money et carte : Inc-11 / 12).
class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  static const path = ClientNavBar.paymentsPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final orders = ref.watch(myOrdersProvider).value ?? const <Order>[];

    Widget method(IconData icon, String label, {String? badge}) => ListTile(
      enabled: badge == null,
      leading: CircleAvatar(
        backgroundColor: badge == null ? tokens.primarySoft : tokens.surfaceAlt,
        child: Icon(icon, color: badge == null ? tokens.primary : tokens.muted),
      ),
      title: Text(label),
      trailing: badge == null
          ? Icon(Icons.check_circle, color: tokens.success)
          : Text(badge, style: TextStyle(color: tokens.muted)),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentsTitle)),
      bottomNavigationBar: const ClientNavBar(current: 2),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(myOrdersProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Space.screen,
            0,
            Space.screen,
            Space.huge,
          ),
          children: [
            SectionHeader(title: l10n.paymentsMethods),
            Card(
              child: Column(
                children: [
                  method(Icons.payments_outlined, l10n.paymentCash),
                  method(
                    Icons.phone_android_outlined,
                    l10n.paymentMobileMoney,
                    badge: l10n.paymentSoon,
                  ),
                  method(
                    Icons.credit_card_outlined,
                    l10n.paymentCard,
                    badge: l10n.paymentSoon,
                  ),
                ],
              ),
            ),
            SectionHeader(title: l10n.paymentsHistory),
            if (orders.isEmpty)
              EmptyState(
                icon: Icons.receipt_long_outlined,
                title: l10n.paymentsEmpty,
                body: l10n.paymentsEmptyBody,
              )
            else
              Card(
                child: Column(
                  children: [
                    for (final order in orders) _PaymentRow(order: order),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final cancelled =
        order.status == OrderStatus.rejected ||
        order.status == OrderStatus.cancelled;
    final (status, color) = order.status == OrderStatus.delivered
        ? (l10n.paymentDone, tokens.success)
        : cancelled
        ? (l10n.paymentNone, tokens.muted)
        : (l10n.paymentDue, tokens.warning);
    return ListTile(
      onTap: () => context.push(OrderDetailScreen.location(order.id)),
      leading: CircleAvatar(
        backgroundColor: tokens.surfaceAlt,
        child: Icon(Icons.payments_outlined, color: tokens.ink),
      ),
      title: Text(
        order.pickupName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${DateFormat('d MMM · HH:mm', 'fr').format(order.createdAt.toLocal())} · $status',
        style: text.bodySmall!.copyWith(color: color),
      ),
      trailing: Text(
        formatMoney(order.total),
        style: text.titleMedium!.copyWith(
          color: cancelled ? tokens.muted : tokens.ink,
          decoration: cancelled ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }
}
