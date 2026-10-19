// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  id: json['id'] as String,
  number: json['number'] as String,
  type: $enumDecodeNullable(_$OrderTypeEnumMap, json['type']) ?? OrderType.food,
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  zoneId: json['zone_id'] as String?,
  restaurantId: json['restaurant_id'] as String?,
  parcelTypeId: json['parcel_type_id'] as String?,
  parcelDescription: json['parcel_description'] as String?,
  pickupName: json['pickup_name'] as String,
  pickupPhone: json['pickup_phone'] as String?,
  pickupDistrict: json['pickup_district'] as String? ?? '',
  pickupLandmark: json['pickup_landmark'] as String? ?? '',
  pickupInstructions: json['pickup_instructions'] as String?,
  pickupLat: (json['pickup_lat'] as num?)?.toDouble() ?? 0,
  pickupLng: (json['pickup_lng'] as num?)?.toDouble() ?? 0,
  dropoffLat: (json['dropoff_lat'] as num?)?.toDouble() ?? 0,
  dropoffLng: (json['dropoff_lng'] as num?)?.toDouble() ?? 0,
  recipientName: json['recipient_name'] as String,
  recipientPhone: json['recipient_phone'] as String?,
  dropoffDistrict: json['dropoff_district'] as String,
  dropoffLandmark: json['dropoff_landmark'] as String,
  dropoffInstructions: json['dropoff_instructions'] as String?,
  subtotal: (json['subtotal'] as num).toInt(),
  deliveryFee: (json['delivery_fee'] as num).toInt(),
  total: (json['total'] as num).toInt(),
  commissionAmount: (json['commission_amount'] as num?)?.toInt() ?? 0,
  courierEarning: (json['courier_earning'] as num?)?.toInt() ?? 0,
  platformAmount: (json['platform_amount'] as num?)?.toInt() ?? 0,
  currency: json['currency'] as String? ?? 'XOF',
  paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['payment_method']),
  paymentStatus:
      $enumDecodeNullable(
        _$OrderPaymentStatusEnumMap,
        json['payment_status'],
      ) ??
      OrderPaymentStatus.unpaid,
  createdAt: DateTime.parse(json['created_at'] as String),
  submittedAt: json['submitted_at'] == null
      ? null
      : DateTime.parse(json['submitted_at'] as String),
  closeReason: json['close_reason'] as String?,
  courierId: json['courier_id'] as String?,
  courierInfo: json['courier_info'] == null
      ? null
      : CourierInfo.fromJson(json['courier_info'] as Map<String, dynamic>),
  dispatchAlertedAt: json['dispatch_alerted_at'] == null
      ? null
      : DateTime.parse(json['dispatch_alerted_at'] as String),
  codeLockedAt: json['code_locked_at'] == null
      ? null
      : DateTime.parse(json['code_locked_at'] as String),
  problemReportedAt: json['problem_reported_at'] == null
      ? null
      : DateTime.parse(json['problem_reported_at'] as String),
  items:
      (json['order_items'] as List<dynamic>?)
          ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'id': instance.id,
  'number': instance.number,
  'type': _$OrderTypeEnumMap[instance.type]!,
  'status': _$OrderStatusEnumMap[instance.status]!,
  'zone_id': instance.zoneId,
  'restaurant_id': instance.restaurantId,
  'parcel_type_id': instance.parcelTypeId,
  'parcel_description': instance.parcelDescription,
  'pickup_name': instance.pickupName,
  'pickup_phone': instance.pickupPhone,
  'pickup_district': instance.pickupDistrict,
  'pickup_landmark': instance.pickupLandmark,
  'pickup_instructions': instance.pickupInstructions,
  'pickup_lat': instance.pickupLat,
  'pickup_lng': instance.pickupLng,
  'dropoff_lat': instance.dropoffLat,
  'dropoff_lng': instance.dropoffLng,
  'recipient_name': instance.recipientName,
  'recipient_phone': instance.recipientPhone,
  'dropoff_district': instance.dropoffDistrict,
  'dropoff_landmark': instance.dropoffLandmark,
  'dropoff_instructions': instance.dropoffInstructions,
  'subtotal': instance.subtotal,
  'delivery_fee': instance.deliveryFee,
  'total': instance.total,
  'commission_amount': instance.commissionAmount,
  'courier_earning': instance.courierEarning,
  'platform_amount': instance.platformAmount,
  'currency': instance.currency,
  'payment_method': _$PaymentMethodEnumMap[instance.paymentMethod]!,
  'payment_status': _$OrderPaymentStatusEnumMap[instance.paymentStatus]!,
  'created_at': instance.createdAt.toIso8601String(),
  'submitted_at': instance.submittedAt?.toIso8601String(),
  'close_reason': instance.closeReason,
  'courier_id': instance.courierId,
  'courier_info': instance.courierInfo,
  'dispatch_alerted_at': instance.dispatchAlertedAt?.toIso8601String(),
  'code_locked_at': instance.codeLockedAt?.toIso8601String(),
  'problem_reported_at': instance.problemReportedAt?.toIso8601String(),
  'order_items': instance.items,
};

const _$OrderTypeEnumMap = {OrderType.food: 'food', OrderType.parcel: 'parcel'};

const _$OrderStatusEnumMap = {
  OrderStatus.awaitingPayment: 'awaiting_payment',
  OrderStatus.pending: 'pending',
  OrderStatus.accepted: 'accepted',
  OrderStatus.preparing: 'preparing',
  OrderStatus.ready: 'ready',
  OrderStatus.searchingCourier: 'searching_courier',
  OrderStatus.courierAssigned: 'courier_assigned',
  OrderStatus.pickedUp: 'picked_up',
  OrderStatus.inTransit: 'in_transit',
  OrderStatus.delivered: 'delivered',
  OrderStatus.rejected: 'rejected',
  OrderStatus.cancelled: 'cancelled',
  OrderStatus.failed: 'failed',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.mobileMoney: 'mobile_money',
  PaymentMethod.card: 'card',
};

const _$OrderPaymentStatusEnumMap = {
  OrderPaymentStatus.unpaid: 'unpaid',
  OrderPaymentStatus.paid: 'paid',
  OrderPaymentStatus.refundPending: 'refund_pending',
  OrderPaymentStatus.refunded: 'refunded',
};

_OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => _OrderItem(
  orderId: json['order_id'] as String,
  productId: json['product_id'] as String?,
  name: json['name'] as String,
  unitPrice: (json['unit_price'] as num).toInt(),
  quantity: (json['quantity'] as num).toInt(),
  lineTotal: (json['line_total'] as num).toInt(),
);

Map<String, dynamic> _$OrderItemToJson(_OrderItem instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'product_id': instance.productId,
      'name': instance.name,
      'unit_price': instance.unitPrice,
      'quantity': instance.quantity,
      'line_total': instance.lineTotal,
    };

_OrderEvent _$OrderEventFromJson(Map<String, dynamic> json) => _OrderEvent(
  kind: json['kind'] as String? ?? 'status_changed',
  status: $enumDecodeNullable(_$OrderStatusEnumMap, json['status']),
  actorRole: json['actor_role'] as String,
  reason: json['reason'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$OrderEventToJson(_OrderEvent instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'status': _$OrderStatusEnumMap[instance.status],
      'actor_role': instance.actorRole,
      'reason': instance.reason,
      'created_at': instance.createdAt.toIso8601String(),
    };

_FoodQuote _$FoodQuoteFromJson(Map<String, dynamic> json) => _FoodQuote(
  subtotal: (json['subtotal'] as num).toInt(),
  deliveryFee: (json['delivery_fee'] as num).toInt(),
  total: (json['total'] as num).toInt(),
  distanceM: (json['distance_m'] as num).toInt(),
  currency: json['currency'] as String? ?? 'XOF',
  issues:
      (json['issues'] as List<dynamic>?)
          ?.map((e) => QuoteIssue.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  couriersAvailable: json['couriers_available'] as bool? ?? true,
);

Map<String, dynamic> _$FoodQuoteToJson(_FoodQuote instance) =>
    <String, dynamic>{
      'subtotal': instance.subtotal,
      'delivery_fee': instance.deliveryFee,
      'total': instance.total,
      'distance_m': instance.distanceM,
      'currency': instance.currency,
      'issues': instance.issues,
      'couriers_available': instance.couriersAvailable,
    };

_QuoteIssue _$QuoteIssueFromJson(Map<String, dynamic> json) => _QuoteIssue(
  issue: json['issue'] as String,
  productId: json['product_id'] as String?,
  name: json['name'] as String?,
);

Map<String, dynamic> _$QuoteIssueToJson(_QuoteIssue instance) =>
    <String, dynamic>{
      'issue': instance.issue,
      'product_id': instance.productId,
      'name': instance.name,
    };

_ParcelType _$ParcelTypeFromJson(Map<String, dynamic> json) => _ParcelType(
  id: json['id'] as String,
  code: json['code'] as String,
  label: json['label'] as String,
  maxWeightKg: (json['max_weight_kg'] as num).toDouble(),
);

Map<String, dynamic> _$ParcelTypeToJson(_ParcelType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'label': instance.label,
      'max_weight_kg': instance.maxWeightKg,
    };

_MissionRecord _$MissionRecordFromJson(Map<String, dynamic> json) =>
    _MissionRecord(
      id: json['id'] as String,
      number: json['number'] as String,
      type: $enumDecode(_$OrderTypeEnumMap, json['type']),
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      pickupDistrict: json['pickup_district'] as String,
      dropoffDistrict: json['dropoff_district'] as String,
      courierEarning: (json['courier_earning'] as num).toInt(),
      assignedAt: json['assigned_at'] == null
          ? null
          : DateTime.parse(json['assigned_at'] as String),
      closedAt: json['closed_at'] == null
          ? null
          : DateTime.parse(json['closed_at'] as String),
    );

Map<String, dynamic> _$MissionRecordToJson(_MissionRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'type': _$OrderTypeEnumMap[instance.type]!,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'pickup_district': instance.pickupDistrict,
      'dropoff_district': instance.dropoffDistrict,
      'courier_earning': instance.courierEarning,
      'assigned_at': instance.assignedAt?.toIso8601String(),
      'closed_at': instance.closedAt?.toIso8601String(),
    };
