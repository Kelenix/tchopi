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
mixin _$Courier {

 String get userId; String get zoneId; VehicleType get vehicleType; String? get plateNumber; String get photoPath; CourierStatus get status; String? get statusReason; bool get isOnline;
/// Create a copy of Courier
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CourierCopyWith<Courier> get copyWith => _$CourierCopyWithImpl<Courier>(this as Courier, _$identity);

  /// Serializes this Courier to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Courier&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.plateNumber, plateNumber) || other.plateNumber == plateNumber)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusReason, statusReason) || other.statusReason == statusReason)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,zoneId,vehicleType,plateNumber,photoPath,status,statusReason,isOnline);

@override
String toString() {
  return 'Courier(userId: $userId, zoneId: $zoneId, vehicleType: $vehicleType, plateNumber: $plateNumber, photoPath: $photoPath, status: $status, statusReason: $statusReason, isOnline: $isOnline)';
}


}

/// @nodoc
abstract mixin class $CourierCopyWith<$Res>  {
  factory $CourierCopyWith(Courier value, $Res Function(Courier) _then) = _$CourierCopyWithImpl;
@useResult
$Res call({
 String userId, String zoneId, VehicleType vehicleType, String? plateNumber, String photoPath, CourierStatus status, String? statusReason, bool isOnline
});




}
/// @nodoc
class _$CourierCopyWithImpl<$Res>
    implements $CourierCopyWith<$Res> {
  _$CourierCopyWithImpl(this._self, this._then);

  final Courier _self;
  final $Res Function(Courier) _then;

/// Create a copy of Courier
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? zoneId = null,Object? vehicleType = null,Object? plateNumber = freezed,Object? photoPath = null,Object? status = null,Object? statusReason = freezed,Object? isOnline = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,plateNumber: freezed == plateNumber ? _self.plateNumber : plateNumber // ignore: cast_nullable_to_non_nullable
as String?,photoPath: null == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CourierStatus,statusReason: freezed == statusReason ? _self.statusReason : statusReason // ignore: cast_nullable_to_non_nullable
as String?,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Courier].
extension CourierPatterns on Courier {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Courier value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Courier() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Courier value)  $default,){
final _that = this;
switch (_that) {
case _Courier():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Courier value)?  $default,){
final _that = this;
switch (_that) {
case _Courier() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String zoneId,  VehicleType vehicleType,  String? plateNumber,  String photoPath,  CourierStatus status,  String? statusReason,  bool isOnline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Courier() when $default != null:
return $default(_that.userId,_that.zoneId,_that.vehicleType,_that.plateNumber,_that.photoPath,_that.status,_that.statusReason,_that.isOnline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String zoneId,  VehicleType vehicleType,  String? plateNumber,  String photoPath,  CourierStatus status,  String? statusReason,  bool isOnline)  $default,) {final _that = this;
switch (_that) {
case _Courier():
return $default(_that.userId,_that.zoneId,_that.vehicleType,_that.plateNumber,_that.photoPath,_that.status,_that.statusReason,_that.isOnline);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String zoneId,  VehicleType vehicleType,  String? plateNumber,  String photoPath,  CourierStatus status,  String? statusReason,  bool isOnline)?  $default,) {final _that = this;
switch (_that) {
case _Courier() when $default != null:
return $default(_that.userId,_that.zoneId,_that.vehicleType,_that.plateNumber,_that.photoPath,_that.status,_that.statusReason,_that.isOnline);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Courier implements Courier {
  const _Courier({required this.userId, required this.zoneId, required this.vehicleType, this.plateNumber, required this.photoPath, required this.status, this.statusReason, this.isOnline = false});
  factory _Courier.fromJson(Map<String, dynamic> json) => _$CourierFromJson(json);

@override final  String userId;
@override final  String zoneId;
@override final  VehicleType vehicleType;
@override final  String? plateNumber;
@override final  String photoPath;
@override final  CourierStatus status;
@override final  String? statusReason;
@override@JsonKey() final  bool isOnline;

/// Create a copy of Courier
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CourierCopyWith<_Courier> get copyWith => __$CourierCopyWithImpl<_Courier>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CourierToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Courier&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.plateNumber, plateNumber) || other.plateNumber == plateNumber)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusReason, statusReason) || other.statusReason == statusReason)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,zoneId,vehicleType,plateNumber,photoPath,status,statusReason,isOnline);

@override
String toString() {
  return 'Courier(userId: $userId, zoneId: $zoneId, vehicleType: $vehicleType, plateNumber: $plateNumber, photoPath: $photoPath, status: $status, statusReason: $statusReason, isOnline: $isOnline)';
}


}

/// @nodoc
abstract mixin class _$CourierCopyWith<$Res> implements $CourierCopyWith<$Res> {
  factory _$CourierCopyWith(_Courier value, $Res Function(_Courier) _then) = __$CourierCopyWithImpl;
@override @useResult
$Res call({
 String userId, String zoneId, VehicleType vehicleType, String? plateNumber, String photoPath, CourierStatus status, String? statusReason, bool isOnline
});




}
/// @nodoc
class __$CourierCopyWithImpl<$Res>
    implements _$CourierCopyWith<$Res> {
  __$CourierCopyWithImpl(this._self, this._then);

  final _Courier _self;
  final $Res Function(_Courier) _then;

/// Create a copy of Courier
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? zoneId = null,Object? vehicleType = null,Object? plateNumber = freezed,Object? photoPath = null,Object? status = null,Object? statusReason = freezed,Object? isOnline = null,}) {
  return _then(_Courier(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,plateNumber: freezed == plateNumber ? _self.plateNumber : plateNumber // ignore: cast_nullable_to_non_nullable
as String?,photoPath: null == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CourierStatus,statusReason: freezed == statusReason ? _self.statusReason : statusReason // ignore: cast_nullable_to_non_nullable
as String?,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$CourierInfo {

 String get firstName; String? get phone; VehicleType get vehicleType; String? get plateNumber;
/// Create a copy of CourierInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CourierInfoCopyWith<CourierInfo> get copyWith => _$CourierInfoCopyWithImpl<CourierInfo>(this as CourierInfo, _$identity);

  /// Serializes this CourierInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CourierInfo&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.plateNumber, plateNumber) || other.plateNumber == plateNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,firstName,phone,vehicleType,plateNumber);

@override
String toString() {
  return 'CourierInfo(firstName: $firstName, phone: $phone, vehicleType: $vehicleType, plateNumber: $plateNumber)';
}


}

/// @nodoc
abstract mixin class $CourierInfoCopyWith<$Res>  {
  factory $CourierInfoCopyWith(CourierInfo value, $Res Function(CourierInfo) _then) = _$CourierInfoCopyWithImpl;
@useResult
$Res call({
 String firstName, String? phone, VehicleType vehicleType, String? plateNumber
});




}
/// @nodoc
class _$CourierInfoCopyWithImpl<$Res>
    implements $CourierInfoCopyWith<$Res> {
  _$CourierInfoCopyWithImpl(this._self, this._then);

  final CourierInfo _self;
  final $Res Function(CourierInfo) _then;

/// Create a copy of CourierInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? firstName = null,Object? phone = freezed,Object? vehicleType = null,Object? plateNumber = freezed,}) {
  return _then(_self.copyWith(
firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,plateNumber: freezed == plateNumber ? _self.plateNumber : plateNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CourierInfo].
extension CourierInfoPatterns on CourierInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CourierInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CourierInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CourierInfo value)  $default,){
final _that = this;
switch (_that) {
case _CourierInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CourierInfo value)?  $default,){
final _that = this;
switch (_that) {
case _CourierInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String firstName,  String? phone,  VehicleType vehicleType,  String? plateNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CourierInfo() when $default != null:
return $default(_that.firstName,_that.phone,_that.vehicleType,_that.plateNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String firstName,  String? phone,  VehicleType vehicleType,  String? plateNumber)  $default,) {final _that = this;
switch (_that) {
case _CourierInfo():
return $default(_that.firstName,_that.phone,_that.vehicleType,_that.plateNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String firstName,  String? phone,  VehicleType vehicleType,  String? plateNumber)?  $default,) {final _that = this;
switch (_that) {
case _CourierInfo() when $default != null:
return $default(_that.firstName,_that.phone,_that.vehicleType,_that.plateNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CourierInfo implements CourierInfo {
  const _CourierInfo({required this.firstName, this.phone, required this.vehicleType, this.plateNumber});
  factory _CourierInfo.fromJson(Map<String, dynamic> json) => _$CourierInfoFromJson(json);

@override final  String firstName;
@override final  String? phone;
@override final  VehicleType vehicleType;
@override final  String? plateNumber;

/// Create a copy of CourierInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CourierInfoCopyWith<_CourierInfo> get copyWith => __$CourierInfoCopyWithImpl<_CourierInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CourierInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CourierInfo&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.plateNumber, plateNumber) || other.plateNumber == plateNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,firstName,phone,vehicleType,plateNumber);

@override
String toString() {
  return 'CourierInfo(firstName: $firstName, phone: $phone, vehicleType: $vehicleType, plateNumber: $plateNumber)';
}


}

/// @nodoc
abstract mixin class _$CourierInfoCopyWith<$Res> implements $CourierInfoCopyWith<$Res> {
  factory _$CourierInfoCopyWith(_CourierInfo value, $Res Function(_CourierInfo) _then) = __$CourierInfoCopyWithImpl;
@override @useResult
$Res call({
 String firstName, String? phone, VehicleType vehicleType, String? plateNumber
});




}
/// @nodoc
class __$CourierInfoCopyWithImpl<$Res>
    implements _$CourierInfoCopyWith<$Res> {
  __$CourierInfoCopyWithImpl(this._self, this._then);

  final _CourierInfo _self;
  final $Res Function(_CourierInfo) _then;

/// Create a copy of CourierInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? firstName = null,Object? phone = freezed,Object? vehicleType = null,Object? plateNumber = freezed,}) {
  return _then(_CourierInfo(
firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,plateNumber: freezed == plateNumber ? _self.plateNumber : plateNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DeliveryOffer {

 String get id; String get orderId; OfferStatus get status; DateTime get expiresAt; OfferSummary get summary;
/// Create a copy of DeliveryOffer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryOfferCopyWith<DeliveryOffer> get copyWith => _$DeliveryOfferCopyWithImpl<DeliveryOffer>(this as DeliveryOffer, _$identity);

  /// Serializes this DeliveryOffer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryOffer&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,status,expiresAt,summary);

@override
String toString() {
  return 'DeliveryOffer(id: $id, orderId: $orderId, status: $status, expiresAt: $expiresAt, summary: $summary)';
}


}

/// @nodoc
abstract mixin class $DeliveryOfferCopyWith<$Res>  {
  factory $DeliveryOfferCopyWith(DeliveryOffer value, $Res Function(DeliveryOffer) _then) = _$DeliveryOfferCopyWithImpl;
@useResult
$Res call({
 String id, String orderId, OfferStatus status, DateTime expiresAt, OfferSummary summary
});


$OfferSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class _$DeliveryOfferCopyWithImpl<$Res>
    implements $DeliveryOfferCopyWith<$Res> {
  _$DeliveryOfferCopyWithImpl(this._self, this._then);

  final DeliveryOffer _self;
  final $Res Function(DeliveryOffer) _then;

/// Create a copy of DeliveryOffer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderId = null,Object? status = null,Object? expiresAt = null,Object? summary = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OfferStatus,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as OfferSummary,
  ));
}
/// Create a copy of DeliveryOffer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferSummaryCopyWith<$Res> get summary {
  
  return $OfferSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [DeliveryOffer].
extension DeliveryOfferPatterns on DeliveryOffer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryOffer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryOffer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryOffer value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryOffer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryOffer value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryOffer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orderId,  OfferStatus status,  DateTime expiresAt,  OfferSummary summary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryOffer() when $default != null:
return $default(_that.id,_that.orderId,_that.status,_that.expiresAt,_that.summary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orderId,  OfferStatus status,  DateTime expiresAt,  OfferSummary summary)  $default,) {final _that = this;
switch (_that) {
case _DeliveryOffer():
return $default(_that.id,_that.orderId,_that.status,_that.expiresAt,_that.summary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orderId,  OfferStatus status,  DateTime expiresAt,  OfferSummary summary)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryOffer() when $default != null:
return $default(_that.id,_that.orderId,_that.status,_that.expiresAt,_that.summary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeliveryOffer implements DeliveryOffer {
  const _DeliveryOffer({required this.id, required this.orderId, required this.status, required this.expiresAt, required this.summary});
  factory _DeliveryOffer.fromJson(Map<String, dynamic> json) => _$DeliveryOfferFromJson(json);

@override final  String id;
@override final  String orderId;
@override final  OfferStatus status;
@override final  DateTime expiresAt;
@override final  OfferSummary summary;

/// Create a copy of DeliveryOffer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryOfferCopyWith<_DeliveryOffer> get copyWith => __$DeliveryOfferCopyWithImpl<_DeliveryOffer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliveryOfferToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryOffer&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,status,expiresAt,summary);

@override
String toString() {
  return 'DeliveryOffer(id: $id, orderId: $orderId, status: $status, expiresAt: $expiresAt, summary: $summary)';
}


}

/// @nodoc
abstract mixin class _$DeliveryOfferCopyWith<$Res> implements $DeliveryOfferCopyWith<$Res> {
  factory _$DeliveryOfferCopyWith(_DeliveryOffer value, $Res Function(_DeliveryOffer) _then) = __$DeliveryOfferCopyWithImpl;
@override @useResult
$Res call({
 String id, String orderId, OfferStatus status, DateTime expiresAt, OfferSummary summary
});


@override $OfferSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class __$DeliveryOfferCopyWithImpl<$Res>
    implements _$DeliveryOfferCopyWith<$Res> {
  __$DeliveryOfferCopyWithImpl(this._self, this._then);

  final _DeliveryOffer _self;
  final $Res Function(_DeliveryOffer) _then;

/// Create a copy of DeliveryOffer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderId = null,Object? status = null,Object? expiresAt = null,Object? summary = null,}) {
  return _then(_DeliveryOffer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OfferStatus,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as OfferSummary,
  ));
}

/// Create a copy of DeliveryOffer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferSummaryCopyWith<$Res> get summary {
  
  return $OfferSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// @nodoc
mixin _$OfferSummary {

 String get number; String get type; String? get pickupName; String get pickupDistrict; String get pickupLandmark; String get recipientName; String get dropoffDistrict; String get dropoffLandmark; String? get parcelType; int get earning; int get toPickupM; int get tripM; int get cashAmount; String get currency;
/// Create a copy of OfferSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferSummaryCopyWith<OfferSummary> get copyWith => _$OfferSummaryCopyWithImpl<OfferSummary>(this as OfferSummary, _$identity);

  /// Serializes this OfferSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferSummary&&(identical(other.number, number) || other.number == number)&&(identical(other.type, type) || other.type == type)&&(identical(other.pickupName, pickupName) || other.pickupName == pickupName)&&(identical(other.pickupDistrict, pickupDistrict) || other.pickupDistrict == pickupDistrict)&&(identical(other.pickupLandmark, pickupLandmark) || other.pickupLandmark == pickupLandmark)&&(identical(other.recipientName, recipientName) || other.recipientName == recipientName)&&(identical(other.dropoffDistrict, dropoffDistrict) || other.dropoffDistrict == dropoffDistrict)&&(identical(other.dropoffLandmark, dropoffLandmark) || other.dropoffLandmark == dropoffLandmark)&&(identical(other.parcelType, parcelType) || other.parcelType == parcelType)&&(identical(other.earning, earning) || other.earning == earning)&&(identical(other.toPickupM, toPickupM) || other.toPickupM == toPickupM)&&(identical(other.tripM, tripM) || other.tripM == tripM)&&(identical(other.cashAmount, cashAmount) || other.cashAmount == cashAmount)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,type,pickupName,pickupDistrict,pickupLandmark,recipientName,dropoffDistrict,dropoffLandmark,parcelType,earning,toPickupM,tripM,cashAmount,currency);

@override
String toString() {
  return 'OfferSummary(number: $number, type: $type, pickupName: $pickupName, pickupDistrict: $pickupDistrict, pickupLandmark: $pickupLandmark, recipientName: $recipientName, dropoffDistrict: $dropoffDistrict, dropoffLandmark: $dropoffLandmark, parcelType: $parcelType, earning: $earning, toPickupM: $toPickupM, tripM: $tripM, cashAmount: $cashAmount, currency: $currency)';
}


}

/// @nodoc
abstract mixin class $OfferSummaryCopyWith<$Res>  {
  factory $OfferSummaryCopyWith(OfferSummary value, $Res Function(OfferSummary) _then) = _$OfferSummaryCopyWithImpl;
@useResult
$Res call({
 String number, String type, String? pickupName, String pickupDistrict, String pickupLandmark, String recipientName, String dropoffDistrict, String dropoffLandmark, String? parcelType, int earning, int toPickupM, int tripM, int cashAmount, String currency
});




}
/// @nodoc
class _$OfferSummaryCopyWithImpl<$Res>
    implements $OfferSummaryCopyWith<$Res> {
  _$OfferSummaryCopyWithImpl(this._self, this._then);

  final OfferSummary _self;
  final $Res Function(OfferSummary) _then;

/// Create a copy of OfferSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? type = null,Object? pickupName = freezed,Object? pickupDistrict = null,Object? pickupLandmark = null,Object? recipientName = null,Object? dropoffDistrict = null,Object? dropoffLandmark = null,Object? parcelType = freezed,Object? earning = null,Object? toPickupM = null,Object? tripM = null,Object? cashAmount = null,Object? currency = null,}) {
  return _then(_self.copyWith(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,pickupName: freezed == pickupName ? _self.pickupName : pickupName // ignore: cast_nullable_to_non_nullable
as String?,pickupDistrict: null == pickupDistrict ? _self.pickupDistrict : pickupDistrict // ignore: cast_nullable_to_non_nullable
as String,pickupLandmark: null == pickupLandmark ? _self.pickupLandmark : pickupLandmark // ignore: cast_nullable_to_non_nullable
as String,recipientName: null == recipientName ? _self.recipientName : recipientName // ignore: cast_nullable_to_non_nullable
as String,dropoffDistrict: null == dropoffDistrict ? _self.dropoffDistrict : dropoffDistrict // ignore: cast_nullable_to_non_nullable
as String,dropoffLandmark: null == dropoffLandmark ? _self.dropoffLandmark : dropoffLandmark // ignore: cast_nullable_to_non_nullable
as String,parcelType: freezed == parcelType ? _self.parcelType : parcelType // ignore: cast_nullable_to_non_nullable
as String?,earning: null == earning ? _self.earning : earning // ignore: cast_nullable_to_non_nullable
as int,toPickupM: null == toPickupM ? _self.toPickupM : toPickupM // ignore: cast_nullable_to_non_nullable
as int,tripM: null == tripM ? _self.tripM : tripM // ignore: cast_nullable_to_non_nullable
as int,cashAmount: null == cashAmount ? _self.cashAmount : cashAmount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OfferSummary].
extension OfferSummaryPatterns on OfferSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferSummary value)  $default,){
final _that = this;
switch (_that) {
case _OfferSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferSummary value)?  $default,){
final _that = this;
switch (_that) {
case _OfferSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String number,  String type,  String? pickupName,  String pickupDistrict,  String pickupLandmark,  String recipientName,  String dropoffDistrict,  String dropoffLandmark,  String? parcelType,  int earning,  int toPickupM,  int tripM,  int cashAmount,  String currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferSummary() when $default != null:
return $default(_that.number,_that.type,_that.pickupName,_that.pickupDistrict,_that.pickupLandmark,_that.recipientName,_that.dropoffDistrict,_that.dropoffLandmark,_that.parcelType,_that.earning,_that.toPickupM,_that.tripM,_that.cashAmount,_that.currency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String number,  String type,  String? pickupName,  String pickupDistrict,  String pickupLandmark,  String recipientName,  String dropoffDistrict,  String dropoffLandmark,  String? parcelType,  int earning,  int toPickupM,  int tripM,  int cashAmount,  String currency)  $default,) {final _that = this;
switch (_that) {
case _OfferSummary():
return $default(_that.number,_that.type,_that.pickupName,_that.pickupDistrict,_that.pickupLandmark,_that.recipientName,_that.dropoffDistrict,_that.dropoffLandmark,_that.parcelType,_that.earning,_that.toPickupM,_that.tripM,_that.cashAmount,_that.currency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String number,  String type,  String? pickupName,  String pickupDistrict,  String pickupLandmark,  String recipientName,  String dropoffDistrict,  String dropoffLandmark,  String? parcelType,  int earning,  int toPickupM,  int tripM,  int cashAmount,  String currency)?  $default,) {final _that = this;
switch (_that) {
case _OfferSummary() when $default != null:
return $default(_that.number,_that.type,_that.pickupName,_that.pickupDistrict,_that.pickupLandmark,_that.recipientName,_that.dropoffDistrict,_that.dropoffLandmark,_that.parcelType,_that.earning,_that.toPickupM,_that.tripM,_that.cashAmount,_that.currency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferSummary implements OfferSummary {
  const _OfferSummary({required this.number, required this.type, this.pickupName, required this.pickupDistrict, required this.pickupLandmark, required this.recipientName, required this.dropoffDistrict, required this.dropoffLandmark, this.parcelType, required this.earning, required this.toPickupM, required this.tripM, required this.cashAmount, this.currency = 'XOF'});
  factory _OfferSummary.fromJson(Map<String, dynamic> json) => _$OfferSummaryFromJson(json);

@override final  String number;
@override final  String type;
@override final  String? pickupName;
@override final  String pickupDistrict;
@override final  String pickupLandmark;
@override final  String recipientName;
@override final  String dropoffDistrict;
@override final  String dropoffLandmark;
@override final  String? parcelType;
@override final  int earning;
@override final  int toPickupM;
@override final  int tripM;
@override final  int cashAmount;
@override@JsonKey() final  String currency;

/// Create a copy of OfferSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferSummaryCopyWith<_OfferSummary> get copyWith => __$OfferSummaryCopyWithImpl<_OfferSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferSummary&&(identical(other.number, number) || other.number == number)&&(identical(other.type, type) || other.type == type)&&(identical(other.pickupName, pickupName) || other.pickupName == pickupName)&&(identical(other.pickupDistrict, pickupDistrict) || other.pickupDistrict == pickupDistrict)&&(identical(other.pickupLandmark, pickupLandmark) || other.pickupLandmark == pickupLandmark)&&(identical(other.recipientName, recipientName) || other.recipientName == recipientName)&&(identical(other.dropoffDistrict, dropoffDistrict) || other.dropoffDistrict == dropoffDistrict)&&(identical(other.dropoffLandmark, dropoffLandmark) || other.dropoffLandmark == dropoffLandmark)&&(identical(other.parcelType, parcelType) || other.parcelType == parcelType)&&(identical(other.earning, earning) || other.earning == earning)&&(identical(other.toPickupM, toPickupM) || other.toPickupM == toPickupM)&&(identical(other.tripM, tripM) || other.tripM == tripM)&&(identical(other.cashAmount, cashAmount) || other.cashAmount == cashAmount)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,number,type,pickupName,pickupDistrict,pickupLandmark,recipientName,dropoffDistrict,dropoffLandmark,parcelType,earning,toPickupM,tripM,cashAmount,currency);

@override
String toString() {
  return 'OfferSummary(number: $number, type: $type, pickupName: $pickupName, pickupDistrict: $pickupDistrict, pickupLandmark: $pickupLandmark, recipientName: $recipientName, dropoffDistrict: $dropoffDistrict, dropoffLandmark: $dropoffLandmark, parcelType: $parcelType, earning: $earning, toPickupM: $toPickupM, tripM: $tripM, cashAmount: $cashAmount, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$OfferSummaryCopyWith<$Res> implements $OfferSummaryCopyWith<$Res> {
  factory _$OfferSummaryCopyWith(_OfferSummary value, $Res Function(_OfferSummary) _then) = __$OfferSummaryCopyWithImpl;
@override @useResult
$Res call({
 String number, String type, String? pickupName, String pickupDistrict, String pickupLandmark, String recipientName, String dropoffDistrict, String dropoffLandmark, String? parcelType, int earning, int toPickupM, int tripM, int cashAmount, String currency
});




}
/// @nodoc
class __$OfferSummaryCopyWithImpl<$Res>
    implements _$OfferSummaryCopyWith<$Res> {
  __$OfferSummaryCopyWithImpl(this._self, this._then);

  final _OfferSummary _self;
  final $Res Function(_OfferSummary) _then;

/// Create a copy of OfferSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? type = null,Object? pickupName = freezed,Object? pickupDistrict = null,Object? pickupLandmark = null,Object? recipientName = null,Object? dropoffDistrict = null,Object? dropoffLandmark = null,Object? parcelType = freezed,Object? earning = null,Object? toPickupM = null,Object? tripM = null,Object? cashAmount = null,Object? currency = null,}) {
  return _then(_OfferSummary(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,pickupName: freezed == pickupName ? _self.pickupName : pickupName // ignore: cast_nullable_to_non_nullable
as String?,pickupDistrict: null == pickupDistrict ? _self.pickupDistrict : pickupDistrict // ignore: cast_nullable_to_non_nullable
as String,pickupLandmark: null == pickupLandmark ? _self.pickupLandmark : pickupLandmark // ignore: cast_nullable_to_non_nullable
as String,recipientName: null == recipientName ? _self.recipientName : recipientName // ignore: cast_nullable_to_non_nullable
as String,dropoffDistrict: null == dropoffDistrict ? _self.dropoffDistrict : dropoffDistrict // ignore: cast_nullable_to_non_nullable
as String,dropoffLandmark: null == dropoffLandmark ? _self.dropoffLandmark : dropoffLandmark // ignore: cast_nullable_to_non_nullable
as String,parcelType: freezed == parcelType ? _self.parcelType : parcelType // ignore: cast_nullable_to_non_nullable
as String?,earning: null == earning ? _self.earning : earning // ignore: cast_nullable_to_non_nullable
as int,toPickupM: null == toPickupM ? _self.toPickupM : toPickupM // ignore: cast_nullable_to_non_nullable
as int,tripM: null == tripM ? _self.tripM : tripM // ignore: cast_nullable_to_non_nullable
as int,cashAmount: null == cashAmount ? _self.cashAmount : cashAmount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DispatchCandidate {

 String get userId; String? get firstName; String? get lastName; String? get phone; VehicleType get vehicleType; String? get plateNumber; int? get distanceM; int? get locationAgeS; bool get busy; bool get offerPending;
/// Create a copy of DispatchCandidate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DispatchCandidateCopyWith<DispatchCandidate> get copyWith => _$DispatchCandidateCopyWithImpl<DispatchCandidate>(this as DispatchCandidate, _$identity);

  /// Serializes this DispatchCandidate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DispatchCandidate&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.plateNumber, plateNumber) || other.plateNumber == plateNumber)&&(identical(other.distanceM, distanceM) || other.distanceM == distanceM)&&(identical(other.locationAgeS, locationAgeS) || other.locationAgeS == locationAgeS)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.offerPending, offerPending) || other.offerPending == offerPending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,firstName,lastName,phone,vehicleType,plateNumber,distanceM,locationAgeS,busy,offerPending);

@override
String toString() {
  return 'DispatchCandidate(userId: $userId, firstName: $firstName, lastName: $lastName, phone: $phone, vehicleType: $vehicleType, plateNumber: $plateNumber, distanceM: $distanceM, locationAgeS: $locationAgeS, busy: $busy, offerPending: $offerPending)';
}


}

/// @nodoc
abstract mixin class $DispatchCandidateCopyWith<$Res>  {
  factory $DispatchCandidateCopyWith(DispatchCandidate value, $Res Function(DispatchCandidate) _then) = _$DispatchCandidateCopyWithImpl;
@useResult
$Res call({
 String userId, String? firstName, String? lastName, String? phone, VehicleType vehicleType, String? plateNumber, int? distanceM, int? locationAgeS, bool busy, bool offerPending
});




}
/// @nodoc
class _$DispatchCandidateCopyWithImpl<$Res>
    implements $DispatchCandidateCopyWith<$Res> {
  _$DispatchCandidateCopyWithImpl(this._self, this._then);

  final DispatchCandidate _self;
  final $Res Function(DispatchCandidate) _then;

/// Create a copy of DispatchCandidate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? firstName = freezed,Object? lastName = freezed,Object? phone = freezed,Object? vehicleType = null,Object? plateNumber = freezed,Object? distanceM = freezed,Object? locationAgeS = freezed,Object? busy = null,Object? offerPending = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,plateNumber: freezed == plateNumber ? _self.plateNumber : plateNumber // ignore: cast_nullable_to_non_nullable
as String?,distanceM: freezed == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as int?,locationAgeS: freezed == locationAgeS ? _self.locationAgeS : locationAgeS // ignore: cast_nullable_to_non_nullable
as int?,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,offerPending: null == offerPending ? _self.offerPending : offerPending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DispatchCandidate].
extension DispatchCandidatePatterns on DispatchCandidate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DispatchCandidate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DispatchCandidate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DispatchCandidate value)  $default,){
final _that = this;
switch (_that) {
case _DispatchCandidate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DispatchCandidate value)?  $default,){
final _that = this;
switch (_that) {
case _DispatchCandidate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String? firstName,  String? lastName,  String? phone,  VehicleType vehicleType,  String? plateNumber,  int? distanceM,  int? locationAgeS,  bool busy,  bool offerPending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DispatchCandidate() when $default != null:
return $default(_that.userId,_that.firstName,_that.lastName,_that.phone,_that.vehicleType,_that.plateNumber,_that.distanceM,_that.locationAgeS,_that.busy,_that.offerPending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String? firstName,  String? lastName,  String? phone,  VehicleType vehicleType,  String? plateNumber,  int? distanceM,  int? locationAgeS,  bool busy,  bool offerPending)  $default,) {final _that = this;
switch (_that) {
case _DispatchCandidate():
return $default(_that.userId,_that.firstName,_that.lastName,_that.phone,_that.vehicleType,_that.plateNumber,_that.distanceM,_that.locationAgeS,_that.busy,_that.offerPending);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String? firstName,  String? lastName,  String? phone,  VehicleType vehicleType,  String? plateNumber,  int? distanceM,  int? locationAgeS,  bool busy,  bool offerPending)?  $default,) {final _that = this;
switch (_that) {
case _DispatchCandidate() when $default != null:
return $default(_that.userId,_that.firstName,_that.lastName,_that.phone,_that.vehicleType,_that.plateNumber,_that.distanceM,_that.locationAgeS,_that.busy,_that.offerPending);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DispatchCandidate implements DispatchCandidate {
  const _DispatchCandidate({required this.userId, this.firstName, this.lastName, this.phone, required this.vehicleType, this.plateNumber, this.distanceM, this.locationAgeS, required this.busy, required this.offerPending});
  factory _DispatchCandidate.fromJson(Map<String, dynamic> json) => _$DispatchCandidateFromJson(json);

@override final  String userId;
@override final  String? firstName;
@override final  String? lastName;
@override final  String? phone;
@override final  VehicleType vehicleType;
@override final  String? plateNumber;
@override final  int? distanceM;
@override final  int? locationAgeS;
@override final  bool busy;
@override final  bool offerPending;

/// Create a copy of DispatchCandidate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DispatchCandidateCopyWith<_DispatchCandidate> get copyWith => __$DispatchCandidateCopyWithImpl<_DispatchCandidate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DispatchCandidateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DispatchCandidate&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.plateNumber, plateNumber) || other.plateNumber == plateNumber)&&(identical(other.distanceM, distanceM) || other.distanceM == distanceM)&&(identical(other.locationAgeS, locationAgeS) || other.locationAgeS == locationAgeS)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.offerPending, offerPending) || other.offerPending == offerPending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,firstName,lastName,phone,vehicleType,plateNumber,distanceM,locationAgeS,busy,offerPending);

@override
String toString() {
  return 'DispatchCandidate(userId: $userId, firstName: $firstName, lastName: $lastName, phone: $phone, vehicleType: $vehicleType, plateNumber: $plateNumber, distanceM: $distanceM, locationAgeS: $locationAgeS, busy: $busy, offerPending: $offerPending)';
}


}

/// @nodoc
abstract mixin class _$DispatchCandidateCopyWith<$Res> implements $DispatchCandidateCopyWith<$Res> {
  factory _$DispatchCandidateCopyWith(_DispatchCandidate value, $Res Function(_DispatchCandidate) _then) = __$DispatchCandidateCopyWithImpl;
@override @useResult
$Res call({
 String userId, String? firstName, String? lastName, String? phone, VehicleType vehicleType, String? plateNumber, int? distanceM, int? locationAgeS, bool busy, bool offerPending
});




}
/// @nodoc
class __$DispatchCandidateCopyWithImpl<$Res>
    implements _$DispatchCandidateCopyWith<$Res> {
  __$DispatchCandidateCopyWithImpl(this._self, this._then);

  final _DispatchCandidate _self;
  final $Res Function(_DispatchCandidate) _then;

/// Create a copy of DispatchCandidate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? firstName = freezed,Object? lastName = freezed,Object? phone = freezed,Object? vehicleType = null,Object? plateNumber = freezed,Object? distanceM = freezed,Object? locationAgeS = freezed,Object? busy = null,Object? offerPending = null,}) {
  return _then(_DispatchCandidate(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as VehicleType,plateNumber: freezed == plateNumber ? _self.plateNumber : plateNumber // ignore: cast_nullable_to_non_nullable
as String?,distanceM: freezed == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as int?,locationAgeS: freezed == locationAgeS ? _self.locationAgeS : locationAgeS // ignore: cast_nullable_to_non_nullable
as int?,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,offerPending: null == offerPending ? _self.offerPending : offerPending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$CourierSummary {

 int get earningsToday; int get deliveriesToday; int get cashDue;
/// Create a copy of CourierSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CourierSummaryCopyWith<CourierSummary> get copyWith => _$CourierSummaryCopyWithImpl<CourierSummary>(this as CourierSummary, _$identity);

  /// Serializes this CourierSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CourierSummary&&(identical(other.earningsToday, earningsToday) || other.earningsToday == earningsToday)&&(identical(other.deliveriesToday, deliveriesToday) || other.deliveriesToday == deliveriesToday)&&(identical(other.cashDue, cashDue) || other.cashDue == cashDue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,earningsToday,deliveriesToday,cashDue);

@override
String toString() {
  return 'CourierSummary(earningsToday: $earningsToday, deliveriesToday: $deliveriesToday, cashDue: $cashDue)';
}


}

/// @nodoc
abstract mixin class $CourierSummaryCopyWith<$Res>  {
  factory $CourierSummaryCopyWith(CourierSummary value, $Res Function(CourierSummary) _then) = _$CourierSummaryCopyWithImpl;
@useResult
$Res call({
 int earningsToday, int deliveriesToday, int cashDue
});




}
/// @nodoc
class _$CourierSummaryCopyWithImpl<$Res>
    implements $CourierSummaryCopyWith<$Res> {
  _$CourierSummaryCopyWithImpl(this._self, this._then);

  final CourierSummary _self;
  final $Res Function(CourierSummary) _then;

/// Create a copy of CourierSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? earningsToday = null,Object? deliveriesToday = null,Object? cashDue = null,}) {
  return _then(_self.copyWith(
earningsToday: null == earningsToday ? _self.earningsToday : earningsToday // ignore: cast_nullable_to_non_nullable
as int,deliveriesToday: null == deliveriesToday ? _self.deliveriesToday : deliveriesToday // ignore: cast_nullable_to_non_nullable
as int,cashDue: null == cashDue ? _self.cashDue : cashDue // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CourierSummary].
extension CourierSummaryPatterns on CourierSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CourierSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CourierSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CourierSummary value)  $default,){
final _that = this;
switch (_that) {
case _CourierSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CourierSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CourierSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int earningsToday,  int deliveriesToday,  int cashDue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CourierSummary() when $default != null:
return $default(_that.earningsToday,_that.deliveriesToday,_that.cashDue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int earningsToday,  int deliveriesToday,  int cashDue)  $default,) {final _that = this;
switch (_that) {
case _CourierSummary():
return $default(_that.earningsToday,_that.deliveriesToday,_that.cashDue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int earningsToday,  int deliveriesToday,  int cashDue)?  $default,) {final _that = this;
switch (_that) {
case _CourierSummary() when $default != null:
return $default(_that.earningsToday,_that.deliveriesToday,_that.cashDue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CourierSummary implements CourierSummary {
  const _CourierSummary({this.earningsToday = 0, this.deliveriesToday = 0, this.cashDue = 0});
  factory _CourierSummary.fromJson(Map<String, dynamic> json) => _$CourierSummaryFromJson(json);

@override@JsonKey() final  int earningsToday;
@override@JsonKey() final  int deliveriesToday;
@override@JsonKey() final  int cashDue;

/// Create a copy of CourierSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CourierSummaryCopyWith<_CourierSummary> get copyWith => __$CourierSummaryCopyWithImpl<_CourierSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CourierSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CourierSummary&&(identical(other.earningsToday, earningsToday) || other.earningsToday == earningsToday)&&(identical(other.deliveriesToday, deliveriesToday) || other.deliveriesToday == deliveriesToday)&&(identical(other.cashDue, cashDue) || other.cashDue == cashDue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,earningsToday,deliveriesToday,cashDue);

@override
String toString() {
  return 'CourierSummary(earningsToday: $earningsToday, deliveriesToday: $deliveriesToday, cashDue: $cashDue)';
}


}

/// @nodoc
abstract mixin class _$CourierSummaryCopyWith<$Res> implements $CourierSummaryCopyWith<$Res> {
  factory _$CourierSummaryCopyWith(_CourierSummary value, $Res Function(_CourierSummary) _then) = __$CourierSummaryCopyWithImpl;
@override @useResult
$Res call({
 int earningsToday, int deliveriesToday, int cashDue
});




}
/// @nodoc
class __$CourierSummaryCopyWithImpl<$Res>
    implements _$CourierSummaryCopyWith<$Res> {
  __$CourierSummaryCopyWithImpl(this._self, this._then);

  final _CourierSummary _self;
  final $Res Function(_CourierSummary) _then;

/// Create a copy of CourierSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? earningsToday = null,Object? deliveriesToday = null,Object? cashDue = null,}) {
  return _then(_CourierSummary(
earningsToday: null == earningsToday ? _self.earningsToday : earningsToday // ignore: cast_nullable_to_non_nullable
as int,deliveriesToday: null == deliveriesToday ? _self.deliveriesToday : deliveriesToday // ignore: cast_nullable_to_non_nullable
as int,cashDue: null == cashDue ? _self.cashDue : cashDue // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CodeResult {

 bool get delivered; int get attemptsLeft; bool get locked;
/// Create a copy of CodeResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodeResultCopyWith<CodeResult> get copyWith => _$CodeResultCopyWithImpl<CodeResult>(this as CodeResult, _$identity);

  /// Serializes this CodeResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodeResult&&(identical(other.delivered, delivered) || other.delivered == delivered)&&(identical(other.attemptsLeft, attemptsLeft) || other.attemptsLeft == attemptsLeft)&&(identical(other.locked, locked) || other.locked == locked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,delivered,attemptsLeft,locked);

@override
String toString() {
  return 'CodeResult(delivered: $delivered, attemptsLeft: $attemptsLeft, locked: $locked)';
}


}

/// @nodoc
abstract mixin class $CodeResultCopyWith<$Res>  {
  factory $CodeResultCopyWith(CodeResult value, $Res Function(CodeResult) _then) = _$CodeResultCopyWithImpl;
@useResult
$Res call({
 bool delivered, int attemptsLeft, bool locked
});




}
/// @nodoc
class _$CodeResultCopyWithImpl<$Res>
    implements $CodeResultCopyWith<$Res> {
  _$CodeResultCopyWithImpl(this._self, this._then);

  final CodeResult _self;
  final $Res Function(CodeResult) _then;

/// Create a copy of CodeResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? delivered = null,Object? attemptsLeft = null,Object? locked = null,}) {
  return _then(_self.copyWith(
delivered: null == delivered ? _self.delivered : delivered // ignore: cast_nullable_to_non_nullable
as bool,attemptsLeft: null == attemptsLeft ? _self.attemptsLeft : attemptsLeft // ignore: cast_nullable_to_non_nullable
as int,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CodeResult].
extension CodeResultPatterns on CodeResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodeResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodeResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodeResult value)  $default,){
final _that = this;
switch (_that) {
case _CodeResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodeResult value)?  $default,){
final _that = this;
switch (_that) {
case _CodeResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool delivered,  int attemptsLeft,  bool locked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodeResult() when $default != null:
return $default(_that.delivered,_that.attemptsLeft,_that.locked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool delivered,  int attemptsLeft,  bool locked)  $default,) {final _that = this;
switch (_that) {
case _CodeResult():
return $default(_that.delivered,_that.attemptsLeft,_that.locked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool delivered,  int attemptsLeft,  bool locked)?  $default,) {final _that = this;
switch (_that) {
case _CodeResult() when $default != null:
return $default(_that.delivered,_that.attemptsLeft,_that.locked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CodeResult implements CodeResult {
  const _CodeResult({required this.delivered, required this.attemptsLeft, required this.locked});
  factory _CodeResult.fromJson(Map<String, dynamic> json) => _$CodeResultFromJson(json);

@override final  bool delivered;
@override final  int attemptsLeft;
@override final  bool locked;

/// Create a copy of CodeResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodeResultCopyWith<_CodeResult> get copyWith => __$CodeResultCopyWithImpl<_CodeResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CodeResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodeResult&&(identical(other.delivered, delivered) || other.delivered == delivered)&&(identical(other.attemptsLeft, attemptsLeft) || other.attemptsLeft == attemptsLeft)&&(identical(other.locked, locked) || other.locked == locked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,delivered,attemptsLeft,locked);

@override
String toString() {
  return 'CodeResult(delivered: $delivered, attemptsLeft: $attemptsLeft, locked: $locked)';
}


}

/// @nodoc
abstract mixin class _$CodeResultCopyWith<$Res> implements $CodeResultCopyWith<$Res> {
  factory _$CodeResultCopyWith(_CodeResult value, $Res Function(_CodeResult) _then) = __$CodeResultCopyWithImpl;
@override @useResult
$Res call({
 bool delivered, int attemptsLeft, bool locked
});




}
/// @nodoc
class __$CodeResultCopyWithImpl<$Res>
    implements _$CodeResultCopyWith<$Res> {
  __$CodeResultCopyWithImpl(this._self, this._then);

  final _CodeResult _self;
  final $Res Function(_CodeResult) _then;

/// Create a copy of CodeResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? delivered = null,Object? attemptsLeft = null,Object? locked = null,}) {
  return _then(_CodeResult(
delivered: null == delivered ? _self.delivered : delivered // ignore: cast_nullable_to_non_nullable
as bool,attemptsLeft: null == attemptsLeft ? _self.attemptsLeft : attemptsLeft // ignore: cast_nullable_to_non_nullable
as int,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
