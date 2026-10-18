import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supervision des commandes, attribution manuelle et paramètres de la plateforme (admins, garanti par la RLS).
class SupervisionRepository {
  SupervisionRepository(this._client);

  final SupabaseClient _client;

  static const activeStatuses = [
    'awaiting_payment',
    'pending',
    'accepted',
    'preparing',
    'ready',
    'searching_courier',
    'courier_assigned',
    'picked_up',
    'in_transit',
  ];

  /// Commandes en cours, en temps réel, les plus récentes d'abord (ADM-03).
  Stream<List<Order>> watchActive() => _client
      .from('orders')
      .stream(primaryKey: ['id'])
      .inFilter('status', activeStatuses)
      .order('created_at')
      .limit(200)
      .map(
        (rows) => [
          for (final row in rows)
            Order.fromJson({...row, 'order_items': <Object>[]}),
        ],
      )
      .handleError((Object error) => throw toFailure(error));

  Future<List<DispatchCandidate>> candidates(String orderId) =>
      guardCall(() async {
        final rows = await _client.rpc<List<dynamic>>(
          'admin_dispatch_candidates',
          params: {'p_order_id': orderId},
        );
        return rows
            .cast<Map<String, dynamic>>()
            .map(DispatchCandidate.fromJson)
            .toList();
      });

  Future<void> assign(String orderId, String courierId, String reason) =>
      guardCall(
        () => _client.rpc<void>(
          'admin_assign_courier',
          params: {
            'p_order_id': orderId,
            'p_courier_id': courierId,
            'p_reason': reason,
          },
        ),
      );

  Future<PlatformSettings> settings() => guardCall(() async {
    final row = await _client.from('settings').select().single();
    return PlatformSettings.fromJson(row);
  });

  Future<PlatformSettings> saveSettings(PlatformSettings settings) =>
      guardCall(() async {
        final row = await _client
            .from('settings')
            .update({
              'offer_timeout_s': settings.offerTimeoutS,
              'restaurant_timeout_s': settings.restaurantTimeoutS,
              'payment_timeout_s': settings.paymentTimeoutS,
              'dispatch_alert_s': settings.dispatchAlertS,
              'dispatch_cancel_s': settings.dispatchCancelS,
              'support_phone': settings.supportPhone,
            })
            .eq('id', true)
            .select()
            .single();
        return PlatformSettings.fromJson(row);
      });
}
