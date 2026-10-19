import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'cart.dart';
import 'data/order_repository.dart';

part 'orders_providers.g.dart';

@riverpod
OrderRepository orderRepository(Ref ref) =>
    OrderRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<List<Order>> myOrders(Ref ref) =>
    ref.watch(orderRepositoryProvider).mine();

/// Commande complète, rechargée à chaque changement en direct (motif de refus, livreur, dates).
@riverpod
Future<Order> order(Ref ref, String id) {
  ref.watch(orderLiveProvider(id));
  return ref.watch(orderRepositoryProvider).fetch(id);
}

@riverpod
Stream<CourierLocation?> courierLocation(Ref ref, String courierId) =>
    ref.watch(orderRepositoryProvider).watchCourier(courierId);

@riverpod
Stream<OrderLive> orderLive(Ref ref, String id) =>
    ref.watch(orderRepositoryProvider).watchLive(id);

/// Chronologie, rechargée à chaque changement en direct.
@riverpod
Future<List<OrderEvent>> orderEvents(Ref ref, String id) {
  ref.watch(orderLiveProvider(id));
  return ref.watch(orderRepositoryProvider).events(id);
}

@riverpod
Stream<List<Order>> restaurantOrders(Ref ref, String restaurantId) =>
    ref.watch(orderRepositoryProvider).watchRestaurant(restaurantId);

@riverpod
Future<List<OrderItem>> orderItems(Ref ref, String orderId) =>
    ref.watch(orderRepositoryProvider).items(orderId);

/// Devis serveur du panier pour l'adresse choisie ; recalculé à chaque changement du panier (ORD-06).
@riverpod
Future<FoodQuote?> cartQuote(Ref ref, String addressId) async {
  final cart = await ref.watch(cartControllerProvider.future);
  if (cart == null) return null;
  return ref.watch(orderRepositoryProvider).quote(cart, addressId);
}

@riverpod
Future<List<ParcelType>> parcelTypes(Ref ref, double lat, double lng) =>
    ref.watch(orderRepositoryProvider).parcelTypes(lat, lng);

@riverpod
Future<String?> deliveryCode(Ref ref, String orderId) =>
    ref.watch(orderRepositoryProvider).deliveryCode(orderId);
