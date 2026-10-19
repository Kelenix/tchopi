import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../orders/presentation/order_widgets.dart';
import '../../admin_scaffold.dart';
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

class _Transactions extends ConsumerWidget {
  const _Transactions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final date = DateFormat('d MMM · HH:mm', 'fr');
    return switch (ref.watch(adminTransactionsProvider)) {
      AsyncData(value: final list) when list.isEmpty => EmptyState(
        icon: Icons.receipt_long_outlined,
        title: l10n.txEmpty,
      ),
      AsyncData(value: final list) => RefreshIndicator(
        onRefresh: () => ref.refresh(adminTransactionsProvider.future),
        child: ListView.separated(
          padding: const EdgeInsets.all(Space.screen),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: Space.sm),
          itemBuilder: (context, index) {
            final t = list[index];
            final (status, color) = transactionStatus(context, t);
            return Card(
              child: ListTile(
                onTap: () => context.push(AdminOrderScreen.location(t.orderId)),
                leading: Icon(paymentIcon(t.method)),
                title: Text(t.orderNumber ?? ''),
                subtitle: Text(date.format(t.createdAt.toLocal())),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatMoney(t.amount, currency: t.currency),
                      style: text.titleMedium,
                    ),
                    Text(status, style: text.bodySmall!.copyWith(color: color)),
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
