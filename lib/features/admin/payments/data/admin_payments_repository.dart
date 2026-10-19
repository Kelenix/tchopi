import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Moyens de paiement, transactions et espèces des livreurs (admins seulement, garanti par la RLS).
class AdminPaymentsRepository {
  AdminPaymentsRepository(this._client);

  final SupabaseClient _client;

  Future<List<PaymentOption>> options() => guardCall(() async {
    final rows = await _client
        .from('payment_options')
        .select()
        .order('country_code', ascending: true)
        .order('position', ascending: true);
    return rows.map(PaymentOption.fromJson).toList();
  });

  Future<void> setOption(String id, {required bool enabled}) => guardCall(
    () => _client.rpc<void>(
      'admin_set_payment_option',
      params: {'p_id': id, 'p_enabled': enabled},
    ),
  );

  Future<List<PaymentTransaction>> transactions() => guardCall(() async {
    final rows = await _client
        .from('transactions')
        .select('*, order:orders(number, status, zone_id, payment_status)')
        .order('created_at', ascending: false)
        .limit(200);
    return rows.map(PaymentTransaction.fromJson).toList();
  });

  Future<List<CashBalance>> balances() => guardCall(() async {
    final rows = await _client.rpc<List<dynamic>>('admin_cash_balances');
    return rows.cast<Map<String, dynamic>>().map(CashBalance.fromJson).toList();
  });

  Future<List<CashEntry>> ledger(String courierId) => guardCall(() async {
    final rows = await _client
        .from('cash_ledger')
        .select('id, type, amount, reference, created_at, order:orders(number)')
        .eq('courier_id', courierId)
        .order('created_at', ascending: false)
        .limit(100);
    return rows.map(CashEntry.fromJson).toList();
  });

  Future<void> recordRemittance(
    String courierId,
    int amount,
    String? reference,
  ) => guardCall(
    () => _client.rpc<void>(
      'admin_record_cash_remittance',
      params: {
        'p_courier_id': courierId,
        'p_amount': amount,
        'p_reference': reference,
      },
    ),
  );
}
