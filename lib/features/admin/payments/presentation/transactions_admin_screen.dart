import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/more_pages.dart';
import '../../../orders/presentation/order_widgets.dart';
import '../../admin_scaffold.dart';
import '../../zones/zones_providers.dart';
import '../../supervision/presentation/admin_order_screen.dart';
import '../admin_payments_providers.dart';

/// A-07 : transactions (statut, moyen, montant ; « livrée · non encaissée ») et espèces des livreurs (solde dû,
/// historique, versement) — PAY-02, TRX-01, ADM-04. Filtres, remboursements et export : Inc-13.
class TransactionsAdminScreen extends ConsumerWidget {
  const TransactionsAdminScreen({super.key});

  static const path = '/admin/transactions';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: AdminScaffold(
        current: path,
        bottom: TabBar(
          tabs: [
            Tab(text: l10n.adminTabTransactions),
            Tab(text: l10n.adminTabCash),
          ],
        ),
        body: const TabBarView(children: [_Transactions(), _Cash()]),
      ),
    );
  }
}

enum _Status { all, pending, succeeded, refundPending, refunded, cancelled }

class _Transactions extends ConsumerStatefulWidget {
  const _Transactions();

  @override
  ConsumerState<_Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends ConsumerState<_Transactions> {
  _Status _status = _Status.all;
  PaymentMethod? _method;
  int? _days;
  String? _zoneId;
  // Transactions plus anciennes que la première page, chargées à la demande.
  late final _more = MorePages<PaymentTransaction>(
    (offset, limit) => ref
        .read(adminPaymentsRepositoryProvider)
        .transactions(offset: offset, limit: limit),
  );

  @override
  void initState() {
    super.initState();
    _more.addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    _more.dispose();
    super.dispose();
  }

  bool _keep(PaymentTransaction t, DateTime now) {
    final status = switch (_status) {
      _Status.all => true,
      _Status.pending => t.status == TransactionStatus.pending,
      _Status.succeeded =>
        t.status == TransactionStatus.succeeded &&
            t.orderPaymentStatus != OrderPaymentStatus.refundPending,
      _Status.refundPending =>
        t.orderPaymentStatus == OrderPaymentStatus.refundPending,
      _Status.refunded => t.status == TransactionStatus.refunded,
      _Status.cancelled => t.status == TransactionStatus.cancelled,
    };
    final since = _days == null
        ? null
        : DateUtils.dateOnly(now).subtract(Duration(days: _days! - 1));
    return status &&
        (since == null || !t.createdAt.toLocal().isBefore(since)) &&
        (_method == null || t.method == _method) &&
        (_zoneId == null || t.orderZoneId == _zoneId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final date = DateFormat('d MMM · HH:mm', 'fr');
    final zones = ref.watch(adminZonesProvider).value ?? const <Zone>[];
    final now = DateTime.now();
    final filters = Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.screen,
        Space.md,
        Space.screen,
        0,
      ),
      child: Wrap(
        spacing: Space.sm,
        runSpacing: Space.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final (status, label) in [
            (_Status.all, l10n.filterAll),
            (_Status.pending, l10n.txPending),
            (_Status.succeeded, l10n.filterSucceeded),
            (_Status.refundPending, l10n.txRefundPending),
            (_Status.refunded, l10n.txRefunded),
            (_Status.cancelled, l10n.txCancelled),
          ])
            ChoiceChip(
              label: Text(label),
              selected: _status == status,
              onSelected: (_) => setState(() => _status = status),
            ),
          DropdownButton<PaymentMethod?>(
            value: _method,
            style: text.labelLarge,
            underline: const SizedBox.shrink(),
            items: [
              DropdownMenuItem(child: Text(l10n.filterAnyMethod)),
              for (final m in PaymentMethod.values)
                DropdownMenuItem(
                  value: m,
                  child: Text(paymentMethodLabel(l10n, m)),
                ),
            ],
            onChanged: (value) => setState(() => _method = value),
          ),
          DropdownButton<int?>(
            value: _days,
            style: text.labelLarge,
            underline: const SizedBox.shrink(),
            items: [
              DropdownMenuItem(child: Text(l10n.filterAnyPeriod)),
              DropdownMenuItem(value: 1, child: Text(l10n.periodDay)),
              DropdownMenuItem(value: 7, child: Text(l10n.periodWeek)),
              DropdownMenuItem(value: 30, child: Text(l10n.periodMonth)),
            ],
            onChanged: (value) => setState(() => _days = value),
          ),
          if (zones.length > 1)
            DropdownButton<String?>(
              value: _zoneId,
              style: text.labelLarge,
              underline: const SizedBox.shrink(),
              items: [
                DropdownMenuItem(child: Text(l10n.supervisionAllZones)),
                for (final z in zones)
                  DropdownMenuItem(value: z.id, child: Text(z.name)),
              ],
              onChanged: (value) => setState(() => _zoneId = value),
            ),
        ],
      ),
    );
    return switch (ref.watch(adminTransactionsProvider)) {
      AsyncData(value: final first) => () {
        final list = [
          for (final t in [...first, ..._more.items])
            if (_keep(t, now)) t,
        ];
        return Column(
          children: [
            filters,
            Expanded(
              child: list.isEmpty
                  ? EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: l10n.txEmpty,
                    )
                  : RefreshIndicator(
                      onRefresh: () {
                        _more.reset();
                        return ref.refresh(adminTransactionsProvider.future);
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(Space.screen),
                        itemCount: list.length + 1,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: Space.sm),
                        itemBuilder: (context, index) {
                          if (index == list.length) {
                            return MorePagesFooter(
                              pages: _more,
                              firstPage: first.length,
                            );
                          }
                          final t = list[index];
                          final (status, color) = transactionStatus(context, t);
                          return Card(
                            child: ListTile(
                              onTap: () => context.push(
                                AdminOrderScreen.location(t.orderId),
                              ),
                              leading: Icon(paymentIcon(t.method)),
                              title: Text(t.orderNumber ?? ''),
                              subtitle: Text(
                                date.format(t.createdAt.toLocal()),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatMoney(t.amount, currency: t.currency),
                                    style: text.titleMedium,
                                  ),
                                  Text(
                                    status,
                                    style: text.bodySmall!.copyWith(
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      }(),
      AsyncError(:final error) => Center(
        child: Text(failureMessage(l10n, error)),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _Cash extends ConsumerWidget {
  const _Cash();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    return switch (ref.watch(cashBalancesProvider)) {
      AsyncData(value: final list) when list.isEmpty => EmptyState(
        icon: Icons.payments_outlined,
        title: l10n.cashEmpty,
      ),
      AsyncData(value: final list) => RefreshIndicator(
        onRefresh: () => ref.refresh(cashBalancesProvider.future),
        child: ListView.separated(
          padding: const EdgeInsets.all(Space.screen),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: Space.sm),
          itemBuilder: (context, index) {
            final b = list[index];
            return Card(
              child: ListTile(
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => _CourierCash(balance: b),
                ),
                leading: const Icon(Icons.two_wheeler),
                title: Text([b.firstName, b.lastName].nonNulls.join(' ')),
                subtitle: Text(
                  '${l10n.cashCollectedLabel(formatMoney(b.collected))} · '
                  '${l10n.cashRemittedLabel(formatMoney(b.remitted))}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatMoney(b.due),
                      style: text.titleMedium!.copyWith(
                        color: b.due > 0 ? tokens.warning : tokens.success,
                      ),
                    ),
                    Text(l10n.cashDueLabel, style: text.bodySmall),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      AsyncError(:final error) => Center(
        child: Text(failureMessage(l10n, error)),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

/// Historique des encaissements et versements d'un livreur ; versement remis à la plateforme.
class _CourierCash extends ConsumerStatefulWidget {
  const _CourierCash({required this.balance});

  final CashBalance balance;

  @override
  ConsumerState<_CourierCash> createState() => _CourierCashState();
}

class _CourierCashState extends ConsumerState<_CourierCash> {
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    super.dispose();
  }

  Future<void> _record() async {
    final amount = int.tryParse(_amount.text);
    if (amount == null || amount <= 0) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(adminPaymentsRepositoryProvider)
          .recordRemittance(
            widget.balance.courierId,
            amount,
            _reference.text.trim().isEmpty ? null : _reference.text.trim(),
          );
      ref
        ..invalidate(cashBalancesProvider)
        ..invalidate(cashLedgerProvider(widget.balance.courierId));
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.cashRecorded)));
    } on AppFailure catch (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final b = widget.balance;
    final entries =
        ref.watch(cashLedgerProvider(b.courierId)).value ?? const <CashEntry>[];
    final date = DateFormat('d MMM · HH:mm', 'fr');
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Space.screen,
          0,
          Space.screen,
          Space.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                [b.firstName, b.lastName].nonNulls.join(' '),
                style: text.titleLarge,
              ),
              Text(
                '${l10n.cashDueLabel} : ${formatMoney(b.due)}',
                style: text.titleMedium!.copyWith(color: tokens.warning),
              ),
              if (b.due > 0) ...[
                const SizedBox(height: Space.md),
                TextField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(labelText: l10n.cashAmount),
                ),
                const SizedBox(height: Space.sm),
                TextField(
                  controller: _reference,
                  decoration: InputDecoration(labelText: l10n.cashReference),
                ),
                const SizedBox(height: Space.md),
                FilledButton(
                  onPressed: _busy ? null : _record,
                  child: Text(l10n.cashRecord),
                ),
              ],
              const SizedBox(height: Space.lg),
              SectionHeader(title: l10n.cashHistory),
              for (final e in entries)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    e.type == 'collected'
                        ? l10n.cashEntryCollected(e.orderNumber ?? '')
                        : [l10n.cashEntryRemitted, ?e.reference].join(' · '),
                  ),
                  subtitle: Text(date.format(e.createdAt.toLocal())),
                  trailing: Text(
                    '${e.type == 'collected' ? '+' : '−'}${formatMoney(e.amount)}',
                    style: text.titleMedium!.copyWith(
                      color: e.type == 'collected'
                          ? tokens.warning
                          : tokens.success,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
