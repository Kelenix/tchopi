import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'data/admin_payments_repository.dart';

part 'admin_payments_providers.g.dart';

@riverpod
AdminPaymentsRepository adminPaymentsRepository(Ref ref) =>
    AdminPaymentsRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<List<PaymentOption>> adminPaymentOptions(Ref ref) =>
    ref.watch(adminPaymentsRepositoryProvider).options();

@riverpod
Future<List<PaymentTransaction>> adminTransactions(Ref ref) =>
    ref.watch(adminPaymentsRepositoryProvider).transactions();

@riverpod
Future<List<CashBalance>> cashBalances(Ref ref) =>
    ref.watch(adminPaymentsRepositoryProvider).balances();

@riverpod
Future<List<CashEntry>> cashLedger(Ref ref, String courierId) =>
    ref.watch(adminPaymentsRepositoryProvider).ledger(courierId);
