import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/more_pages.dart';
import '../../orders/presentation/order_widgets.dart';
import '../client_nav_bar.dart';
import 'payments_providers.dart';
import 'presentation/receipt_sheet.dart';

enum _Filter { all, succeeded, refunds }

/// C-12 : paiements — moyens disponibles ; transactions groupées par jour, filtrables, avec reçu (PAY-01, TRX-01,
/// TRX-02, TRX-03).
class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  static const path = ClientNavBar.paymentsPath;

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  _Filter _filter = _Filter.all;
  // Paiements plus anciens que la première page, chargés à la demande.
  late final _more = MorePages<PaymentTransaction>(
    (offset, limit) =>
        ref.read(paymentRepositoryProvider).mine(offset: offset, limit: limit),
  );

  @override
  void dispose() {
    _more.dispose();
    super.dispose();
  }

  bool _keep(PaymentTransaction t) => switch (_filter) {
    _Filter.all => true,
    _Filter.succeeded => t.status == TransactionStatus.succeeded,
    _Filter.refunds =>
      t.status == TransactionStatus.refunded ||
          t.orderPaymentStatus == OrderPaymentStatus.refundPending,
  };

  String _day(AppLocalizations l10n, DateTime date) {
    final day = DateUtils.dateOnly(date.toLocal());
    final today = DateUtils.dateOnly(DateTime.now());
    if (day == today) return l10n.dayToday;
    if (day == today.subtract(const Duration(days: 1))) {
      return l10n.dayYesterday;
    }
    return DateFormat('d MMM y', 'fr').format(day);
  }

  @override
  void initState() {
    super.initState();
    _more.addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final options = ref.watch(paymentOptionsProvider).value ?? const [];
    final first =
        ref.watch(myTransactionsProvider).value ?? const <PaymentTransaction>[];
    final transactions = [
      for (final t in [...first, ..._more.items])
        if (_keep(t)) t,
    ];
    final days = <String, List<PaymentTransaction>>{};
    for (final t in transactions) {
      (days[_day(l10n, t.createdAt)] ??= []).add(t);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentsTitle)),
      bottomNavigationBar: const ClientNavBar(current: 2),
      body: RefreshIndicator(
        onRefresh: () {
          _more.reset();
          return ref.refresh(myTransactionsProvider.future);
        },
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
            Wrap(
              spacing: Space.sm,
              children: [
                for (final (filter, label) in [
                  (_Filter.all, l10n.filterAll),
                  (_Filter.succeeded, l10n.filterSucceeded),
                  (_Filter.refunds, l10n.filterRefunds),
                ])
                  ChoiceChip(
                    label: Text(label),
                    selected: _filter == filter,
                    onSelected: (_) => setState(() => _filter = filter),
                  ),
              ],
            ),
            const SizedBox(height: Space.sm),
            if (transactions.isEmpty)
              EmptyState(
                icon: Icons.receipt_long_outlined,
                title: l10n.paymentsEmpty,
                body: l10n.paymentsEmptyBody,
              )
            else
              for (final MapEntry(key: day, value: list) in days.entries) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, Space.md, 0, Space.xs),
                  child: Text(
                    day,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge!.copyWith(color: tokens.muted),
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      for (final t in list) _TransactionRow(transaction: t),
                    ],
                  ),
                ),
              ],
            MorePagesFooter(pages: _more, firstPage: first.length),
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
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => ReceiptSheet(transaction: t),
      ),
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
        '${DateFormat.Hm('fr').format(t.createdAt.toLocal())} · $status',
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
