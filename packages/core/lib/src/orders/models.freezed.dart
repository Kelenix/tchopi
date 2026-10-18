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
mixin _$Order {

 String get id; String get number; OrderType get type; OrderStatus get status; String? get restaurantId; String? get parcelTypeId; String? get parcelDescription; String get pickupName; String? get pickupPhone; String get pickupDistrict; String get pickupLandmark; String get recipientName; String? get recipientPhone; String get dropoffDistrict; String get dropoffLandmark; String? get dropoffInstructions; int get subtotal; int get deliveryFee; int get total; int get commissionAmount; String get currency; PaymentMethod get paymentMethod; DateTime get createdAt; String? get closeReason;@JsonKey(name: 'order_items') List<OrderItem> get items;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.restaurantId, restaurantId) || other.restaurantId == restaurantId)&&(identical(other.parcelTypeId, parcelTypeId) || other.parcelTypeId == parcelTypeId)&&(identical(other.parcelDescription, parcelDescription) || other.parcelDescription == parcelDescription)&&(identical(other.pickupName, pickupName) || other.pickupName == pickupName)&&(identical(other.pickupPhone, pickupPhone) || other.pickupPhone == pickupPhone)&&(identical(other.pickupDistrict, pickupDistrict) || other.pickupDistrict == pickupDistrict)&&(identical(other.pickupLandmark, pickupLandmark) || other.pickupLandmark == pickupLandmark)&&(identical(other.recipientName, recipientName) || other.recipientName == recipientName)&&(identical(other.recipientPhone, recipientPhone) || other.recipientPhone == recipientPhone)&&(identical(other.dropoffDistrict, dropoffDistrict) || other.dropoffDistrict == dropoffDistrict)&&(identical(other.dropoffLandmark, dropoffLandmark) || other.dropoffLandmark == dropoffLandmark)&&(identical(other.dropoffInstructions, dropoffInstructions) || other.dropoffInstructions == dropoffInstructions)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.total, total) || other.total == total)&&(identical(other.commissionAmount, commissionAmount) || other.commissionAmount == commissionAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.closeReason, closeReason) || other.closeReason == closeReason)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,number,type,status,restaurantId,parcelTypeId,parcelDescription,pickupName,pickupPhone,pickupDistrict,pickupLandmark,recipientName,recipientPhone,dropoffDistrict,dropoffLandmark,dropoffInstructions,subtotal,deliveryFee,total,commissionAmount,currency,paymentMethod,createdAt,closeReason,const DeepCollectionEquality().hash(items)]);

@override
String toString() {
  return 'Order(id: $id, number: $number, type: $type, status: $status, restaurantId: $restaurantId, parcelTypeId: $parcelTypeId, parcelDescription: $parcelDescription, pickupName: $pickupName, pickupPhone: $pickupPhone, pickupDistrict: $pickupDistrict, pickupLandmark: $pickupLandmark, recipientName: $recipientName, recipientPhone: $recipientPhone, dropoffDistrict: $dropoffDistrict, dropoffLandmark: $dropoffLandmark, dropoffInstructions: $dropoffInstructions, subtotal: $subtotal, deliveryFee: $deliveryFee, total: $total, commissionAmount: $commissionAmount, currency: $currency, paymentMethod: $paymentMethod, createdAt: $createdAt, closeReason: $closeReason, items: $items)';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 String id, String number, OrderType type, OrderStatus status, String? restaurantId, String? parcelTypeId, String? parcelDescription, String pickupName, String? pickupPhone, String pickupDistrict, String pickupLandmark, String recipientName, String? recipientPhone, String dropoffDistrict, String dropoffLandmark, String? dropoffInstructions, int subtotal, int deliveryFee, int total, int commissionAmount, String currency, PaymentMethod paymentMethod, DateTime createdAt, String? closeReason,@JsonKey(name: 'order_items') List<OrderItem> items
});




}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? type = null,Object? status = null,Object? restaurantId = freezed,Object? parcelTypeId = freezed,Object? parcelDescription = freezed,Object? pickupName = null,Object? pickupPhone = freezed,Object? pickupDistrict = null,Object? pickupLandmark = null,Object? recipientName = null,Object? recipientPhone = freezed,Object? dropoffDistrict = null,Object? dropoffLandmark = null,Object? dropoffInstructions = freezed,Object? subtotal = null,Object? deliveryFee = null,Object? total = null,Object? commissionAmount = null,Object? currency = null,Object? paymentMethod = null,Object? createdAt = null,Object? closeReason = freezed,Object? items = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OrderType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,restaurantId: freezed == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as String?,parcelTypeId: freezed == parcelTypeId ? _self.parcelTypeId : parcelTypeId // ignore: cast_nullable_to_non_nullable
as String?,parcelDescription: freezed == parcelDescription ? _self.parcelDescription : parcelDescription // ignore: cast_nullable_to_non_nullable
as String?,pickupName: null == pickupName ? _self.pickupName : pickupName // ignore: cast_nullable_to_non_nullable
as String,pickupPhone: freezed == pickupPhone ? _self.pickupPhone : pickupPhone // ignore: cast_nullable_to_non_nullable
as String?,pickupDistrict: null == pickupDistrict ? _self.pickupDistrict : pickupDistrict // ignore: cast_nullable_to_non_nullable
as String,pickupLandmark: null == pickupLandmark ? _self.pickupLandmark : pickupLandmark // ignore: cast_nullable_to_non_nullable
as String,recipientName: null == recipientName ? _self.recipientName : recipientName // ignore: cast_nullable_to_non_nullable
as String,recipientPhone: freezed == recipientPhone ? _self.recipientPhone : recipientPhone // ignore: cast_nullable_to_non_nullable
as String?,dropoffDistrict: null == dropoffDistrict ? _self.dropoffDistrict : dropoffDistrict // ignore: cast_nullable_to_non_nullable
as String,dropoffLandmark: null == dropoffLandmark ? _self.dropoffLandmark : dropoffLandmark // ignore: cast_nullable_to_non_nullable
as String,dropoffInstructions: freezed == dropoffInstructions ? _self.dropoffInstructions : dropoffInstructions // ignore: cast_nullable_to_non_nullable
as String?,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as int,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,commissionAmount: null == commissionAmount ? _self.commissionAmount : commissionAmount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,closeReason: freezed == closeReason ? _self.closeReason : closeReason // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String number,  OrderType type,  OrderStatus status,  String? restaurantId,  String? parcelTypeId,  String? parcelDescription,  String pickupName,  String? pickupPhone,  String pickupDistrict,  String pickupLandmark,  String recipientName,  String? recipientPhone,  String dropoffDistrict,  String dropoffLandmark,  String? dropoffInstructions,  int subtotal,  int deliveryFee,  int total,  int commissionAmount,  String currency,  PaymentMethod paymentMethod,  DateTime createdAt,  String? closeReason, @JsonKey(name: 'order_items')  List<OrderItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.number,_that.type,_that.status,_that.restaurantId,_that.parcelTypeId,_that.parcelDescription,_that.pickupName,_that.pickupPhone,_that.pickupDistrict,_that.pickupLandmark,_that.recipientName,_that.recipientPhone,_that.dropoffDistrict,_that.dropoffLandmark,_that.dropoffInstructions,_that.subtotal,_that.deliveryFee,_that.total,_that.commissionAmount,_that.currency,_that.paymentMethod,_that.createdAt,_that.closeReason,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String number,  OrderType type,  OrderStatus status,  String? restaurantId,  String? parcelTypeId,  String? parcelDescription,  String pickupName,  String? pickupPhone,  String pickupDistrict,  String pickupLandmark,  String recipientName,  String? recipientPhone,  String dropoffDistrict,  String dropoffLandmark,  String? dropoffInstructions,  int subtotal,  int deliveryFee,  int total,  int commissionAmount,  String currency,  PaymentMethod paymentMethod,  DateTime createdAt,  String? closeReason, @JsonKey(name: 'order_items')  List<OrderItem> items)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.number,_that.type,_that.status,_that.restaurantId,_that.parcelTypeId,_that.parcelDescription,_that.pickupName,_that.pickupPhone,_that.pickupDistrict,_that.pickupLandmark,_that.recipientName,_that.recipientPhone,_that.dropoffDistrict,_that.dropoffLandmark,_that.dropoffInstructions,_that.subtotal,_that.deliveryFee,_that.total,_that.commissionAmount,_that.currency,_that.paymentMethod,_that.createdAt,_that.closeReason,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String number,  OrderType type,  OrderStatus status,  String? restaurantId,  String? parcelTypeId,  String? parcelDescription,  String pickupName,  String? pickupPhone,  String pickupDistrict,  String pickupLandmark,  String recipientName,  String? recipientPhone,  String dropoffDistrict,  String dropoffLandmark,  String? dropoffInstructions,  int subtotal,  int deliveryFee,  int total,  int commissionAmount,  String currency,  PaymentMethod paymentMethod,  DateTime createdAt,  String? closeReason, @JsonKey(name: 'order_items')  List<OrderItem> items)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.number,_that.type,_that.status,_that.restaurantId,_that.parcelTypeId,_that.parcelDescription,_that.pickupName,_that.pickupPhone,_that.pickupDistrict,_that.pickupLandmark,_that.recipientName,_that.recipientPhone,_that.dropoffDistrict,_that.dropoffLandmark,_that.dropoffInstructions,_that.subtotal,_that.deliveryFee,_that.total,_that.commissionAmount,_that.currency,_that.paymentMethod,_that.createdAt,_that.closeReason,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Order implements Order {
  const _Order({required this.id, required this.number, this.type = OrderType.food, required this.status, this.restaurantId, this.parcelTypeId, this.parcelDescription, required this.pickupName, this.pickupPhone, this.pickupDistrict = '', this.pickupLandmark = '', required this.recipientName, this.recipientPhone, required this.dropoffDistrict, required this.dropoffLandmark, this.dropoffInstructions, required this.subtotal, required this.deliveryFee, required this.total, this.commissionAmount = 0, this.currency = 'XOF', required this.paymentMethod, required this.createdAt, this.closeReason, @JsonKey(name: 'order_items') final  List<OrderItem> items = const []}): _items = items;
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

@override final  String id;
@override final  String number;
@override@JsonKey() final  OrderType type;
@override final  OrderStatus status;
@override final  String? restaurantId;
@override final  String? parcelTypeId;
@override final  String? parcelDescription;
@override final  String pickupName;
@override final  String? pickupPhone;
@override@JsonKey() final  String pickupDistrict;
@override@JsonKey() final  String pickupLandmark;
@override final  String recipientName;
@override final  String? recipientPhone;
@override final  String dropoffDistrict;
@override final  String dropoffLandmark;
@override final  String? dropoffInstructions;
@override final  int subtotal;
@override final  int deliveryFee;
@override final  int total;
@override@JsonKey() final  int commissionAmount;
@override@JsonKey() final  String currency;
@override final  PaymentMethod paymentMethod;
@override final  DateTime createdAt;
@override final  String? closeReason;
 final  List<OrderItem> _items;
@override@JsonKey(name: 'order_items') List<OrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.restaurantId, restaurantId) || other.restaurantId == restaurantId)&&(identical(other.parcelTypeId, parcelTypeId) || other.parcelTypeId == parcelTypeId)&&(identical(other.parcelDescription, parcelDescription) || other.parcelDescription == parcelDescription)&&(identical(other.pickupName, pickupName) || other.pickupName == pickupName)&&(identical(other.pickupPhone, pickupPhone) || other.pickupPhone == pickupPhone)&&(identical(other.pickupDistrict, pickupDistrict) || other.pickupDistrict == pickupDistrict)&&(identical(other.pickupLandmark, pickupLandmark) || other.pickupLandmark == pickupLandmark)&&(identical(other.recipientName, recipientName) || other.recipientName == recipientName)&&(identical(other.recipientPhone, recipientPhone) || other.recipientPhone == recipientPhone)&&(identical(other.dropoffDistrict, dropoffDistrict) || other.dropoffDistrict == dropoffDistrict)&&(identical(other.dropoffLandmark, dropoffLandmark) || other.dropoffLandmark == dropoffLandmark)&&(identical(other.dropoffInstructions, dropoffInstructions) || other.dropoffInstructions == dropoffInstructions)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.total, total) || other.total == total)&&(identical(other.commissionAmount, commissionAmount) || other.commissionAmount == commissionAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.closeReason, closeReason) || other.closeReason == closeReason)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,number,type,status,restaurantId,parcelTypeId,parcelDescription,pickupName,pickupPhone,pickupDistrict,pickupLandmark,recipientName,recipientPhone,dropoffDistrict,dropoffLandmark,dropoffInstructions,subtotal,deliveryFee,total,commissionAmount,currency,paymentMethod,createdAt,closeReason,const DeepCollectionEquality().hash(_items)]);

@override
String toString() {
  return 'Order(id: $id, number: $number, type: $type, status: $status, restaurantId: $restaurantId, parcelTypeId: $parcelTypeId, parcelDescription: $parcelDescription, pickupName: $pickupName, pickupPhone: $pickupPhone, pickupDistrict: $pickupDistrict, pickupLandmark: $pickupLandmark, recipientName: $recipientName, recipientPhone: $recipientPhone, dropoffDistrict: $dropoffDistrict, dropoffLandmark: $dropoffLandmark, dropoffInstructions: $dropoffInstructions, subtotal: $subtotal, deliveryFee: $deliveryFee, total: $total, commissionAmount: $commissionAmount, currency: $currency, paymentMethod: $paymentMethod, createdAt: $createdAt, closeReason: $closeReason, items: $items)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 String id, String number, OrderType type, OrderStatus status, String? restaurantId, String? parcelTypeId, String? parcelDescription, String pickupName, String? pickupPhone, String pickupDistrict, String pickupLandmark, String recipientName, String? recipientPhone, String dropoffDistrict, String dropoffLandmark, String? dropoffInstructions, int subtotal, int deliveryFee, int total, int commissionAmount, String currency, PaymentMethod paymentMethod, DateTime createdAt, String? closeReason,@JsonKey(name: 'order_items') List<OrderItem> items
});




}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? type = null,Object? status = null,Object? restaurantId = freezed,Object? parcelTypeId = freezed,Object? parcelDescription = freezed,Object? pickupName = null,Object? pickupPhone = freezed,Object? pickupDistrict = null,Object? pickupLandmark = null,Object? recipientName = null,Object? recipientPhone = freezed,Object? dropoffDistrict = null,Object? dropoffLandmark = null,Object? dropoffInstructions = freezed,Object? subtotal = null,Object? deliveryFee = null,Object? total = null,Object? commissionAmount = null,Object? currency = null,Object? paymentMethod = null,Object? createdAt = null,Object? closeReason = freezed,Object? items = null,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OrderType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,restaurantId: freezed == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as String?,parcelTypeId: freezed == parcelTypeId ? _self.parcelTypeId : parcelTypeId // ignore: cast_nullable_to_non_nullable
as String?,parcelDescription: freezed == parcelDescription ? _self.parcelDescription : parcelDescription // ignore: cast_nullable_to_non_nullable
as String?,pickupName: null == pickupName ? _self.pickupName : pickupName // ignore: cast_nullable_to_non_nullable
as String,pickupPhone: freezed == pickupPhone ? _self.pickupPhone : pickupPhone // ignore: cast_nullable_to_non_nullable
as String?,pickupDistrict: null == pickupDistrict ? _self.pickupDistrict : pickupDistrict // ignore: cast_nullable_to_non_nullable
as String,pickupLandmark: null == pickupLandmark ? _self.pickupLandmark : pickupLandmark // ignore: cast_nullable_to_non_nullable
as String,recipientName: null == recipientName ? _self.recipientName : recipientName // ignore: cast_nullable_to_non_nullable
as String,recipientPhone: freezed == recipientPhone ? _self.recipientPhone : recipientPhone // ignore: cast_nullable_to_non_nullable
as String?,dropoffDistrict: null == dropoffDistrict ? _self.dropoffDistrict : dropoffDistrict // ignore: cast_nullable_to_non_nullable
as String,dropoffLandmark: null == dropoffLandmark ? _self.dropoffLandmark : dropoffLandmark // ignore: cast_nullable_to_non_nullable
as String,dropoffInstructions: freezed == dropoffInstructions ? _self.dropoffInstructions : dropoffInstructions // ignore: cast_nullable_to_non_nullable
as String?,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as int,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,commissionAmount: null == commissionAmount ? _self.commissionAmount : commissionAmount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,closeReason: freezed == closeReason ? _self.closeReason : closeReason // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,
  ));
}


}


/// @nodoc
mixin _$OrderItem {

 String get orderId; String get name; int get unitPrice; int get quantity; int get lineTotal;
/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderItemCopyWith<OrderItem> get copyWith => _$OrderItemCopyWithImpl<OrderItem>(this as OrderItem, _$identity);

  /// Serializes this OrderItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderItem&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.lineTotal, lineTotal) || other.lineTotal == lineTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderId,name,unitPrice,quantity,lineTotal);

@override
String toString() {
  return 'OrderItem(orderId: $orderId, name: $name, unitPrice: $unitPrice, quantity: $quantity, lineTotal: $lineTotal)';
}


}

/// @nodoc
abstract mixin class $OrderItemCopyWith<$Res>  {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) _then) = _$OrderItemCopyWithImpl;
@useResult
$Res call({
 String orderId, String name, int unitPrice, int quantity, int lineTotal
});




}
/// @nodoc
class _$OrderItemCopyWithImpl<$Res>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._self, this._then);

  final OrderItem _self;
  final $Res Function(OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderId = null,Object? name = null,Object? unitPrice = null,Object? quantity = null,Object? lineTotal = null,}) {
  return _then(_self.copyWith(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderItem].
extension OrderItemPatterns on OrderItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderItem value)  $default,){
final _that = this;
switch (_that) {
case _OrderItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String orderId,  String name,  int unitPrice,  int quantity,  int lineTotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.orderId,_that.name,_that.unitPrice,_that.quantity,_that.lineTotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String orderId,  String name,  int unitPrice,  int quantity,  int lineTotal)  $default,) {final _that = this;
switch (_that) {
case _OrderItem():
return $default(_that.orderId,_that.name,_that.unitPrice,_that.quantity,_that.lineTotal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String orderId,  String name,  int unitPrice,  int quantity,  int lineTotal)?  $default,) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.orderId,_that.name,_that.unitPrice,_that.quantity,_that.lineTotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderItem implements OrderItem {
  const _OrderItem({required this.orderId, required this.name, required this.unitPrice, required this.quantity, required this.lineTotal});
  factory _OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);

@override final  String orderId;
@override final  String name;
@override final  int unitPrice;
@override final  int quantity;
@override final  int lineTotal;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderItemCopyWith<_OrderItem> get copyWith => __$OrderItemCopyWithImpl<_OrderItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderItem&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.lineTotal, lineTotal) || other.lineTotal == lineTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderId,name,unitPrice,quantity,lineTotal);

@override
String toString() {
  return 'OrderItem(orderId: $orderId, name: $name, unitPrice: $unitPrice, quantity: $quantity, lineTotal: $lineTotal)';
}


}

/// @nodoc
abstract mixin class _$OrderItemCopyWith<$Res> implements $OrderItemCopyWith<$Res> {
  factory _$OrderItemCopyWith(_OrderItem value, $Res Function(_OrderItem) _then) = __$OrderItemCopyWithImpl;
@override @useResult
$Res call({
 String orderId, String name, int unitPrice, int quantity, int lineTotal
});




}
/// @nodoc
class __$OrderItemCopyWithImpl<$Res>
    implements _$OrderItemCopyWith<$Res> {
  __$OrderItemCopyWithImpl(this._self, this._then);

  final _OrderItem _self;
  final $Res Function(_OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderId = null,Object? name = null,Object? unitPrice = null,Object? quantity = null,Object? lineTotal = null,}) {
  return _then(_OrderItem(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$OrderEvent {

 OrderStatus? get status; String get actorRole; String? get reason; DateTime get createdAt;
/// Create a copy of OrderEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderEventCopyWith<OrderEvent> get copyWith => _$OrderEventCopyWithImpl<OrderEvent>(this as OrderEvent, _$identity);

  /// Serializes this OrderEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderEvent&&(identical(other.status, status) || other.status == status)&&(identical(other.actorRole, actorRole) || other.actorRole == actorRole)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,actorRole,reason,createdAt);

@override
String toString() {
  return 'OrderEvent(status: $status, actorRole: $actorRole, reason: $reason, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $OrderEventCopyWith<$Res>  {
  factory $OrderEventCopyWith(OrderEvent value, $Res Function(OrderEvent) _then) = _$OrderEventCopyWithImpl;
@useResult
$Res call({
 OrderStatus? status, String actorRole, String? reason, DateTime createdAt
});




}
/// @nodoc
class _$OrderEventCopyWithImpl<$Res>
    implements $OrderEventCopyWith<$Res> {
  _$OrderEventCopyWithImpl(this._self, this._then);

  final OrderEvent _self;
  final $Res Function(OrderEvent) _then;

/// Create a copy of OrderEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = freezed,Object? actorRole = null,Object? reason = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus?,actorRole: null == actorRole ? _self.actorRole : actorRole // ignore: cast_nullable_to_non_nullable
as String,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderEvent].
extension OrderEventPatterns on OrderEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderEvent value)  $default,){
final _that = this;
switch (_that) {
case _OrderEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderEvent value)?  $default,){
final _that = this;
switch (_that) {
case _OrderEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OrderStatus? status,  String actorRole,  String? reason,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderEvent() when $default != null:
return $default(_that.status,_that.actorRole,_that.reason,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OrderStatus? status,  String actorRole,  String? reason,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _OrderEvent():
return $default(_that.status,_that.actorRole,_that.reason,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OrderStatus? status,  String actorRole,  String? reason,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _OrderEvent() when $default != null:
return $default(_that.status,_that.actorRole,_that.reason,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderEvent implements OrderEvent {
  const _OrderEvent({this.status, required this.actorRole, this.reason, required this.createdAt});
  factory _OrderEvent.fromJson(Map<String, dynamic> json) => _$OrderEventFromJson(json);

@override final  OrderStatus? status;
@override final  String actorRole;
@override final  String? reason;
@override final  DateTime createdAt;

/// Create a copy of OrderEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderEventCopyWith<_OrderEvent> get copyWith => __$OrderEventCopyWithImpl<_OrderEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderEvent&&(identical(other.status, status) || other.status == status)&&(identical(other.actorRole, actorRole) || other.actorRole == actorRole)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,actorRole,reason,createdAt);

@override
String toString() {
  return 'OrderEvent(status: $status, actorRole: $actorRole, reason: $reason, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$OrderEventCopyWith<$Res> implements $OrderEventCopyWith<$Res> {
  factory _$OrderEventCopyWith(_OrderEvent value, $Res Function(_OrderEvent) _then) = __$OrderEventCopyWithImpl;
@override @useResult
$Res call({
 OrderStatus? status, String actorRole, String? reason, DateTime createdAt
});




}
/// @nodoc
class __$OrderEventCopyWithImpl<$Res>
    implements _$OrderEventCopyWith<$Res> {
  __$OrderEventCopyWithImpl(this._self, this._then);

  final _OrderEvent _self;
  final $Res Function(_OrderEvent) _then;

/// Create a copy of OrderEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = freezed,Object? actorRole = null,Object? reason = freezed,Object? createdAt = null,}) {
  return _then(_OrderEvent(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus?,actorRole: null == actorRole ? _self.actorRole : actorRole // ignore: cast_nullable_to_non_nullable
as String,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$FoodQuote {

 int get subtotal; int get deliveryFee; int get total; int get distanceM; String get currency; List<QuoteIssue> get issues;
/// Create a copy of FoodQuote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoodQuoteCopyWith<FoodQuote> get copyWith => _$FoodQuoteCopyWithImpl<FoodQuote>(this as FoodQuote, _$identity);

  /// Serializes this FoodQuote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoodQuote&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.total, total) || other.total == total)&&(identical(other.distanceM, distanceM) || other.distanceM == distanceM)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other.issues, issues));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subtotal,deliveryFee,total,distanceM,currency,const DeepCollectionEquality().hash(issues));

@override
String toString() {
  return 'FoodQuote(subtotal: $subtotal, deliveryFee: $deliveryFee, total: $total, distanceM: $distanceM, currency: $currency, issues: $issues)';
}


}

/// @nodoc
abstract mixin class $FoodQuoteCopyWith<$Res>  {
  factory $FoodQuoteCopyWith(FoodQuote value, $Res Function(FoodQuote) _then) = _$FoodQuoteCopyWithImpl;
@useResult
$Res call({
 int subtotal, int deliveryFee, int total, int distanceM, String currency, List<QuoteIssue> issues
});




}
/// @nodoc
class _$FoodQuoteCopyWithImpl<$Res>
    implements $FoodQuoteCopyWith<$Res> {
  _$FoodQuoteCopyWithImpl(this._self, this._then);

  final FoodQuote _self;
  final $Res Function(FoodQuote) _then;

/// Create a copy of FoodQuote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? subtotal = null,Object? deliveryFee = null,Object? total = null,Object? distanceM = null,Object? currency = null,Object? issues = null,}) {
  return _then(_self.copyWith(
subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as int,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,distanceM: null == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,issues: null == issues ? _self.issues : issues // ignore: cast_nullable_to_non_nullable
as List<QuoteIssue>,
  ));
}

}


/// Adds pattern-matching-related methods to [FoodQuote].
extension FoodQuotePatterns on FoodQuote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FoodQuote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FoodQuote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FoodQuote value)  $default,){
final _that = this;
switch (_that) {
case _FoodQuote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FoodQuote value)?  $default,){
final _that = this;
switch (_that) {
case _FoodQuote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int subtotal,  int deliveryFee,  int total,  int distanceM,  String currency,  List<QuoteIssue> issues)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FoodQuote() when $default != null:
return $default(_that.subtotal,_that.deliveryFee,_that.total,_that.distanceM,_that.currency,_that.issues);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int subtotal,  int deliveryFee,  int total,  int distanceM,  String currency,  List<QuoteIssue> issues)  $default,) {final _that = this;
switch (_that) {
case _FoodQuote():
return $default(_that.subtotal,_that.deliveryFee,_that.total,_that.distanceM,_that.currency,_that.issues);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int subtotal,  int deliveryFee,  int total,  int distanceM,  String currency,  List<QuoteIssue> issues)?  $default,) {final _that = this;
switch (_that) {
case _FoodQuote() when $default != null:
return $default(_that.subtotal,_that.deliveryFee,_that.total,_that.distanceM,_that.currency,_that.issues);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FoodQuote implements FoodQuote {
  const _FoodQuote({required this.subtotal, required this.deliveryFee, required this.total, required this.distanceM, this.currency = 'XOF', final  List<QuoteIssue> issues = const []}): _issues = issues;
  factory _FoodQuote.fromJson(Map<String, dynamic> json) => _$FoodQuoteFromJson(json);

@override final  int subtotal;
@override final  int deliveryFee;
@override final  int total;
@override final  int distanceM;
@override@JsonKey() final  String currency;
 final  List<QuoteIssue> _issues;
@override@JsonKey() List<QuoteIssue> get issues {
  if (_issues is EqualUnmodifiableListView) return _issues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_issues);
}


/// Create a copy of FoodQuote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoodQuoteCopyWith<_FoodQuote> get copyWith => __$FoodQuoteCopyWithImpl<_FoodQuote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FoodQuoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FoodQuote&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.total, total) || other.total == total)&&(identical(other.distanceM, distanceM) || other.distanceM == distanceM)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other._issues, _issues));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subtotal,deliveryFee,total,distanceM,currency,const DeepCollectionEquality().hash(_issues));

@override
String toString() {
  return 'FoodQuote(subtotal: $subtotal, deliveryFee: $deliveryFee, total: $total, distanceM: $distanceM, currency: $currency, issues: $issues)';
}


}

/// @nodoc
abstract mixin class _$FoodQuoteCopyWith<$Res> implements $FoodQuoteCopyWith<$Res> {
  factory _$FoodQuoteCopyWith(_FoodQuote value, $Res Function(_FoodQuote) _then) = __$FoodQuoteCopyWithImpl;
@override @useResult
$Res call({
 int subtotal, int deliveryFee, int total, int distanceM, String currency, List<QuoteIssue> issues
});




}
/// @nodoc
class __$FoodQuoteCopyWithImpl<$Res>
    implements _$FoodQuoteCopyWith<$Res> {
  __$FoodQuoteCopyWithImpl(this._self, this._then);

  final _FoodQuote _self;
  final $Res Function(_FoodQuote) _then;

/// Create a copy of FoodQuote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? subtotal = null,Object? deliveryFee = null,Object? total = null,Object? distanceM = null,Object? currency = null,Object? issues = null,}) {
  return _then(_FoodQuote(
subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as int,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,distanceM: null == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,issues: null == issues ? _self._issues : issues // ignore: cast_nullable_to_non_nullable
as List<QuoteIssue>,
  ));
}


}


/// @nodoc
mixin _$QuoteIssue {

 String get issue; String? get productId; String? get name;
/// Create a copy of QuoteIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuoteIssueCopyWith<QuoteIssue> get copyWith => _$QuoteIssueCopyWithImpl<QuoteIssue>(this as QuoteIssue, _$identity);

  /// Serializes this QuoteIssue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuoteIssue&&(identical(other.issue, issue) || other.issue == issue)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,issue,productId,name);

@override
String toString() {
  return 'QuoteIssue(issue: $issue, productId: $productId, name: $name)';
}


}

/// @nodoc
abstract mixin class $QuoteIssueCopyWith<$Res>  {
  factory $QuoteIssueCopyWith(QuoteIssue value, $Res Function(QuoteIssue) _then) = _$QuoteIssueCopyWithImpl;
@useResult
$Res call({
 String issue, String? productId, String? name
});




}
/// @nodoc
class _$QuoteIssueCopyWithImpl<$Res>
    implements $QuoteIssueCopyWith<$Res> {
  _$QuoteIssueCopyWithImpl(this._self, this._then);

  final QuoteIssue _self;
  final $Res Function(QuoteIssue) _then;

/// Create a copy of QuoteIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? issue = null,Object? productId = freezed,Object? name = freezed,}) {
  return _then(_self.copyWith(
issue: null == issue ? _self.issue : issue // ignore: cast_nullable_to_non_nullable
as String,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [QuoteIssue].
extension QuoteIssuePatterns on QuoteIssue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuoteIssue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuoteIssue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuoteIssue value)  $default,){
final _that = this;
switch (_that) {
case _QuoteIssue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuoteIssue value)?  $default,){
final _that = this;
switch (_that) {
case _QuoteIssue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String issue,  String? productId,  String? name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuoteIssue() when $default != null:
return $default(_that.issue,_that.productId,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String issue,  String? productId,  String? name)  $default,) {final _that = this;
switch (_that) {
case _QuoteIssue():
return $default(_that.issue,_that.productId,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String issue,  String? productId,  String? name)?  $default,) {final _that = this;
switch (_that) {
case _QuoteIssue() when $default != null:
return $default(_that.issue,_that.productId,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuoteIssue implements QuoteIssue {
  const _QuoteIssue({required this.issue, this.productId, this.name});
  factory _QuoteIssue.fromJson(Map<String, dynamic> json) => _$QuoteIssueFromJson(json);

@override final  String issue;
@override final  String? productId;
@override final  String? name;

/// Create a copy of QuoteIssue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuoteIssueCopyWith<_QuoteIssue> get copyWith => __$QuoteIssueCopyWithImpl<_QuoteIssue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuoteIssueToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuoteIssue&&(identical(other.issue, issue) || other.issue == issue)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,issue,productId,name);

@override
String toString() {
  return 'QuoteIssue(issue: $issue, productId: $productId, name: $name)';
}


}

/// @nodoc
abstract mixin class _$QuoteIssueCopyWith<$Res> implements $QuoteIssueCopyWith<$Res> {
  factory _$QuoteIssueCopyWith(_QuoteIssue value, $Res Function(_QuoteIssue) _then) = __$QuoteIssueCopyWithImpl;
@override @useResult
$Res call({
 String issue, String? productId, String? name
});




}
/// @nodoc
class __$QuoteIssueCopyWithImpl<$Res>
    implements _$QuoteIssueCopyWith<$Res> {
  __$QuoteIssueCopyWithImpl(this._self, this._then);

  final _QuoteIssue _self;
  final $Res Function(_QuoteIssue) _then;

/// Create a copy of QuoteIssue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? issue = null,Object? productId = freezed,Object? name = freezed,}) {
  return _then(_QuoteIssue(
issue: null == issue ? _self.issue : issue // ignore: cast_nullable_to_non_nullable
as String,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ParcelType {

 String get id; String get code; String get label; double get maxWeightKg;
/// Create a copy of ParcelType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParcelTypeCopyWith<ParcelType> get copyWith => _$ParcelTypeCopyWithImpl<ParcelType>(this as ParcelType, _$identity);

  /// Serializes this ParcelType to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParcelType&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.label, label) || other.label == label)&&(identical(other.maxWeightKg, maxWeightKg) || other.maxWeightKg == maxWeightKg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,label,maxWeightKg);

@override
String toString() {
  return 'ParcelType(id: $id, code: $code, label: $label, maxWeightKg: $maxWeightKg)';
}


}

/// @nodoc
abstract mixin class $ParcelTypeCopyWith<$Res>  {
  factory $ParcelTypeCopyWith(ParcelType value, $Res Function(ParcelType) _then) = _$ParcelTypeCopyWithImpl;
@useResult
$Res call({
 String id, String code, String label, double maxWeightKg
});




}
/// @nodoc
class _$ParcelTypeCopyWithImpl<$Res>
    implements $ParcelTypeCopyWith<$Res> {
  _$ParcelTypeCopyWithImpl(this._self, this._then);

  final ParcelType _self;
  final $Res Function(ParcelType) _then;

/// Create a copy of ParcelType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? label = null,Object? maxWeightKg = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,maxWeightKg: null == maxWeightKg ? _self.maxWeightKg : maxWeightKg // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ParcelType].
extension ParcelTypePatterns on ParcelType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParcelType value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParcelType() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParcelType value)  $default,){
final _that = this;
switch (_that) {
case _ParcelType():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParcelType value)?  $default,){
final _that = this;
switch (_that) {
case _ParcelType() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code,  String label,  double maxWeightKg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParcelType() when $default != null:
return $default(_that.id,_that.code,_that.label,_that.maxWeightKg);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code,  String label,  double maxWeightKg)  $default,) {final _that = this;
switch (_that) {
case _ParcelType():
return $default(_that.id,_that.code,_that.label,_that.maxWeightKg);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code,  String label,  double maxWeightKg)?  $default,) {final _that = this;
switch (_that) {
case _ParcelType() when $default != null:
return $default(_that.id,_that.code,_that.label,_that.maxWeightKg);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParcelType implements ParcelType {
  const _ParcelType({required this.id, required this.code, required this.label, required this.maxWeightKg});
  factory _ParcelType.fromJson(Map<String, dynamic> json) => _$ParcelTypeFromJson(json);

@override final  String id;
@override final  String code;
@override final  String label;
@override final  double maxWeightKg;

/// Create a copy of ParcelType
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParcelTypeCopyWith<_ParcelType> get copyWith => __$ParcelTypeCopyWithImpl<_ParcelType>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParcelTypeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParcelType&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.label, label) || other.label == label)&&(identical(other.maxWeightKg, maxWeightKg) || other.maxWeightKg == maxWeightKg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,label,maxWeightKg);

@override
String toString() {
  return 'ParcelType(id: $id, code: $code, label: $label, maxWeightKg: $maxWeightKg)';
}


}

/// @nodoc
abstract mixin class _$ParcelTypeCopyWith<$Res> implements $ParcelTypeCopyWith<$Res> {
  factory _$ParcelTypeCopyWith(_ParcelType value, $Res Function(_ParcelType) _then) = __$ParcelTypeCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, String label, double maxWeightKg
});




}
/// @nodoc
class __$ParcelTypeCopyWithImpl<$Res>
    implements _$ParcelTypeCopyWith<$Res> {
  __$ParcelTypeCopyWithImpl(this._self, this._then);

  final _ParcelType _self;
  final $Res Function(_ParcelType) _then;

/// Create a copy of ParcelType
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? label = null,Object? maxWeightKg = null,}) {
  return _then(_ParcelType(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,maxWeightKg: null == maxWeightKg ? _self.maxWeightKg : maxWeightKg // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$ParcelPoint {

 double get lat; double get lng; String get district; String get landmark; String? get instructions;
/// Create a copy of ParcelPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParcelPointCopyWith<ParcelPoint> get copyWith => _$ParcelPointCopyWithImpl<ParcelPoint>(this as ParcelPoint, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParcelPoint&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.district, district) || other.district == district)&&(identical(other.landmark, landmark) || other.landmark == landmark)&&(identical(other.instructions, instructions) || other.instructions == instructions));
}


@override
int get hashCode => Object.hash(runtimeType,lat,lng,district,landmark,instructions);

@override
String toString() {
  return 'ParcelPoint(lat: $lat, lng: $lng, district: $district, landmark: $landmark, instructions: $instructions)';
}


}

/// @nodoc
abstract mixin class $ParcelPointCopyWith<$Res>  {
  factory $ParcelPointCopyWith(ParcelPoint value, $Res Function(ParcelPoint) _then) = _$ParcelPointCopyWithImpl;
@useResult
$Res call({
 double lat, double lng, String district, String landmark, String? instructions
});




}
/// @nodoc
class _$ParcelPointCopyWithImpl<$Res>
    implements $ParcelPointCopyWith<$Res> {
  _$ParcelPointCopyWithImpl(this._self, this._then);

  final ParcelPoint _self;
  final $Res Function(ParcelPoint) _then;

/// Create a copy of ParcelPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lat = null,Object? lng = null,Object? district = null,Object? landmark = null,Object? instructions = freezed,}) {
  return _then(_self.copyWith(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,landmark: null == landmark ? _self.landmark : landmark // ignore: cast_nullable_to_non_nullable
as String,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ParcelPoint].
extension ParcelPointPatterns on ParcelPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParcelPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParcelPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParcelPoint value)  $default,){
final _that = this;
switch (_that) {
case _ParcelPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParcelPoint value)?  $default,){
final _that = this;
switch (_that) {
case _ParcelPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double lat,  double lng,  String district,  String landmark,  String? instructions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParcelPoint() when $default != null:
return $default(_that.lat,_that.lng,_that.district,_that.landmark,_that.instructions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double lat,  double lng,  String district,  String landmark,  String? instructions)  $default,) {final _that = this;
switch (_that) {
case _ParcelPoint():
return $default(_that.lat,_that.lng,_that.district,_that.landmark,_that.instructions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double lat,  double lng,  String district,  String landmark,  String? instructions)?  $default,) {final _that = this;
switch (_that) {
case _ParcelPoint() when $default != null:
return $default(_that.lat,_that.lng,_that.district,_that.landmark,_that.instructions);case _:
  return null;

}
}

}

/// @nodoc


class _ParcelPoint extends ParcelPoint {
  const _ParcelPoint({required this.lat, required this.lng, required this.district, required this.landmark, this.instructions}): super._();
  

@override final  double lat;
@override final  double lng;
@override final  String district;
@override final  String landmark;
@override final  String? instructions;

/// Create a copy of ParcelPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParcelPointCopyWith<_ParcelPoint> get copyWith => __$ParcelPointCopyWithImpl<_ParcelPoint>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParcelPoint&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.district, district) || other.district == district)&&(identical(other.landmark, landmark) || other.landmark == landmark)&&(identical(other.instructions, instructions) || other.instructions == instructions));
}


@override
int get hashCode => Object.hash(runtimeType,lat,lng,district,landmark,instructions);

@override
String toString() {
  return 'ParcelPoint(lat: $lat, lng: $lng, district: $district, landmark: $landmark, instructions: $instructions)';
}


}

/// @nodoc
abstract mixin class _$ParcelPointCopyWith<$Res> implements $ParcelPointCopyWith<$Res> {
  factory _$ParcelPointCopyWith(_ParcelPoint value, $Res Function(_ParcelPoint) _then) = __$ParcelPointCopyWithImpl;
@override @useResult
$Res call({
 double lat, double lng, String district, String landmark, String? instructions
});




}
/// @nodoc
class __$ParcelPointCopyWithImpl<$Res>
    implements _$ParcelPointCopyWith<$Res> {
  __$ParcelPointCopyWithImpl(this._self, this._then);

  final _ParcelPoint _self;
  final $Res Function(_ParcelPoint) _then;

/// Create a copy of ParcelPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lat = null,Object? lng = null,Object? district = null,Object? landmark = null,Object? instructions = freezed,}) {
  return _then(_ParcelPoint(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,landmark: null == landmark ? _self.landmark : landmark // ignore: cast_nullable_to_non_nullable
as String,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
