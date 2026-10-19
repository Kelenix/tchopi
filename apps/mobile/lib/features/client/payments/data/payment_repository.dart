import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Moyens de paiement et transactions du client (PAY-01, TRX-01) ; la RLS ne livre que les siennes.
class PaymentRepository {
  PaymentRepository(this._client);

  final SupabaseClient _client;

  /// Moyens activés du pays de la zone desservie (Côte d'Ivoire seulement au lancement, D-1).
  Future<List<PaymentOption>> options() => guardCall(() async {
    final rows = await _client
        .from('payment_options')
        .select()
        .eq('is_enabled', true)
        .order('position', ascending: true);
    return rows.map(PaymentOption.fromJson).toList();
  });

  Future<List<PaymentTransaction>> mine() => guardCall(() async {
    final rows = await _client
        .from('transactions')
        .select('*, order:orders(number, status)')
        .order('created_at', ascending: false)
        .limit(100);
    return rows.map(PaymentTransaction.fromJson).toList();
  });
}
