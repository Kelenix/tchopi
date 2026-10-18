import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../cart.dart';

/// Commandes de repas : devis, création et suivi (client), réception et actions (restaurant).
/// Montants et statuts ne sont jamais écrits directement : uniquement par les fonctions serveur (RLS).
class OrderRepository {
  OrderRepository(this._client);

  final SupabaseClient _client;

  static const _withItems = '*, order_items(*)';

  List<Map<String, Object>> _items(Cart cart) => [
    for (final line in cart.lines)
      {'product_id': line.productId, 'quantity': line.quantity},
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

  /// Changements de statut en temps réel (sans les lignes, qui ne changent pas).
  Stream<OrderStatus> watchStatus(String id) => _client
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('id', id)
      .where((rows) => rows.isNotEmpty)
      .map(
        (rows) =>
            Order.fromJson({...rows.first, 'order_items': <Object>[]}).status,
      )
      .handleError((Object error) => throw toFailure(error));

  Future<List<OrderEvent>> events(String id) => guardCall(() async {
    final rows = await _client
        .from('order_events')
        .select('status, actor_role, reason, created_at')
        .eq('order_id', id)
        .order('created_at', ascending: true);
    return rows.map(OrderEvent.fromJson).toList();
  });

  Future<void> cancel(String id) => guardCall(
    () => _client.rpc<void>('cancel_order', params: {'p_order_id': id}),
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
}
