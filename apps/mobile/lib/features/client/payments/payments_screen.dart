import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../orders/presentation/order_detail_screen.dart';
import '../../orders/presentation/order_widgets.dart';
import '../client_nav_bar.dart';
import 'payments_providers.dart';

/// C-12 : paiements — moyens disponibles et transactions des commandes avec leur statut (PAY-01, TRX-01).
/// Historique groupé par date et reçus : Inc-13.
class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  static const path = ClientNavBar.paymentsPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final options = ref.watch(paymentOptionsProvider).value ?? const [];
    final transactions = ref.watch(myTransactionsProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentsTitle)),
      bottomNavigationBar: const ClientNavBar(current: 2),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(myTransactionsProvider.future),
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
                  if (options.isEmpty)
                    ListTile(title: Text(l10n.paymentNoneAvailable)),
                  for (final option in options)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: tokens.primarySoft,
                        child: Icon(
                          paymentIcon(option.method),
                          color: tokens.primary,
                        ),
                      ),
                      title: Text(paymentOptionLabel(l10n, option)),
                      trailing: Icon(Icons.check_circle, color: tokens.success),
                    ),
                ],
              ),
            ),
            SectionHeader(title: l10n.paymentsHistory),
            if (transactions.isEmpty)
              EmptyState(
                icon: Icons.receipt_long_outlined,
                title: l10n.paymentsEmpty,
                body: l10n.paymentsEmptyBody,
              )
            else
              Card(
                child: Column(
                  children: [
                    for (final t in transactions)
                      _TransactionRow(transaction: t),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});

  final PaymentTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final t = transaction;
    final (status, color) = transactionStatus(context, t);
    final void_ = t.status == TransactionStatus.cancelled;
    return ListTile(
      onTap: () => context.push(OrderDetailScreen.location(t.orderId)),
      leading: CircleAvatar(
        backgroundColor: tokens.surfaceAlt,
        child: Icon(paymentIcon(t.method), color: tokens.ink),
      ),
      title: Text(
        l10n.orderNumber(t.orderNumber ?? ''),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${DateFormat('d MMM · HH:mm', 'fr').format(t.createdAt.toLocal())} · $status',
        style: text.bodySmall!.copyWith(color: color),
      ),
      trailing: Text(
        formatMoney(t.amount, currency: t.currency),
        style: text.titleMedium!.copyWith(
          color: void_ ? tokens.muted : tokens.ink,
          decoration: void_ ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }
}
