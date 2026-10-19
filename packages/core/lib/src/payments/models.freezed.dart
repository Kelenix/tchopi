// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentOption {

 String get id; String get countryCode; PaymentMethod get method; String? get operator; String? get provider; String get label; bool get isEnabled; int get position;
/// Create a copy of PaymentOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentOptionCopyWith<PaymentOption> get copyWith => _$PaymentOptionCopyWithImpl<PaymentOption>(this as PaymentOption, _$identity);

  /// Serializes this PaymentOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentOption&&(identical(other.id, id) || other.id == id)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.method, method) || other.method == method)&&(identical(other.operator, operator) || other.operator == operator)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.label, label) || other.label == label)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,countryCode,method,operator,provider,label,isEnabled,position);

@override
String toString() {
  return 'PaymentOption(id: $id, countryCode: $countryCode, method: $method, operator: $operator, provider: $provider, label: $label, isEnabled: $isEnabled, position: $position)';
}


}

/// @nodoc
abstract mixin class $PaymentOptionCopyWith<$Res>  {
  factory $PaymentOptionCopyWith(PaymentOption value, $Res Function(PaymentOption) _then) = _$PaymentOptionCopyWithImpl;
@useResult
$Res call({
 String id, String countryCode, PaymentMethod method, String? operator, String? provider, String label, bool isEnabled, int position
});




}
/// @nodoc
class _$PaymentOptionCopyWithImpl<$Res>
    implements $PaymentOptionCopyWith<$Res> {
  _$PaymentOptionCopyWithImpl(this._self, this._then);

  final PaymentOption _self;
  final $Res Function(PaymentOption) _then;

/// Create a copy of PaymentOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? countryCode = null,Object? method = null,Object? operator = freezed,Object? provider = freezed,Object? label = null,Object? isEnabled = null,Object? position = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,operator: freezed == operator ? _self.operator : operator // ignore: cast_nullable_to_non_nullable
as String?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentOption].
extension PaymentOptionPatterns on PaymentOption {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentOption() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentOption value)  $default,){
final _that = this;
switch (_that) {
case _PaymentOption():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentOption value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentOption() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String countryCode,  PaymentMethod method,  String? operator,  String? provider,  String label,  bool isEnabled,  int position)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentOption() when $default != null:
return $default(_that.id,_that.countryCode,_that.method,_that.operator,_that.provider,_that.label,_that.isEnabled,_that.position);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String countryCode,  PaymentMethod method,  String? operator,  String? provider,  String label,  bool isEnabled,  int position)  $default,) {final _that = this;
switch (_that) {
case _PaymentOption():
return $default(_that.id,_that.countryCode,_that.method,_that.operator,_that.provider,_that.label,_that.isEnabled,_that.position);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String countryCode,  PaymentMethod method,  String? operator,  String? provider,  String label,  bool isEnabled,  int position)?  $default,) {final _that = this;
switch (_that) {
case _PaymentOption() when $default != null:
return $default(_that.id,_that.countryCode,_that.method,_that.operator,_that.provider,_that.label,_that.isEnabled,_that.position);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentOption implements PaymentOption {
  const _PaymentOption({required this.id, required this.countryCode, required this.method, this.operator, this.provider, required this.label, required this.isEnabled, this.position = 0});
  factory _PaymentOption.fromJson(Map<String, dynamic> json) => _$PaymentOptionFromJson(json);

@override final  String id;
@override final  String countryCode;
@override final  PaymentMethod method;
@override final  String? operator;
@override final  String? provider;
@override final  String label;
@override final  bool isEnabled;
@override@JsonKey() final  int position;

/// Create a copy of PaymentOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentOptionCopyWith<_PaymentOption> get copyWith => __$PaymentOptionCopyWithImpl<_PaymentOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentOption&&(identical(other.id, id) || other.id == id)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.method, method) || other.method == method)&&(identical(other.operator, operator) || other.operator == operator)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.label, label) || other.label == label)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,countryCode,method,operator,provider,label,isEnabled,position);

@override
String toString() {
  return 'PaymentOption(id: $id, countryCode: $countryCode, method: $method, operator: $operator, provider: $provider, label: $label, isEnabled: $isEnabled, position: $position)';
}


}

/// @nodoc
abstract mixin class _$PaymentOptionCopyWith<$Res> implements $PaymentOptionCopyWith<$Res> {
  factory _$PaymentOptionCopyWith(_PaymentOption value, $Res Function(_PaymentOption) _then) = __$PaymentOptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String countryCode, PaymentMethod method, String? operator, String? provider, String label, bool isEnabled, int position
});




}
/// @nodoc
class __$PaymentOptionCopyWithImpl<$Res>
    implements _$PaymentOptionCopyWith<$Res> {
  __$PaymentOptionCopyWithImpl(this._self, this._then);

  final _PaymentOption _self;
  final $Res Function(_PaymentOption) _then;

/// Create a copy of PaymentOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? countryCode = null,Object? method = null,Object? operator = freezed,Object? provider = freezed,Object? label = null,Object? isEnabled = null,Object? position = null,}) {
  return _then(_PaymentOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,operator: freezed == operator ? _self.operator : operator // ignore: cast_nullable_to_non_nullable
as String?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String?,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PaymentTransaction {

 String get id; String get orderId; int get amount; String get currency; PaymentMethod get method; String? get operator; TransactionStatus get status; DateTime get createdAt; DateTime? get succeededAt;@JsonKey(readValue: _orderField) String? get orderNumber;@JsonKey(readValue: _orderField) OrderStatus? get orderStatus;@JsonKey(readValue: _orderField) String? get orderZoneId;@JsonKey(readValue: _orderField) OrderPaymentStatus? get orderPaymentStatus; String? get providerReference; String? get refundReference;/// Mobile Money : refus de l'opérateur (« failed ») ou session annulée (« cancelled »).
 String? get failureReason;/// Page de paiement du fournisseur (nyole, Stripe) à rouvrir pour payer ou réessayer.
 String? get checkoutUrl;
/// Create a copy of PaymentTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentTransactionCopyWith<PaymentTransaction> get copyWith => _$PaymentTransactionCopyWithImpl<PaymentTransaction>(this as PaymentTransaction, _$identity);

  /// Serializes this PaymentTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.method, method) || other.method == method)&&(identical(other.operator, operator) || other.operator == operator)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.succeededAt, succeededAt) || other.succeededAt == succeededAt)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.orderStatus, orderStatus) || other.orderStatus == orderStatus)&&(identical(other.orderZoneId, orderZoneId) || other.orderZoneId == orderZoneId)&&(identical(other.orderPaymentStatus, orderPaymentStatus) || other.orderPaymentStatus == orderPaymentStatus)&&(identical(other.providerReference, providerReference) || other.providerReference == providerReference)&&(identical(other.refundReference, refundReference) || other.refundReference == refundReference)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.checkoutUrl, checkoutUrl) || other.checkoutUrl == checkoutUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,amount,currency,method,operator,status,createdAt,succeededAt,orderNumber,orderStatus,orderZoneId,orderPaymentStatus,providerReference,refundReference,failureReason,checkoutUrl);

@override
String toString() {
  return 'PaymentTransaction(id: $id, orderId: $orderId, amount: $amount, currency: $currency, method: $method, operator: $operator, status: $status, createdAt: $createdAt, succeededAt: $succeededAt, orderNumber: $orderNumber, orderStatus: $orderStatus, orderZoneId: $orderZoneId, orderPaymentStatus: $orderPaymentStatus, providerReference: $providerReference, refundReference: $refundReference, failureReason: $failureReason, checkoutUrl: $checkoutUrl)';
}


}

/// @nodoc
abstract mixin class $PaymentTransactionCopyWith<$Res>  {
  factory $PaymentTransactionCopyWith(PaymentTransaction value, $Res Function(PaymentTransaction) _then) = _$PaymentTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String orderId, int amount, String currency, PaymentMethod method, String? operator, TransactionStatus status, DateTime createdAt, DateTime? succeededAt,@JsonKey(readValue: _orderField) String? orderNumber,@JsonKey(readValue: _orderField) OrderStatus? orderStatus,@JsonKey(readValue: _orderField) String? orderZoneId,@JsonKey(readValue: _orderField) OrderPaymentStatus? orderPaymentStatus, String? providerReference, String? refundReference, String? failureReason, String? checkoutUrl
});




}
/// @nodoc
class _$PaymentTransactionCopyWithImpl<$Res>
    implements $PaymentTransactionCopyWith<$Res> {
  _$PaymentTransactionCopyWithImpl(this._self, this._then);

  final PaymentTransaction _self;
  final $Res Function(PaymentTransaction) _then;

/// Create a copy of PaymentTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderId = null,Object? amount = null,Object? currency = null,Object? method = null,Object? operator = freezed,Object? status = null,Object? createdAt = null,Object? succeededAt = freezed,Object? orderNumber = freezed,Object? orderStatus = freezed,Object? orderZoneId = freezed,Object? orderPaymentStatus = freezed,Object? providerReference = freezed,Object? refundReference = freezed,Object? failureReason = freezed,Object? checkoutUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,operator: freezed == operator ? _self.operator : operator // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,succeededAt: freezed == succeededAt ? _self.succeededAt : succeededAt // ignore: cast_nullable_to_non_nullable
as DateTime?,orderNumber: freezed == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String?,orderStatus: freezed == orderStatus ? _self.orderStatus : orderStatus // ignore: cast_nullable_to_non_nullable
as OrderStatus?,orderZoneId: freezed == orderZoneId ? _self.orderZoneId : orderZoneId // ignore: cast_nullable_to_non_nullable
as String?,orderPaymentStatus: freezed == orderPaymentStatus ? _self.orderPaymentStatus : orderPaymentStatus // ignore: cast_nullable_to_non_nullable
as OrderPaymentStatus?,providerReference: freezed == providerReference ? _self.providerReference : providerReference // ignore: cast_nullable_to_non_nullable
as String?,refundReference: freezed == refundReference ? _self.refundReference : refundReference // ignore: cast_nullable_to_non_nullable
as String?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,checkoutUrl: freezed == checkoutUrl ? _self.checkoutUrl : checkoutUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentTransaction].
extension PaymentTransactionPatterns on PaymentTransaction {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentTransaction() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentTransaction value)  $default,){
final _that = this;
switch (_that) {
case _PaymentTransaction():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentTransaction() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orderId,  int amount,  String currency,  PaymentMethod method,  String? operator,  TransactionStatus status,  DateTime createdAt,  DateTime? succeededAt, @JsonKey(readValue: _orderField)  String? orderNumber, @JsonKey(readValue: _orderField)  OrderStatus? orderStatus, @JsonKey(readValue: _orderField)  String? orderZoneId, @JsonKey(readValue: _orderField)  OrderPaymentStatus? orderPaymentStatus,  String? providerReference,  String? refundReference,  String? failureReason,  String? checkoutUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentTransaction() when $default != null:
return $default(_that.id,_that.orderId,_that.amount,_that.currency,_that.method,_that.operator,_that.status,_that.createdAt,_that.succeededAt,_that.orderNumber,_that.orderStatus,_that.orderZoneId,_that.orderPaymentStatus,_that.providerReference,_that.refundReference,_that.failureReason,_that.checkoutUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orderId,  int amount,  String currency,  PaymentMethod method,  String? operator,  TransactionStatus status,  DateTime createdAt,  DateTime? succeededAt, @JsonKey(readValue: _orderField)  String? orderNumber, @JsonKey(readValue: _orderField)  OrderStatus? orderStatus, @JsonKey(readValue: _orderField)  String? orderZoneId, @JsonKey(readValue: _orderField)  OrderPaymentStatus? orderPaymentStatus,  String? providerReference,  String? refundReference,  String? failureReason,  String? checkoutUrl)  $default,) {final _that = this;
switch (_that) {
case _PaymentTransaction():
return $default(_that.id,_that.orderId,_that.amount,_that.currency,_that.method,_that.operator,_that.status,_that.createdAt,_that.succeededAt,_that.orderNumber,_that.orderStatus,_that.orderZoneId,_that.orderPaymentStatus,_that.providerReference,_that.refundReference,_that.failureReason,_that.checkoutUrl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orderId,  int amount,  String currency,  PaymentMethod method,  String? operator,  TransactionStatus status,  DateTime createdAt,  DateTime? succeededAt, @JsonKey(readValue: _orderField)  String? orderNumber, @JsonKey(readValue: _orderField)  OrderStatus? orderStatus, @JsonKey(readValue: _orderField)  String? orderZoneId, @JsonKey(readValue: _orderField)  OrderPaymentStatus? orderPaymentStatus,  String? providerReference,  String? refundReference,  String? failureReason,  String? checkoutUrl)?  $default,) {final _that = this;
switch (_that) {
case _PaymentTransaction() when $default != null:
return $default(_that.id,_that.orderId,_that.amount,_that.currency,_that.method,_that.operator,_that.status,_that.createdAt,_that.succeededAt,_that.orderNumber,_that.orderStatus,_that.orderZoneId,_that.orderPaymentStatus,_that.providerReference,_that.refundReference,_that.failureReason,_that.checkoutUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentTransaction implements PaymentTransaction {
  const _PaymentTransaction({required this.id, required this.orderId, required this.amount, this.currency = 'XOF', required this.method, this.operator, required this.status, required this.createdAt, this.succeededAt, @JsonKey(readValue: _orderField) this.orderNumber, @JsonKey(readValue: _orderField) this.orderStatus, @JsonKey(readValue: _orderField) this.orderZoneId, @JsonKey(readValue: _orderField) this.orderPaymentStatus, this.providerReference, this.refundReference, this.failureReason, this.checkoutUrl});
  factory _PaymentTransaction.fromJson(Map<String, dynamic> json) => _$PaymentTransactionFromJson(json);

@override final  String id;
@override final  String orderId;
@override final  int amount;
@override@JsonKey() final  String currency;
@override final  PaymentMethod method;
@override final  String? operator;
@override final  TransactionStatus status;
@override final  DateTime createdAt;
@override final  DateTime? succeededAt;
@override@JsonKey(readValue: _orderField) final  String? orderNumber;
@override@JsonKey(readValue: _orderField) final  OrderStatus? orderStatus;
@override@JsonKey(readValue: _orderField) final  String? orderZoneId;
@override@JsonKey(readValue: _orderField) final  OrderPaymentStatus? orderPaymentStatus;
@override final  String? providerReference;
@override final  String? refundReference;
/// Mobile Money : refus de l'opérateur (« failed ») ou session annulée (« cancelled »).
@override final  String? failureReason;
/// Page de paiement du fournisseur (nyole, Stripe) à rouvrir pour payer ou réessayer.
@override final  String? checkoutUrl;

/// Create a copy of PaymentTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentTransactionCopyWith<_PaymentTransaction> get copyWith => __$PaymentTransactionCopyWithImpl<_PaymentTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.method, method) || other.method == method)&&(identical(other.operator, operator) || other.operator == operator)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.succeededAt, succeededAt) || other.succeededAt == succeededAt)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.orderStatus, orderStatus) || other.orderStatus == orderStatus)&&(identical(other.orderZoneId, orderZoneId) || other.orderZoneId == orderZoneId)&&(identical(other.orderPaymentStatus, orderPaymentStatus) || other.orderPaymentStatus == orderPaymentStatus)&&(identical(other.providerReference, providerReference) || other.providerReference == providerReference)&&(identical(other.refundReference, refundReference) || other.refundReference == refundReference)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.checkoutUrl, checkoutUrl) || other.checkoutUrl == checkoutUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,amount,currency,method,operator,status,createdAt,succeededAt,orderNumber,orderStatus,orderZoneId,orderPaymentStatus,providerReference,refundReference,failureReason,checkoutUrl);

@override
String toString() {
  return 'PaymentTransaction(id: $id, orderId: $orderId, amount: $amount, currency: $currency, method: $method, operator: $operator, status: $status, createdAt: $createdAt, succeededAt: $succeededAt, orderNumber: $orderNumber, orderStatus: $orderStatus, orderZoneId: $orderZoneId, orderPaymentStatus: $orderPaymentStatus, providerReference: $providerReference, refundReference: $refundReference, failureReason: $failureReason, checkoutUrl: $checkoutUrl)';
}


}

/// @nodoc
abstract mixin class _$PaymentTransactionCopyWith<$Res> implements $PaymentTransactionCopyWith<$Res> {
  factory _$PaymentTransactionCopyWith(_PaymentTransaction value, $Res Function(_PaymentTransaction) _then) = __$PaymentTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String orderId, int amount, String currency, PaymentMethod method, String? operator, TransactionStatus status, DateTime createdAt, DateTime? succeededAt,@JsonKey(readValue: _orderField) String? orderNumber,@JsonKey(readValue: _orderField) OrderStatus? orderStatus,@JsonKey(readValue: _orderField) String? orderZoneId,@JsonKey(readValue: _orderField) OrderPaymentStatus? orderPaymentStatus, String? providerReference, String? refundReference, String? failureReason, String? checkoutUrl
});




}
/// @nodoc
class __$PaymentTransactionCopyWithImpl<$Res>
    implements _$PaymentTransactionCopyWith<$Res> {
  __$PaymentTransactionCopyWithImpl(this._self, this._then);

  final _PaymentTransaction _self;
  final $Res Function(_PaymentTransaction) _then;

/// Create a copy of PaymentTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderId = null,Object? amount = null,Object? currency = null,Object? method = null,Object? operator = freezed,Object? status = null,Object? createdAt = null,Object? succeededAt = freezed,Object? orderNumber = freezed,Object? orderStatus = freezed,Object? orderZoneId = freezed,Object? orderPaymentStatus = freezed,Object? providerReference = freezed,Object? refundReference = freezed,Object? failureReason = freezed,Object? checkoutUrl = freezed,}) {
  return _then(_PaymentTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,operator: freezed == operator ? _self.operator : operator // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,succeededAt: freezed == succeededAt ? _self.succeededAt : succeededAt // ignore: cast_nullable_to_non_nullable
as DateTime?,orderNumber: freezed == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String?,orderStatus: freezed == orderStatus ? _self.orderStatus : orderStatus // ignore: cast_nullable_to_non_nullable
as OrderStatus?,orderZoneId: freezed == orderZoneId ? _self.orderZoneId : orderZoneId // ignore: cast_nullable_to_non_nullable
as String?,orderPaymentStatus: freezed == orderPaymentStatus ? _self.orderPaymentStatus : orderPaymentStatus // ignore: cast_nullable_to_non_nullable
as OrderPaymentStatus?,providerReference: freezed == providerReference ? _self.providerReference : providerReference // ignore: cast_nullable_to_non_nullable
as String?,refundReference: freezed == refundReference ? _self.refundReference : refundReference // ignore: cast_nullable_to_non_nullable
as String?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,checkoutUrl: freezed == checkoutUrl ? _self.checkoutUrl : checkoutUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CashBalance {

 String get courierId; String? get firstName; String? get lastName; String? get phone; int get collected; int get remitted; int get due;
/// Create a copy of CashBalance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CashBalanceCopyWith<CashBalance> get copyWith => _$CashBalanceCopyWithImpl<CashBalance>(this as CashBalance, _$identity);

  /// Serializes this CashBalance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CashBalance&&(identical(other.courierId, courierId) || other.courierId == courierId)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.collected, collected) || other.collected == collected)&&(identical(other.remitted, remitted) || other.remitted == remitted)&&(identical(other.due, due) || other.due == due));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,courierId,firstName,lastName,phone,collected,remitted,due);

@override
String toString() {
  return 'CashBalance(courierId: $courierId, firstName: $firstName, lastName: $lastName, phone: $phone, collected: $collected, remitted: $remitted, due: $due)';
}


}

/// @nodoc
abstract mixin class $CashBalanceCopyWith<$Res>  {
  factory $CashBalanceCopyWith(CashBalance value, $Res Function(CashBalance) _then) = _$CashBalanceCopyWithImpl;
@useResult
$Res call({
 String courierId, String? firstName, String? lastName, String? phone, int collected, int remitted, int due
});




}
/// @nodoc
class _$CashBalanceCopyWithImpl<$Res>
    implements $CashBalanceCopyWith<$Res> {
  _$CashBalanceCopyWithImpl(this._self, this._then);

  final CashBalance _self;
  final $Res Function(CashBalance) _then;

/// Create a copy of CashBalance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? courierId = null,Object? firstName = freezed,Object? lastName = freezed,Object? phone = freezed,Object? collected = null,Object? remitted = null,Object? due = null,}) {
  return _then(_self.copyWith(
courierId: null == courierId ? _self.courierId : courierId // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,collected: null == collected ? _self.collected : collected // ignore: cast_nullable_to_non_nullable
as int,remitted: null == remitted ? _self.remitted : remitted // ignore: cast_nullable_to_non_nullable
as int,due: null == due ? _self.due : due // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CashBalance].
extension CashBalancePatterns on CashBalance {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CashBalance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CashBalance() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CashBalance value)  $default,){
final _that = this;
switch (_that) {
case _CashBalance():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CashBalance value)?  $default,){
final _that = this;
switch (_that) {
case _CashBalance() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String courierId,  String? firstName,  String? lastName,  String? phone,  int collected,  int remitted,  int due)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CashBalance() when $default != null:
return $default(_that.courierId,_that.firstName,_that.lastName,_that.phone,_that.collected,_that.remitted,_that.due);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String courierId,  String? firstName,  String? lastName,  String? phone,  int collected,  int remitted,  int due)  $default,) {final _that = this;
switch (_that) {
case _CashBalance():
return $default(_that.courierId,_that.firstName,_that.lastName,_that.phone,_that.collected,_that.remitted,_that.due);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String courierId,  String? firstName,  String? lastName,  String? phone,  int collected,  int remitted,  int due)?  $default,) {final _that = this;
switch (_that) {
case _CashBalance() when $default != null:
return $default(_that.courierId,_that.firstName,_that.lastName,_that.phone,_that.collected,_that.remitted,_that.due);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CashBalance implements CashBalance {
  const _CashBalance({required this.courierId, this.firstName, this.lastName, this.phone, required this.collected, required this.remitted, required this.due});
  factory _CashBalance.fromJson(Map<String, dynamic> json) => _$CashBalanceFromJson(json);

@override final  String courierId;
@override final  String? firstName;
@override final  String? lastName;
@override final  String? phone;
@override final  int collected;
@override final  int remitted;
@override final  int due;

/// Create a copy of CashBalance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CashBalanceCopyWith<_CashBalance> get copyWith => __$CashBalanceCopyWithImpl<_CashBalance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CashBalanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CashBalance&&(identical(other.courierId, courierId) || other.courierId == courierId)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.collected, collected) || other.collected == collected)&&(identical(other.remitted, remitted) || other.remitted == remitted)&&(identical(other.due, due) || other.due == due));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,courierId,firstName,lastName,phone,collected,remitted,due);

@override
String toString() {
  return 'CashBalance(courierId: $courierId, firstName: $firstName, lastName: $lastName, phone: $phone, collected: $collected, remitted: $remitted, due: $due)';
}


}

/// @nodoc
abstract mixin class _$CashBalanceCopyWith<$Res> implements $CashBalanceCopyWith<$Res> {
  factory _$CashBalanceCopyWith(_CashBalance value, $Res Function(_CashBalance) _then) = __$CashBalanceCopyWithImpl;
@override @useResult
$Res call({
 String courierId, String? firstName, String? lastName, String? phone, int collected, int remitted, int due
});




}
/// @nodoc
class __$CashBalanceCopyWithImpl<$Res>
    implements _$CashBalanceCopyWith<$Res> {
  __$CashBalanceCopyWithImpl(this._self, this._then);

  final _CashBalance _self;
  final $Res Function(_CashBalance) _then;

/// Create a copy of CashBalance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? courierId = null,Object? firstName = freezed,Object? lastName = freezed,Object? phone = freezed,Object? collected = null,Object? remitted = null,Object? due = null,}) {
  return _then(_CashBalance(
courierId: null == courierId ? _self.courierId : courierId // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,collected: null == collected ? _self.collected : collected // ignore: cast_nullable_to_non_nullable
as int,remitted: null == remitted ? _self.remitted : remitted // ignore: cast_nullable_to_non_nullable
as int,due: null == due ? _self.due : due // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CashEntry {

 int get id; String get type; int get amount; String? get reference; DateTime get createdAt;@JsonKey(readValue: _orderField) String? get orderNumber;
/// Create a copy of CashEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CashEntryCopyWith<CashEntry> get copyWith => _$CashEntryCopyWithImpl<CashEntry>(this as CashEntry, _$identity);

  /// Serializes this CashEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CashEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,amount,reference,createdAt,orderNumber);

@override
String toString() {
  return 'CashEntry(id: $id, type: $type, amount: $amount, reference: $reference, createdAt: $createdAt, orderNumber: $orderNumber)';
}


}

/// @nodoc
abstract mixin class $CashEntryCopyWith<$Res>  {
  factory $CashEntryCopyWith(CashEntry value, $Res Function(CashEntry) _then) = _$CashEntryCopyWithImpl;
@useResult
$Res call({
 int id, String type, int amount, String? reference, DateTime createdAt,@JsonKey(readValue: _orderField) String? orderNumber
});




}
/// @nodoc
class _$CashEntryCopyWithImpl<$Res>
    implements $CashEntryCopyWith<$Res> {
  _$CashEntryCopyWithImpl(this._self, this._then);

  final CashEntry _self;
  final $Res Function(CashEntry) _then;

/// Create a copy of CashEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? reference = freezed,Object? createdAt = null,Object? orderNumber = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,orderNumber: freezed == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CashEntry].
extension CashEntryPatterns on CashEntry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CashEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CashEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CashEntry value)  $default,){
final _that = this;
switch (_that) {
case _CashEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CashEntry value)?  $default,){
final _that = this;
switch (_that) {
case _CashEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String type,  int amount,  String? reference,  DateTime createdAt, @JsonKey(readValue: _orderField)  String? orderNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CashEntry() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.reference,_that.createdAt,_that.orderNumber);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String type,  int amount,  String? reference,  DateTime createdAt, @JsonKey(readValue: _orderField)  String? orderNumber)  $default,) {final _that = this;
switch (_that) {
case _CashEntry():
return $default(_that.id,_that.type,_that.amount,_that.reference,_that.createdAt,_that.orderNumber);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String type,  int amount,  String? reference,  DateTime createdAt, @JsonKey(readValue: _orderField)  String? orderNumber)?  $default,) {final _that = this;
switch (_that) {
case _CashEntry() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.reference,_that.createdAt,_that.orderNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CashEntry implements CashEntry {
  const _CashEntry({required this.id, required this.type, required this.amount, this.reference, required this.createdAt, @JsonKey(readValue: _orderField) this.orderNumber});
  factory _CashEntry.fromJson(Map<String, dynamic> json) => _$CashEntryFromJson(json);

@override final  int id;
@override final  String type;
@override final  int amount;
@override final  String? reference;
@override final  DateTime createdAt;
@override@JsonKey(readValue: _orderField) final  String? orderNumber;

/// Create a copy of CashEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CashEntryCopyWith<_CashEntry> get copyWith => __$CashEntryCopyWithImpl<_CashEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CashEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CashEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,amount,reference,createdAt,orderNumber);

@override
String toString() {
  return 'CashEntry(id: $id, type: $type, amount: $amount, reference: $reference, createdAt: $createdAt, orderNumber: $orderNumber)';
}


}

/// @nodoc
abstract mixin class _$CashEntryCopyWith<$Res> implements $CashEntryCopyWith<$Res> {
  factory _$CashEntryCopyWith(_CashEntry value, $Res Function(_CashEntry) _then) = __$CashEntryCopyWithImpl;
@override @useResult
$Res call({
 int id, String type, int amount, String? reference, DateTime createdAt,@JsonKey(readValue: _orderField) String? orderNumber
});




}
/// @nodoc
class __$CashEntryCopyWithImpl<$Res>
    implements _$CashEntryCopyWith<$Res> {
  __$CashEntryCopyWithImpl(this._self, this._then);

  final _CashEntry _self;
  final $Res Function(_CashEntry) _then;

/// Create a copy of CashEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? reference = freezed,Object? createdAt = null,Object? orderNumber = freezed,}) {
  return _then(_CashEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,orderNumber: freezed == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
