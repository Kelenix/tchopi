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

// dart format on
