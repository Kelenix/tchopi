import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/more_pages.dart';

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

  /// PAY-03, PAY-04 : ouvre ou rouvre la page de paiement du fournisseur (nyole, Stripe) ; `null` si le paiement
  /// est déjà confirmé.
  Future<String?> startOnlinePayment(String orderId) => guardCall(() async {
    final response = await _client.functions.invoke(
      'payments-create',
      body: {'order_id': orderId},
    );
    return (response.data as Map<String, dynamic>)['url'] as String?;
  });

  /// Transaction de la commande, en direct : refus de l'opérateur, page ouverte, confirmation.
  Stream<PaymentTransaction?> watchOrder(String orderId) => _client
      .from('transactions')
      .stream(primaryKey: ['id'])
      .eq('order_id', orderId)
      .order('created_at')
      .map(
        (rows) => rows.isEmpty ? null : PaymentTransaction.fromJson(rows.first),
      )
      .handleError((Object error) => throw toFailure(error));

  /// Délai de paiement en ligne (ADM-05) avant annulation de la commande.
  Future<int> paymentTimeoutS() => guardCall(() async {
    final row = await _client
        .from('settings')
        .select('payment_timeout_s')
        .single();
    return row['payment_timeout_s'] as int;
  });

  Future<List<PaymentTransaction>> mine({
    int offset = 0,
    int limit = pageSize,
  }) => guardCall(() async {
    final rows = await _client
        .from('transactions')
        .select('*, order:orders(number, status, payment_status)')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return rows.map(PaymentTransaction.fromJson).toList();
  });
}
