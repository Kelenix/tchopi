import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../cart.dart';

/// Ce qui change en direct sur une commande : statut, livreur attribué, alerte « toujours sans livreur »,
/// paiement (encaissé, à rembourser, remboursé).
typedef OrderLive = ({
  OrderStatus status,
  String? courierId,
  DateTime? dispatchAlertedAt,
  OrderPaymentStatus paymentStatus,
});

/// Commandes de repas : devis, création et suivi (client), réception et actions (restaurant).
/// Montants et statuts ne sont jamais écrits directement : uniquement par les fonctions serveur (RLS).
class OrderRepository {
  OrderRepository(this._client);

  final SupabaseClient _client;

  static const _withItems = '*, order_items(*)';

  List<Map<String, Object>> _items(Cart cart) => [
    for (final line in cart.lines)
      {
        'product_id': line.productId,
        'quantity': line.quantity,
        if (line.optionIds.isNotEmpty) 'options': line.optionIds,
      },
  ];

  Future<FoodQuote> quote(Cart cart, String addressId) => guardCall(() async {
    final json = await _client.rpc<Map<String, dynamic>>(
      'quote_food_order',
      params: {
        'p_restaurant_id': cart.restaurantId,
        'p_address_id': addressId,
        'p_items': _items(cart),
      },
    );
    return FoodQuote.fromJson(json);
  });

  /// La même [idempotencyKey] rend la commande déjà créée (double toucher, coupure réseau).
  Future<Order> place({
    required Cart cart,
    required String addressId,
    required PaymentMethod method,
    required int expectedTotal,
    required String idempotencyKey,
  }) => guardCall(() async {
    final row = await _client.rpc<Map<String, dynamic>>(
      'place_food_order',
      params: {
        'p_restaurant_id': cart.restaurantId,
        'p_address_id': addressId,
        'p_items': _items(cart),
        'p_payment_method': method.wireName,
        'p_expected_total': expectedTotal,
        'p_idempotency_key': idempotencyKey,
      },
    );
    return Order.fromJson(row);
  });

  /// Mes commandes, les plus récentes d'abord (un gérant voit aussi celles de son restaurant : filtre explicite).
  Future<List<Order>> mine() => guardCall(() async {
    final rows = await _client
        .from('orders')
        .select(_withItems)
        .eq('customer_id', _client.auth.currentUser!.id)
        .order('created_at', ascending: false)
        .limit(50);
    return rows.map(Order.fromJson).toList();
  });

  Future<Order> fetch(String id) => guardCall(() async {
    final row = await _client
        .from('orders')
        .select(_withItems)
        .eq('id', id)
        .single();
    return Order.fromJson(row);
  });

  /// Changements en temps réel (sans les lignes, qui ne changent pas).
  Stream<OrderLive> watchLive(String id) => _client
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('id', id)
      .where((rows) => rows.isNotEmpty)
      .map((rows) {
        final o = Order.fromJson({...rows.first, 'order_items': <Object>[]});
        return (
          status: o.status,
          courierId: o.courierId,
          dispatchAlertedAt: o.dispatchAlertedAt,
          paymentStatus: o.paymentStatus,
        );
      })
      .handleError((Object error) => throw toFailure(error));

  /// Position du livreur de ma commande en cours, en temps réel (la RLS la cache ensuite).
  Stream<CourierLocation?> watchCourier(String courierId) => _client
      .from('courier_locations')
      .stream(primaryKey: ['courier_id'])
      .eq('courier_id', courierId)
      .map((rows) => rows.isEmpty ? null : CourierLocation.fromJson(rows.first))
      .handleError((Object error) => throw toFailure(error));

  Future<List<OrderEvent>> events(String id) => guardCall(() async {
    final rows = await _client
        .from('order_events')
        .select('kind, status, actor_role, reason, created_at')
        .eq('order_id', id)
        .order('id', ascending: true);
    return rows.map(OrderEvent.fromJson).toList();
  });

  /// Le motif n'est exigé que de l'admin (commande déjà acceptée).
  Future<void> cancel(String id, {String? reason}) => guardCall(
    () => _client.rpc<void>(
      'cancel_order',
      params: {'p_order_id': id, 'p_reason': reason},
    ),
  );

  /// Commandes du restaurant en temps réel, les plus récentes d'abord.
  Stream<List<Order>> watchRestaurant(String restaurantId) => _client
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('restaurant_id', restaurantId)
      .order('created_at')
      .limit(100)
      .map(
        (rows) => [
          for (final row in rows)
            Order.fromJson({...row, 'order_items': <Object>[]}),
        ],
      )
      .handleError((Object error) => throw toFailure(error));

  Future<List<OrderItem>> items(String orderId) => guardCall(() async {
    final rows = await _client
        .from('order_items')
        .select('order_id, name, unit_price, quantity, line_total')
        .eq('order_id', orderId)
        .order('name', ascending: true);
    return rows.map(OrderItem.fromJson).toList();
  });

  Future<void> transition(String id, OrderStatus to, {String? reason}) =>
      guardCall(
        () => _client.rpc<void>(
          'transition_order',
          params: {
            'p_order_id': id,
            'p_to_status': to.wireName,
            'p_reason': reason,
          },
        ),
      );

  // Colis (Inc-6)

  /// Types transportables par les livreurs en ligne autour du point de départ (PAR-01).
  Future<List<ParcelType>> parcelTypes(double lat, double lng) =>
      guardCall(() async {
        final rows = await _client.rpc<List<dynamic>>(
          'available_parcel_types',
          params: {'p_lat': lat, 'p_lng': lng},
        );
        return rows
            .cast<Map<String, dynamic>>()
            .map(ParcelType.fromJson)
            .toList();
      });

  Future<FoodQuote> quoteParcel(
    ParcelPoint pickup,
    ParcelPoint dropoff,
    String parcelTypeId,
  ) => guardCall(() async {
    final json = await _client.rpc<Map<String, dynamic>>(
      'quote_parcel',
      params: {
        'p_pickup_lat': pickup.lat,
        'p_pickup_lng': pickup.lng,
        'p_dropoff_lat': dropoff.lat,
        'p_dropoff_lng': dropoff.lng,
        'p_parcel_type_id': parcelTypeId,
      },
    );
    return FoodQuote.fromJson(json);
  });

  /// La même [idempotencyKey] rend la demande déjà créée.
  Future<Order> placeParcel({
    required ParcelPoint pickup,
    required ParcelPoint dropoff,
    required String recipientName,
    required String recipientPhone,
    required String parcelTypeId,
    required String description,
    required bool rulesAccepted,
    required PaymentMethod method,
    required int expectedTotal,
    required String idempotencyKey,
  }) => guardCall(() async {
    final row = await _client.rpc<Map<String, dynamic>>(
      'place_parcel_order',
      params: {
        'p_pickup': pickup.toApi(),
        'p_dropoff': dropoff.toApi(),
        'p_recipient_name': recipientName.trim(),
        'p_recipient_phone': recipientPhone,
        'p_parcel_type_id': parcelTypeId,
        'p_description': description.trim(),
        'p_rules_accepted': rulesAccepted,
        'p_payment_method': method.wireName,
        'p_expected_total': expectedTotal,
        'p_idempotency_key': idempotencyKey,
      },
    );
    return Order.fromJson(row);
  });

  /// Code de livraison (lisible uniquement par le client de la commande).
  Future<String?> deliveryCode(String orderId) => guardCall(() async {
    final row = await _client
        .from('delivery_codes')
        .select('code')
        .eq('order_id', orderId)
        .maybeSingle();
    return row?['code'] as String?;
  });
}
