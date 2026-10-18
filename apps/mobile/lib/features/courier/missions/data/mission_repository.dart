import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Disponibilité, position, offres et mission en cours du livreur connecté (COU-05, DIS-02).
class MissionRepository {
  MissionRepository(this._client);

  final SupabaseClient _client;

  Future<void> setOnline(bool online) => guardCall(
    () => _client.rpc<void>('set_courier_online', params: {'p_online': online}),
  );

  Future<void> reportLocation(double lat, double lng, double accuracyM) =>
      guardCall(
        () => _client.rpc<void>(
          'report_location',
          params: {'p_lat': lat, 'p_lng': lng, 'p_accuracy_m': accuracyM},
        ),
      );

  /// Offre en attente la plus récente, en temps réel (la RLS ne livre que les siennes).
  Stream<DeliveryOffer?> watchPendingOffer(String courierId) => _client
      .from('delivery_offers')
      .stream(primaryKey: ['id'])
      .eq('courier_id', courierId)
      .order('created_at')
      .limit(5)
      .map(
        (rows) => rows
            .map(DeliveryOffer.fromJson)
            .where((offer) => offer.status == OfferStatus.pending)
            .firstOrNull,
      )
      .handleError((Object error) => throw toFailure(error));

  Future<void> respond(String offerId, {required bool accept}) => guardCall(
    () => _client.rpc<void>(
      'respond_to_offer',
      params: {'p_offer_id': offerId, 'p_accept': accept},
    ),
  );

  /// Mission en cours : commande attribuée et non close, en temps réel.
  Stream<Order?> watchMission(String courierId) => _client
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('courier_id', courierId)
      .order('created_at')
      .limit(10)
      .map(
        (rows) => rows
            .map((row) => Order.fromJson({...row, 'order_items': <Object>[]}))
            .where((order) => !order.status.isClosed)
            .firstOrNull,
      )
      .handleError((Object error) => throw toFailure(error));
}
