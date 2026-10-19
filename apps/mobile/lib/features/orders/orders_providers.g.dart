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

/// Commande complète, rechargée à chaque changement en direct (motif de refus, livreur, dates).

@ProviderFor(order)
final orderProvider = OrderFamily._();

/// Commande complète, rechargée à chaque changement en direct (motif de refus, livreur, dates).

final class OrderProvider
    extends $FunctionalProvider<AsyncValue<Order>, Order, FutureOr<Order>>
    with $FutureModifier<Order>, $FutureProvider<Order> {
  /// Commande complète, rechargée à chaque changement en direct (motif de refus, livreur, dates).
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

String _$orderHash() => r'89bee9908266ee99d362ff1c9df7db82bf224272';

/// Commande complète, rechargée à chaque changement en direct (motif de refus, livreur, dates).

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

  /// Commande complète, rechargée à chaque changement en direct (motif de refus, livreur, dates).

  OrderProvider call(String id) => OrderProvider._(argument: id, from: this);

  @override
  String toString() => r'orderProvider';
}

@ProviderFor(courierLocation)
final courierLocationProvider = CourierLocationFamily._();

final class CourierLocationProvider
    extends
        $FunctionalProvider<
          AsyncValue<CourierLocation?>,
          CourierLocation?,
          Stream<CourierLocation?>
        >
    with $FutureModifier<CourierLocation?>, $StreamProvider<CourierLocation?> {
  CourierLocationProvider._({
    required CourierLocationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'courierLocationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$courierLocationHash();

  @override
  String toString() {
    return r'courierLocationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<CourierLocation?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<CourierLocation?> create(Ref ref) {
    final argument = this.argument as String;
    return courierLocation(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CourierLocationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$courierLocationHash() => r'897559e26f41ad0c4bda6f45bb8ef37047789cd8';

final class CourierLocationFamily extends $Family
    with $FunctionalFamilyOverride<Stream<CourierLocation?>, String> {
  CourierLocationFamily._()
    : super(
        retry: null,
        name: r'courierLocationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CourierLocationProvider call(String courierId) =>
      CourierLocationProvider._(argument: courierId, from: this);

  @override
  String toString() => r'courierLocationProvider';
}

@ProviderFor(orderLive)
final orderLiveProvider = OrderLiveFamily._();

final class OrderLiveProvider
    extends
        $FunctionalProvider<AsyncValue<OrderLive>, OrderLive, Stream<OrderLive>>
    with $FutureModifier<OrderLive>, $StreamProvider<OrderLive> {
  OrderLiveProvider._({
    required OrderLiveFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'orderLiveProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderLiveHash();

  @override
  String toString() {
    return r'orderLiveProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<OrderLive> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<OrderLive> create(Ref ref) {
    final argument = this.argument as String;
    return orderLive(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderLiveProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderLiveHash() => r'670b31b49d811e9539d36a316df78aef15250c77';

final class OrderLiveFamily extends $Family
    with $FunctionalFamilyOverride<Stream<OrderLive>, String> {
  OrderLiveFamily._()
    : super(
        retry: null,
        name: r'orderLiveProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OrderLiveProvider call(String id) =>
      OrderLiveProvider._(argument: id, from: this);

  @override
  String toString() => r'orderLiveProvider';
}

/// Chronologie, rechargée à chaque changement en direct.

@ProviderFor(orderEvents)
final orderEventsProvider = OrderEventsFamily._();

/// Chronologie, rechargée à chaque changement en direct.

final class OrderEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<OrderEvent>>,
          List<OrderEvent>,
          FutureOr<List<OrderEvent>>
        >
    with $FutureModifier<List<OrderEvent>>, $FutureProvider<List<OrderEvent>> {
  /// Chronologie, rechargée à chaque changement en direct.
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

String _$orderEventsHash() => r'fec750d90ac9bebae07f377368f0f3cd55a66d57';

/// Chronologie, rechargée à chaque changement en direct.

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

  /// Chronologie, rechargée à chaque changement en direct.

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

@ProviderFor(parcelTypes)
final parcelTypesProvider = ParcelTypesFamily._();

final class ParcelTypesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ParcelType>>,
          List<ParcelType>,
          FutureOr<List<ParcelType>>
        >
    with $FutureModifier<List<ParcelType>>, $FutureProvider<List<ParcelType>> {
  ParcelTypesProvider._({
    required ParcelTypesFamily super.from,
    required (double, double) super.argument,
  }) : super(
         retry: null,
         name: r'parcelTypesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$parcelTypesHash();

  @override
  String toString() {
    return r'parcelTypesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<ParcelType>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ParcelType>> create(Ref ref) {
    final argument = this.argument as (double, double);
    return parcelTypes(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ParcelTypesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$parcelTypesHash() => r'931c28423af53c26c2c19dcc14005f9eb50fc6b1';

final class ParcelTypesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ParcelType>>,
          (double, double)
        > {
  ParcelTypesFamily._()
    : super(
        retry: null,
        name: r'parcelTypesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ParcelTypesProvider call(double lat, double lng) =>
      ParcelTypesProvider._(argument: (lat, lng), from: this);

  @override
  String toString() => r'parcelTypesProvider';
}

@ProviderFor(deliveryCode)
final deliveryCodeProvider = DeliveryCodeFamily._();

final class DeliveryCodeProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  DeliveryCodeProvider._({
    required DeliveryCodeFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deliveryCodeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deliveryCodeHash();

  @override
  String toString() {
    return r'deliveryCodeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return deliveryCode(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeliveryCodeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deliveryCodeHash() => r'23d556bfbfca6aae4c25a627a1f74de8d501e29d';

final class DeliveryCodeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  DeliveryCodeFamily._()
    : super(
        retry: null,
        name: r'deliveryCodeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeliveryCodeProvider call(String orderId) =>
      DeliveryCodeProvider._(argument: orderId, from: this);

  @override
  String toString() => r'deliveryCodeProvider';
}
