// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(orderRepository)
final orderRepositoryProvider = OrderRepositoryProvider._();

final class OrderRepositoryProvider
    extends
        $FunctionalProvider<OrderRepository, OrderRepository, OrderRepository>
    with $Provider<OrderRepository> {
  OrderRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrderRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrderRepository create(Ref ref) {
    return orderRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrderRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrderRepository>(value),
    );
  }
}

String _$orderRepositoryHash() => r'a574a2ee1a2b9f05eb8ff7634f85ed8080f13c6d';

@ProviderFor(myOrders)
final myOrdersProvider = MyOrdersProvider._();

final class MyOrdersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Order>>,
          List<Order>,
          FutureOr<List<Order>>
        >
    with $FutureModifier<List<Order>>, $FutureProvider<List<Order>> {
  MyOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myOrdersHash();

  @$internal
  @override
  $FutureProviderElement<List<Order>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Order>> create(Ref ref) {
    return myOrders(ref);
  }
}

String _$myOrdersHash() => r'd12715bf5db3d5fabe806f89fb6a57ca71f12c4d';

/// Commande complète, rechargée à chaque changement de statut (motif de refus, dates).

@ProviderFor(order)
final orderProvider = OrderFamily._();

/// Commande complète, rechargée à chaque changement de statut (motif de refus, dates).

final class OrderProvider
    extends $FunctionalProvider<AsyncValue<Order>, Order, FutureOr<Order>>
    with $FutureModifier<Order>, $FutureProvider<Order> {
  /// Commande complète, rechargée à chaque changement de statut (motif de refus, dates).
  OrderProvider._({
    required OrderFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'orderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderHash();

  @override
  String toString() {
    return r'orderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Order> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Order> create(Ref ref) {
    final argument = this.argument as String;
    return order(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderHash() => r'71bac15cd1d2b7ca7b9ba08bfee84a879fbaa7dd';

/// Commande complète, rechargée à chaque changement de statut (motif de refus, dates).

final class OrderFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Order>, String> {
  OrderFamily._()
    : super(
        retry: null,
        name: r'orderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Commande complète, rechargée à chaque changement de statut (motif de refus, dates).

  OrderProvider call(String id) => OrderProvider._(argument: id, from: this);

  @override
  String toString() => r'orderProvider';
}

@ProviderFor(orderStatus)
final orderStatusProvider = OrderStatusFamily._();

final class OrderStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<OrderStatus>,
          OrderStatus,
          Stream<OrderStatus>
        >
    with $FutureModifier<OrderStatus>, $StreamProvider<OrderStatus> {
  OrderStatusProvider._({
    required OrderStatusFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'orderStatusProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderStatusHash();

  @override
  String toString() {
    return r'orderStatusProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<OrderStatus> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<OrderStatus> create(Ref ref) {
    final argument = this.argument as String;
    return orderStatus(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderStatusProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderStatusHash() => r'3ceec3ba981826a4c3d3b13547f43dca0e3427d7';

final class OrderStatusFamily extends $Family
    with $FunctionalFamilyOverride<Stream<OrderStatus>, String> {
  OrderStatusFamily._()
    : super(
        retry: null,
        name: r'orderStatusProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OrderStatusProvider call(String id) =>
      OrderStatusProvider._(argument: id, from: this);

  @override
  String toString() => r'orderStatusProvider';
}

/// Chronologie, rechargée à chaque changement de statut.

@ProviderFor(orderEvents)
final orderEventsProvider = OrderEventsFamily._();

/// Chronologie, rechargée à chaque changement de statut.

final class OrderEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<OrderEvent>>,
          List<OrderEvent>,
          FutureOr<List<OrderEvent>>
        >
    with $FutureModifier<List<OrderEvent>>, $FutureProvider<List<OrderEvent>> {
  /// Chronologie, rechargée à chaque changement de statut.
  OrderEventsProvider._({
    required OrderEventsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'orderEventsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderEventsHash();

  @override
  String toString() {
    return r'orderEventsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<OrderEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<OrderEvent>> create(Ref ref) {
    final argument = this.argument as String;
    return orderEvents(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderEventsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderEventsHash() => r'cf032b3639f3cab6d4a46c65d119558efd355d43';

/// Chronologie, rechargée à chaque changement de statut.

final class OrderEventsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<OrderEvent>>, String> {
  OrderEventsFamily._()
    : super(
        retry: null,
        name: r'orderEventsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Chronologie, rechargée à chaque changement de statut.

  OrderEventsProvider call(String id) =>
      OrderEventsProvider._(argument: id, from: this);

  @override
  String toString() => r'orderEventsProvider';
}

@ProviderFor(restaurantOrders)
final restaurantOrdersProvider = RestaurantOrdersFamily._();

final class RestaurantOrdersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Order>>,
          List<Order>,
          Stream<List<Order>>
        >
    with $FutureModifier<List<Order>>, $StreamProvider<List<Order>> {
  RestaurantOrdersProvider._({
    required RestaurantOrdersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'restaurantOrdersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$restaurantOrdersHash();

  @override
  String toString() {
    return r'restaurantOrdersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Order>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Order>> create(Ref ref) {
    final argument = this.argument as String;
    return restaurantOrders(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RestaurantOrdersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$restaurantOrdersHash() => r'2fcec31a0bc02e9a2c5721b40068c9c01af47cce';

final class RestaurantOrdersFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Order>>, String> {
  RestaurantOrdersFamily._()
    : super(
        retry: null,
        name: r'restaurantOrdersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RestaurantOrdersProvider call(String restaurantId) =>
      RestaurantOrdersProvider._(argument: restaurantId, from: this);

  @override
  String toString() => r'restaurantOrdersProvider';
}

@ProviderFor(orderItems)
final orderItemsProvider = OrderItemsFamily._();

final class OrderItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<OrderItem>>,
          List<OrderItem>,
          FutureOr<List<OrderItem>>
        >
    with $FutureModifier<List<OrderItem>>, $FutureProvider<List<OrderItem>> {
  OrderItemsProvider._({
    required OrderItemsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'orderItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderItemsHash();

  @override
  String toString() {
    return r'orderItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<OrderItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<OrderItem>> create(Ref ref) {
    final argument = this.argument as String;
    return orderItems(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderItemsHash() => r'9e695d85b4095893113413b97bd8b034899d7376';

final class OrderItemsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<OrderItem>>, String> {
  OrderItemsFamily._()
    : super(
        retry: null,
        name: r'orderItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OrderItemsProvider call(String orderId) =>
      OrderItemsProvider._(argument: orderId, from: this);

  @override
  String toString() => r'orderItemsProvider';
}

/// Devis serveur du panier pour l'adresse choisie ; recalculé à chaque changement du panier (ORD-06).

@ProviderFor(cartQuote)
final cartQuoteProvider = CartQuoteFamily._();

/// Devis serveur du panier pour l'adresse choisie ; recalculé à chaque changement du panier (ORD-06).

final class CartQuoteProvider
    extends
        $FunctionalProvider<
          AsyncValue<FoodQuote?>,
          FoodQuote?,
          FutureOr<FoodQuote?>
        >
    with $FutureModifier<FoodQuote?>, $FutureProvider<FoodQuote?> {
  /// Devis serveur du panier pour l'adresse choisie ; recalculé à chaque changement du panier (ORD-06).
  CartQuoteProvider._({
    required CartQuoteFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cartQuoteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cartQuoteHash();

  @override
  String toString() {
    return r'cartQuoteProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<FoodQuote?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<FoodQuote?> create(Ref ref) {
    final argument = this.argument as String;
    return cartQuote(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CartQuoteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cartQuoteHash() => r'3a840c2160031dc7d2d373f8f4daf6c8f14b7916';

/// Devis serveur du panier pour l'adresse choisie ; recalculé à chaque changement du panier (ORD-06).

final class CartQuoteFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<FoodQuote?>, String> {
  CartQuoteFamily._()
    : super(
        retry: null,
        name: r'cartQuoteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Devis serveur du panier pour l'adresse choisie ; recalculé à chaque changement du panier (ORD-06).

  CartQuoteProvider call(String addressId) =>
      CartQuoteProvider._(argument: addressId, from: this);

  @override
  String toString() => r'cartQuoteProvider';
}
