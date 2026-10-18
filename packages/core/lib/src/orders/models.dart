import 'package:freezed_annotation/freezed_annotation.dart';

import '../couriers/models.dart';

part 'models.freezed.dart';
part 'models.g.dart';

/// Statuts d'une commande (docs/data-model.md §3, §5).
enum OrderStatus {
  @JsonValue('awaiting_payment')
  awaitingPayment,
  pending,
  accepted,
  preparing,
  ready,
  @JsonValue('searching_courier')
  searchingCourier,
  @JsonValue('courier_assigned')
  courierAssigned,
  @JsonValue('picked_up')
  pickedUp,
  @JsonValue('in_transit')
  inTransit,
  delivered,
  rejected,
  cancelled,
  failed;

  bool get isClosed =>
      this == delivered ||
      this == rejected ||
      this == cancelled ||
      this == failed;

  /// Valeur attendue par l'API (`transition_order`).
  String get wireName => switch (this) {
    awaitingPayment => 'awaiting_payment',
    searchingCourier => 'searching_courier',
    courierAssigned => 'courier_assigned',
    pickedUp => 'picked_up',
    inTransit => 'in_transit',
    _ => name,
  };
}

enum OrderType { food, parcel }

enum PaymentMethod {
  cash,
  @JsonValue('mobile_money')
  mobileMoney,
  card;

  String get wireName => this == mobileMoney ? 'mobile_money' : name;
}

/// Commande, montants et adresses figés au moment de la commande (ORD-07, ORD-12).
@freezed
abstract class Order with _$Order {
  const factory Order({
    required String id,
    required String number,
    @Default(OrderType.food) OrderType type,
    required OrderStatus status,
    String? zoneId,
    String? restaurantId,
    String? parcelTypeId,
    String? parcelDescription,
    required String pickupName,
    String? pickupPhone,
    @Default('') String pickupDistrict,
    @Default('') String pickupLandmark,
    required String recipientName,
    String? recipientPhone,
    required String dropoffDistrict,
    required String dropoffLandmark,
    String? dropoffInstructions,
    required int subtotal,
    required int deliveryFee,
    required int total,
    @Default(0) int commissionAmount,
    @Default(0) int courierEarning,
    @Default(0) int platformAmount,
    @Default('XOF') String currency,
    required PaymentMethod paymentMethod,
    required DateTime createdAt,
    String? closeReason,
    String? courierId,
    CourierInfo? courierInfo,

    /// Toujours sans livreur après le délai d'alerte (DIS-03).
    DateTime? dispatchAlertedAt,
    @JsonKey(name: 'order_items') @Default([]) List<OrderItem> items,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

@freezed
abstract class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String orderId,
    required String name,
    required int unitPrice,
    required int quantity,
    required int lineTotal,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}

/// Étape de la chronologie (TRK-03) : changement de statut, ou événement (`courier_assigned`,
/// `courier_released`, `dispatch_alert`).
@freezed
abstract class OrderEvent with _$OrderEvent {
  const factory OrderEvent({
    @Default('status_changed') String kind,
    OrderStatus? status,
    required String actorRole,
    String? reason,
    required DateTime createdAt,
  }) = _OrderEvent;

  factory OrderEvent.fromJson(Map<String, dynamic> json) =>
      _$OrderEventFromJson(json);
}

/// Devis serveur d'un panier (ORD-06) ; `issues` liste les écarts qui empêchent de commander.
@freezed
abstract class FoodQuote with _$FoodQuote {
  const factory FoodQuote({
    required int subtotal,
    required int deliveryFee,
    required int total,
    required int distanceM,
    @Default('XOF') String currency,
    @Default([]) List<QuoteIssue> issues,

    /// Au moins un livreur en ligne dans la zone (ORD-07, PAR-03).
    @Default(true) bool couriersAvailable,
  }) = _FoodQuote;

  factory FoodQuote.fromJson(Map<String, dynamic> json) =>
      _$FoodQuoteFromJson(json);
}

/// `restaurant_closed` ou `product_unavailable` (avec le produit concerné).
@freezed
abstract class QuoteIssue with _$QuoteIssue {
  const factory QuoteIssue({
    required String issue,
    String? productId,
    String? name,
  }) = _QuoteIssue;

  factory QuoteIssue.fromJson(Map<String, dynamic> json) =>
      _$QuoteIssueFromJson(json);
}

/// Type de colis proposé (PAR-01) : libellé, poids maximal, moyens de transport capables de le porter.
@freezed
abstract class ParcelType with _$ParcelType {
  const factory ParcelType({
    required String id,
    required String code,
    required String label,
    required double maxWeightKg,
  }) = _ParcelType;

  factory ParcelType.fromJson(Map<String, dynamic> json) =>
      _$ParcelTypeFromJson(json);
}

/// Point de retrait ou de livraison d'un colis : position, quartier, repère, instructions.
@freezed
abstract class ParcelPoint with _$ParcelPoint {
  const ParcelPoint._();

  const factory ParcelPoint({
    required double lat,
    required double lng,
    required String district,
    required String landmark,
    String? instructions,
  }) = _ParcelPoint;

  Map<String, Object?> toApi() => {
    'lat': lat,
    'lng': lng,
    'district': district.trim(),
    'landmark': landmark.trim(),
    'instructions': instructions?.trim(),
  };
}
