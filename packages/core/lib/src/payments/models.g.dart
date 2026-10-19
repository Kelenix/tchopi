// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentOption _$PaymentOptionFromJson(Map<String, dynamic> json) =>
    _PaymentOption(
      id: json['id'] as String,
      countryCode: json['country_code'] as String,
      method: $enumDecode(_$PaymentMethodEnumMap, json['method']),
      operator: json['operator'] as String?,
      provider: json['provider'] as String?,
      label: json['label'] as String,
      isEnabled: json['is_enabled'] as bool,
      position: (json['position'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PaymentOptionToJson(_PaymentOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'country_code': instance.countryCode,
      'method': _$PaymentMethodEnumMap[instance.method]!,
      'operator': instance.operator,
      'provider': instance.provider,
      'label': instance.label,
      'is_enabled': instance.isEnabled,
      'position': instance.position,
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.mobileMoney: 'mobile_money',
  PaymentMethod.card: 'card',
};

_PaymentTransaction _$PaymentTransactionFromJson(Map<String, dynamic> json) =>
    _PaymentTransaction(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      amount: (json['amount'] as num).toInt(),
      currency: json['currency'] as String? ?? 'XOF',
      method: $enumDecode(_$PaymentMethodEnumMap, json['method']),
      operator: json['operator'] as String?,
      status: $enumDecode(_$TransactionStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['created_at'] as String),
      succeededAt: json['succeeded_at'] == null
          ? null
          : DateTime.parse(json['succeeded_at'] as String),
      orderNumber: _orderField(json, 'order_number') as String?,
      orderStatus: $enumDecodeNullable(
        _$OrderStatusEnumMap,
        _orderField(json, 'order_status'),
      ),
      orderZoneId: _orderField(json, 'order_zone_id') as String?,
      orderPaymentStatus: $enumDecodeNullable(
        _$OrderPaymentStatusEnumMap,
        _orderField(json, 'order_payment_status'),
      ),
      providerReference: json['provider_reference'] as String?,
      refundReference: json['refund_reference'] as String?,
      failureReason: json['failure_reason'] as String?,
      checkoutUrl: json['checkout_url'] as String?,
    );

Map<String, dynamic> _$PaymentTransactionToJson(_PaymentTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'amount': instance.amount,
      'currency': instance.currency,
      'method': _$PaymentMethodEnumMap[instance.method]!,
      'operator': instance.operator,
      'status': _$TransactionStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt.toIso8601String(),
      'succeeded_at': instance.succeededAt?.toIso8601String(),
      'order_number': instance.orderNumber,
      'order_status': _$OrderStatusEnumMap[instance.orderStatus],
      'order_zone_id': instance.orderZoneId,
      'order_payment_status':
          _$OrderPaymentStatusEnumMap[instance.orderPaymentStatus],
      'provider_reference': instance.providerReference,
      'refund_reference': instance.refundReference,
      'failure_reason': instance.failureReason,
      'checkout_url': instance.checkoutUrl,
    };

const _$TransactionStatusEnumMap = {
  TransactionStatus.pending: 'pending',
  TransactionStatus.succeeded: 'succeeded',
  TransactionStatus.failed: 'failed',
  TransactionStatus.cancelled: 'cancelled',
  TransactionStatus.refunded: 'refunded',
};

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

const _$OrderPaymentStatusEnumMap = {
  OrderPaymentStatus.unpaid: 'unpaid',
  OrderPaymentStatus.paid: 'paid',
  OrderPaymentStatus.refundPending: 'refund_pending',
  OrderPaymentStatus.refunded: 'refunded',
};

_CashBalance _$CashBalanceFromJson(Map<String, dynamic> json) => _CashBalance(
  courierId: json['courier_id'] as String,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  phone: json['phone'] as String?,
  collected: (json['collected'] as num).toInt(),
  remitted: (json['remitted'] as num).toInt(),
  due: (json['due'] as num).toInt(),
);

Map<String, dynamic> _$CashBalanceToJson(_CashBalance instance) =>
    <String, dynamic>{
      'courier_id': instance.courierId,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone': instance.phone,
      'collected': instance.collected,
      'remitted': instance.remitted,
      'due': instance.due,
    };

_CashEntry _$CashEntryFromJson(Map<String, dynamic> json) => _CashEntry(
  id: (json['id'] as num).toInt(),
  type: json['type'] as String,
  amount: (json['amount'] as num).toInt(),
  reference: json['reference'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  orderNumber: _orderField(json, 'order_number') as String?,
);

Map<String, dynamic> _$CashEntryToJson(_CashEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'reference': instance.reference,
      'created_at': instance.createdAt.toIso8601String(),
      'order_number': instance.orderNumber,
    };
