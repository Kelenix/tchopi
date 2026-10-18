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
mixin _$PlatformSettings {

 int get offerTimeoutS; int get restaurantTimeoutS; int get paymentTimeoutS; int get dispatchAlertS; int get dispatchCancelS; String? get supportPhone;
/// Create a copy of PlatformSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlatformSettingsCopyWith<PlatformSettings> get copyWith => _$PlatformSettingsCopyWithImpl<PlatformSettings>(this as PlatformSettings, _$identity);

  /// Serializes this PlatformSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlatformSettings&&(identical(other.offerTimeoutS, offerTimeoutS) || other.offerTimeoutS == offerTimeoutS)&&(identical(other.restaurantTimeoutS, restaurantTimeoutS) || other.restaurantTimeoutS == restaurantTimeoutS)&&(identical(other.paymentTimeoutS, paymentTimeoutS) || other.paymentTimeoutS == paymentTimeoutS)&&(identical(other.dispatchAlertS, dispatchAlertS) || other.dispatchAlertS == dispatchAlertS)&&(identical(other.dispatchCancelS, dispatchCancelS) || other.dispatchCancelS == dispatchCancelS)&&(identical(other.supportPhone, supportPhone) || other.supportPhone == supportPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,offerTimeoutS,restaurantTimeoutS,paymentTimeoutS,dispatchAlertS,dispatchCancelS,supportPhone);

@override
String toString() {
  return 'PlatformSettings(offerTimeoutS: $offerTimeoutS, restaurantTimeoutS: $restaurantTimeoutS, paymentTimeoutS: $paymentTimeoutS, dispatchAlertS: $dispatchAlertS, dispatchCancelS: $dispatchCancelS, supportPhone: $supportPhone)';
}


}

/// @nodoc
abstract mixin class $PlatformSettingsCopyWith<$Res>  {
  factory $PlatformSettingsCopyWith(PlatformSettings value, $Res Function(PlatformSettings) _then) = _$PlatformSettingsCopyWithImpl;
@useResult
$Res call({
 int offerTimeoutS, int restaurantTimeoutS, int paymentTimeoutS, int dispatchAlertS, int dispatchCancelS, String? supportPhone
});




}
/// @nodoc
class _$PlatformSettingsCopyWithImpl<$Res>
    implements $PlatformSettingsCopyWith<$Res> {
  _$PlatformSettingsCopyWithImpl(this._self, this._then);

  final PlatformSettings _self;
  final $Res Function(PlatformSettings) _then;

/// Create a copy of PlatformSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? offerTimeoutS = null,Object? restaurantTimeoutS = null,Object? paymentTimeoutS = null,Object? dispatchAlertS = null,Object? dispatchCancelS = null,Object? supportPhone = freezed,}) {
  return _then(_self.copyWith(
offerTimeoutS: null == offerTimeoutS ? _self.offerTimeoutS : offerTimeoutS // ignore: cast_nullable_to_non_nullable
as int,restaurantTimeoutS: null == restaurantTimeoutS ? _self.restaurantTimeoutS : restaurantTimeoutS // ignore: cast_nullable_to_non_nullable
as int,paymentTimeoutS: null == paymentTimeoutS ? _self.paymentTimeoutS : paymentTimeoutS // ignore: cast_nullable_to_non_nullable
as int,dispatchAlertS: null == dispatchAlertS ? _self.dispatchAlertS : dispatchAlertS // ignore: cast_nullable_to_non_nullable
as int,dispatchCancelS: null == dispatchCancelS ? _self.dispatchCancelS : dispatchCancelS // ignore: cast_nullable_to_non_nullable
as int,supportPhone: freezed == supportPhone ? _self.supportPhone : supportPhone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlatformSettings].
extension PlatformSettingsPatterns on PlatformSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlatformSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlatformSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlatformSettings value)  $default,){
final _that = this;
switch (_that) {
case _PlatformSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlatformSettings value)?  $default,){
final _that = this;
switch (_that) {
case _PlatformSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int offerTimeoutS,  int restaurantTimeoutS,  int paymentTimeoutS,  int dispatchAlertS,  int dispatchCancelS,  String? supportPhone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlatformSettings() when $default != null:
return $default(_that.offerTimeoutS,_that.restaurantTimeoutS,_that.paymentTimeoutS,_that.dispatchAlertS,_that.dispatchCancelS,_that.supportPhone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int offerTimeoutS,  int restaurantTimeoutS,  int paymentTimeoutS,  int dispatchAlertS,  int dispatchCancelS,  String? supportPhone)  $default,) {final _that = this;
switch (_that) {
case _PlatformSettings():
return $default(_that.offerTimeoutS,_that.restaurantTimeoutS,_that.paymentTimeoutS,_that.dispatchAlertS,_that.dispatchCancelS,_that.supportPhone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int offerTimeoutS,  int restaurantTimeoutS,  int paymentTimeoutS,  int dispatchAlertS,  int dispatchCancelS,  String? supportPhone)?  $default,) {final _that = this;
switch (_that) {
case _PlatformSettings() when $default != null:
return $default(_that.offerTimeoutS,_that.restaurantTimeoutS,_that.paymentTimeoutS,_that.dispatchAlertS,_that.dispatchCancelS,_that.supportPhone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlatformSettings implements PlatformSettings {
  const _PlatformSettings({required this.offerTimeoutS, required this.restaurantTimeoutS, required this.paymentTimeoutS, required this.dispatchAlertS, required this.dispatchCancelS, this.supportPhone});
  factory _PlatformSettings.fromJson(Map<String, dynamic> json) => _$PlatformSettingsFromJson(json);

@override final  int offerTimeoutS;
@override final  int restaurantTimeoutS;
@override final  int paymentTimeoutS;
@override final  int dispatchAlertS;
@override final  int dispatchCancelS;
@override final  String? supportPhone;

/// Create a copy of PlatformSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlatformSettingsCopyWith<_PlatformSettings> get copyWith => __$PlatformSettingsCopyWithImpl<_PlatformSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlatformSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlatformSettings&&(identical(other.offerTimeoutS, offerTimeoutS) || other.offerTimeoutS == offerTimeoutS)&&(identical(other.restaurantTimeoutS, restaurantTimeoutS) || other.restaurantTimeoutS == restaurantTimeoutS)&&(identical(other.paymentTimeoutS, paymentTimeoutS) || other.paymentTimeoutS == paymentTimeoutS)&&(identical(other.dispatchAlertS, dispatchAlertS) || other.dispatchAlertS == dispatchAlertS)&&(identical(other.dispatchCancelS, dispatchCancelS) || other.dispatchCancelS == dispatchCancelS)&&(identical(other.supportPhone, supportPhone) || other.supportPhone == supportPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,offerTimeoutS,restaurantTimeoutS,paymentTimeoutS,dispatchAlertS,dispatchCancelS,supportPhone);

@override
String toString() {
  return 'PlatformSettings(offerTimeoutS: $offerTimeoutS, restaurantTimeoutS: $restaurantTimeoutS, paymentTimeoutS: $paymentTimeoutS, dispatchAlertS: $dispatchAlertS, dispatchCancelS: $dispatchCancelS, supportPhone: $supportPhone)';
}


}

/// @nodoc
abstract mixin class _$PlatformSettingsCopyWith<$Res> implements $PlatformSettingsCopyWith<$Res> {
  factory _$PlatformSettingsCopyWith(_PlatformSettings value, $Res Function(_PlatformSettings) _then) = __$PlatformSettingsCopyWithImpl;
@override @useResult
$Res call({
 int offerTimeoutS, int restaurantTimeoutS, int paymentTimeoutS, int dispatchAlertS, int dispatchCancelS, String? supportPhone
});




}
/// @nodoc
class __$PlatformSettingsCopyWithImpl<$Res>
    implements _$PlatformSettingsCopyWith<$Res> {
  __$PlatformSettingsCopyWithImpl(this._self, this._then);

  final _PlatformSettings _self;
  final $Res Function(_PlatformSettings) _then;

/// Create a copy of PlatformSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? offerTimeoutS = null,Object? restaurantTimeoutS = null,Object? paymentTimeoutS = null,Object? dispatchAlertS = null,Object? dispatchCancelS = null,Object? supportPhone = freezed,}) {
  return _then(_PlatformSettings(
offerTimeoutS: null == offerTimeoutS ? _self.offerTimeoutS : offerTimeoutS // ignore: cast_nullable_to_non_nullable
as int,restaurantTimeoutS: null == restaurantTimeoutS ? _self.restaurantTimeoutS : restaurantTimeoutS // ignore: cast_nullable_to_non_nullable
as int,paymentTimeoutS: null == paymentTimeoutS ? _self.paymentTimeoutS : paymentTimeoutS // ignore: cast_nullable_to_non_nullable
as int,dispatchAlertS: null == dispatchAlertS ? _self.dispatchAlertS : dispatchAlertS // ignore: cast_nullable_to_non_nullable
as int,dispatchCancelS: null == dispatchCancelS ? _self.dispatchCancelS : dispatchCancelS // ignore: cast_nullable_to_non_nullable
as int,supportPhone: freezed == supportPhone ? _self.supportPhone : supportPhone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
