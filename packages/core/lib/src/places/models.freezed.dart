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
mixin _$Zone {

 String get id; String get name; String get city; String get countryCode; String get currency; String get timezone; double get centerLat; double get centerLng; int get radiusM; bool get isActive;
/// Create a copy of Zone
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ZoneCopyWith<Zone> get copyWith => _$ZoneCopyWithImpl<Zone>(this as Zone, _$identity);

  /// Serializes this Zone to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Zone&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.city, city) || other.city == city)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.centerLat, centerLat) || other.centerLat == centerLat)&&(identical(other.centerLng, centerLng) || other.centerLng == centerLng)&&(identical(other.radiusM, radiusM) || other.radiusM == radiusM)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,city,countryCode,currency,timezone,centerLat,centerLng,radiusM,isActive);

@override
String toString() {
  return 'Zone(id: $id, name: $name, city: $city, countryCode: $countryCode, currency: $currency, timezone: $timezone, centerLat: $centerLat, centerLng: $centerLng, radiusM: $radiusM, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $ZoneCopyWith<$Res>  {
  factory $ZoneCopyWith(Zone value, $Res Function(Zone) _then) = _$ZoneCopyWithImpl;
@useResult
$Res call({
 String id, String name, String city, String countryCode, String currency, String timezone, double centerLat, double centerLng, int radiusM, bool isActive
});




}
/// @nodoc
class _$ZoneCopyWithImpl<$Res>
    implements $ZoneCopyWith<$Res> {
  _$ZoneCopyWithImpl(this._self, this._then);

  final Zone _self;
  final $Res Function(Zone) _then;

/// Create a copy of Zone
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? city = null,Object? countryCode = null,Object? currency = null,Object? timezone = null,Object? centerLat = null,Object? centerLng = null,Object? radiusM = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,centerLat: null == centerLat ? _self.centerLat : centerLat // ignore: cast_nullable_to_non_nullable
as double,centerLng: null == centerLng ? _self.centerLng : centerLng // ignore: cast_nullable_to_non_nullable
as double,radiusM: null == radiusM ? _self.radiusM : radiusM // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Zone].
extension ZonePatterns on Zone {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Zone value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Zone() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Zone value)  $default,){
final _that = this;
switch (_that) {
case _Zone():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Zone value)?  $default,){
final _that = this;
switch (_that) {
case _Zone() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String city,  String countryCode,  String currency,  String timezone,  double centerLat,  double centerLng,  int radiusM,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Zone() when $default != null:
return $default(_that.id,_that.name,_that.city,_that.countryCode,_that.currency,_that.timezone,_that.centerLat,_that.centerLng,_that.radiusM,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String city,  String countryCode,  String currency,  String timezone,  double centerLat,  double centerLng,  int radiusM,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _Zone():
return $default(_that.id,_that.name,_that.city,_that.countryCode,_that.currency,_that.timezone,_that.centerLat,_that.centerLng,_that.radiusM,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String city,  String countryCode,  String currency,  String timezone,  double centerLat,  double centerLng,  int radiusM,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _Zone() when $default != null:
return $default(_that.id,_that.name,_that.city,_that.countryCode,_that.currency,_that.timezone,_that.centerLat,_that.centerLng,_that.radiusM,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Zone implements Zone {
  const _Zone({required this.id, required this.name, required this.city, this.countryCode = 'CI', this.currency = 'XOF', this.timezone = 'Africa/Abidjan', required this.centerLat, required this.centerLng, required this.radiusM, this.isActive = true});
  factory _Zone.fromJson(Map<String, dynamic> json) => _$ZoneFromJson(json);

@override final  String id;
@override final  String name;
@override final  String city;
@override@JsonKey() final  String countryCode;
@override@JsonKey() final  String currency;
@override@JsonKey() final  String timezone;
@override final  double centerLat;
@override final  double centerLng;
@override final  int radiusM;
@override@JsonKey() final  bool isActive;

/// Create a copy of Zone
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ZoneCopyWith<_Zone> get copyWith => __$ZoneCopyWithImpl<_Zone>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ZoneToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Zone&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.city, city) || other.city == city)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.centerLat, centerLat) || other.centerLat == centerLat)&&(identical(other.centerLng, centerLng) || other.centerLng == centerLng)&&(identical(other.radiusM, radiusM) || other.radiusM == radiusM)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,city,countryCode,currency,timezone,centerLat,centerLng,radiusM,isActive);

@override
String toString() {
  return 'Zone(id: $id, name: $name, city: $city, countryCode: $countryCode, currency: $currency, timezone: $timezone, centerLat: $centerLat, centerLng: $centerLng, radiusM: $radiusM, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$ZoneCopyWith<$Res> implements $ZoneCopyWith<$Res> {
  factory _$ZoneCopyWith(_Zone value, $Res Function(_Zone) _then) = __$ZoneCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String city, String countryCode, String currency, String timezone, double centerLat, double centerLng, int radiusM, bool isActive
});




}
/// @nodoc
class __$ZoneCopyWithImpl<$Res>
    implements _$ZoneCopyWith<$Res> {
  __$ZoneCopyWithImpl(this._self, this._then);

  final _Zone _self;
  final $Res Function(_Zone) _then;

/// Create a copy of Zone
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? city = null,Object? countryCode = null,Object? currency = null,Object? timezone = null,Object? centerLat = null,Object? centerLng = null,Object? radiusM = null,Object? isActive = null,}) {
  return _then(_Zone(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,centerLat: null == centerLat ? _self.centerLat : centerLat // ignore: cast_nullable_to_non_nullable
as double,centerLng: null == centerLng ? _self.centerLng : centerLng // ignore: cast_nullable_to_non_nullable
as double,radiusM: null == radiusM ? _self.radiusM : radiusM // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PricingRule {

 String get zoneId; Service get service; int get baseFee; int get perKmFee; int get minFee; int get maxFee; double get detourFactor; int get roundingStep; int get courierBase; int get courierPerKm;
/// Create a copy of PricingRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PricingRuleCopyWith<PricingRule> get copyWith => _$PricingRuleCopyWithImpl<PricingRule>(this as PricingRule, _$identity);

  /// Serializes this PricingRule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PricingRule&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.service, service) || other.service == service)&&(identical(other.baseFee, baseFee) || other.baseFee == baseFee)&&(identical(other.perKmFee, perKmFee) || other.perKmFee == perKmFee)&&(identical(other.minFee, minFee) || other.minFee == minFee)&&(identical(other.maxFee, maxFee) || other.maxFee == maxFee)&&(identical(other.detourFactor, detourFactor) || other.detourFactor == detourFactor)&&(identical(other.roundingStep, roundingStep) || other.roundingStep == roundingStep)&&(identical(other.courierBase, courierBase) || other.courierBase == courierBase)&&(identical(other.courierPerKm, courierPerKm) || other.courierPerKm == courierPerKm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,zoneId,service,baseFee,perKmFee,minFee,maxFee,detourFactor,roundingStep,courierBase,courierPerKm);

@override
String toString() {
  return 'PricingRule(zoneId: $zoneId, service: $service, baseFee: $baseFee, perKmFee: $perKmFee, minFee: $minFee, maxFee: $maxFee, detourFactor: $detourFactor, roundingStep: $roundingStep, courierBase: $courierBase, courierPerKm: $courierPerKm)';
}


}

/// @nodoc
abstract mixin class $PricingRuleCopyWith<$Res>  {
  factory $PricingRuleCopyWith(PricingRule value, $Res Function(PricingRule) _then) = _$PricingRuleCopyWithImpl;
@useResult
$Res call({
 String zoneId, Service service, int baseFee, int perKmFee, int minFee, int maxFee, double detourFactor, int roundingStep, int courierBase, int courierPerKm
});




}
/// @nodoc
class _$PricingRuleCopyWithImpl<$Res>
    implements $PricingRuleCopyWith<$Res> {
  _$PricingRuleCopyWithImpl(this._self, this._then);

  final PricingRule _self;
  final $Res Function(PricingRule) _then;

/// Create a copy of PricingRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? zoneId = null,Object? service = null,Object? baseFee = null,Object? perKmFee = null,Object? minFee = null,Object? maxFee = null,Object? detourFactor = null,Object? roundingStep = null,Object? courierBase = null,Object? courierPerKm = null,}) {
  return _then(_self.copyWith(
zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as Service,baseFee: null == baseFee ? _self.baseFee : baseFee // ignore: cast_nullable_to_non_nullable
as int,perKmFee: null == perKmFee ? _self.perKmFee : perKmFee // ignore: cast_nullable_to_non_nullable
as int,minFee: null == minFee ? _self.minFee : minFee // ignore: cast_nullable_to_non_nullable
as int,maxFee: null == maxFee ? _self.maxFee : maxFee // ignore: cast_nullable_to_non_nullable
as int,detourFactor: null == detourFactor ? _self.detourFactor : detourFactor // ignore: cast_nullable_to_non_nullable
as double,roundingStep: null == roundingStep ? _self.roundingStep : roundingStep // ignore: cast_nullable_to_non_nullable
as int,courierBase: null == courierBase ? _self.courierBase : courierBase // ignore: cast_nullable_to_non_nullable
as int,courierPerKm: null == courierPerKm ? _self.courierPerKm : courierPerKm // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PricingRule].
extension PricingRulePatterns on PricingRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PricingRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PricingRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PricingRule value)  $default,){
final _that = this;
switch (_that) {
case _PricingRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PricingRule value)?  $default,){
final _that = this;
switch (_that) {
case _PricingRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String zoneId,  Service service,  int baseFee,  int perKmFee,  int minFee,  int maxFee,  double detourFactor,  int roundingStep,  int courierBase,  int courierPerKm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PricingRule() when $default != null:
return $default(_that.zoneId,_that.service,_that.baseFee,_that.perKmFee,_that.minFee,_that.maxFee,_that.detourFactor,_that.roundingStep,_that.courierBase,_that.courierPerKm);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String zoneId,  Service service,  int baseFee,  int perKmFee,  int minFee,  int maxFee,  double detourFactor,  int roundingStep,  int courierBase,  int courierPerKm)  $default,) {final _that = this;
switch (_that) {
case _PricingRule():
return $default(_that.zoneId,_that.service,_that.baseFee,_that.perKmFee,_that.minFee,_that.maxFee,_that.detourFactor,_that.roundingStep,_that.courierBase,_that.courierPerKm);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String zoneId,  Service service,  int baseFee,  int perKmFee,  int minFee,  int maxFee,  double detourFactor,  int roundingStep,  int courierBase,  int courierPerKm)?  $default,) {final _that = this;
switch (_that) {
case _PricingRule() when $default != null:
return $default(_that.zoneId,_that.service,_that.baseFee,_that.perKmFee,_that.minFee,_that.maxFee,_that.detourFactor,_that.roundingStep,_that.courierBase,_that.courierPerKm);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PricingRule implements PricingRule {
  const _PricingRule({required this.zoneId, required this.service, required this.baseFee, required this.perKmFee, required this.minFee, required this.maxFee, this.detourFactor = 1.3, this.roundingStep = 25, required this.courierBase, required this.courierPerKm});
  factory _PricingRule.fromJson(Map<String, dynamic> json) => _$PricingRuleFromJson(json);

@override final  String zoneId;
@override final  Service service;
@override final  int baseFee;
@override final  int perKmFee;
@override final  int minFee;
@override final  int maxFee;
@override@JsonKey() final  double detourFactor;
@override@JsonKey() final  int roundingStep;
@override final  int courierBase;
@override final  int courierPerKm;

/// Create a copy of PricingRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PricingRuleCopyWith<_PricingRule> get copyWith => __$PricingRuleCopyWithImpl<_PricingRule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PricingRuleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PricingRule&&(identical(other.zoneId, zoneId) || other.zoneId == zoneId)&&(identical(other.service, service) || other.service == service)&&(identical(other.baseFee, baseFee) || other.baseFee == baseFee)&&(identical(other.perKmFee, perKmFee) || other.perKmFee == perKmFee)&&(identical(other.minFee, minFee) || other.minFee == minFee)&&(identical(other.maxFee, maxFee) || other.maxFee == maxFee)&&(identical(other.detourFactor, detourFactor) || other.detourFactor == detourFactor)&&(identical(other.roundingStep, roundingStep) || other.roundingStep == roundingStep)&&(identical(other.courierBase, courierBase) || other.courierBase == courierBase)&&(identical(other.courierPerKm, courierPerKm) || other.courierPerKm == courierPerKm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,zoneId,service,baseFee,perKmFee,minFee,maxFee,detourFactor,roundingStep,courierBase,courierPerKm);

@override
String toString() {
  return 'PricingRule(zoneId: $zoneId, service: $service, baseFee: $baseFee, perKmFee: $perKmFee, minFee: $minFee, maxFee: $maxFee, detourFactor: $detourFactor, roundingStep: $roundingStep, courierBase: $courierBase, courierPerKm: $courierPerKm)';
}


}

/// @nodoc
abstract mixin class _$PricingRuleCopyWith<$Res> implements $PricingRuleCopyWith<$Res> {
  factory _$PricingRuleCopyWith(_PricingRule value, $Res Function(_PricingRule) _then) = __$PricingRuleCopyWithImpl;
@override @useResult
$Res call({
 String zoneId, Service service, int baseFee, int perKmFee, int minFee, int maxFee, double detourFactor, int roundingStep, int courierBase, int courierPerKm
});




}
/// @nodoc
class __$PricingRuleCopyWithImpl<$Res>
    implements _$PricingRuleCopyWith<$Res> {
  __$PricingRuleCopyWithImpl(this._self, this._then);

  final _PricingRule _self;
  final $Res Function(_PricingRule) _then;

/// Create a copy of PricingRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? zoneId = null,Object? service = null,Object? baseFee = null,Object? perKmFee = null,Object? minFee = null,Object? maxFee = null,Object? detourFactor = null,Object? roundingStep = null,Object? courierBase = null,Object? courierPerKm = null,}) {
  return _then(_PricingRule(
zoneId: null == zoneId ? _self.zoneId : zoneId // ignore: cast_nullable_to_non_nullable
as String,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as Service,baseFee: null == baseFee ? _self.baseFee : baseFee // ignore: cast_nullable_to_non_nullable
as int,perKmFee: null == perKmFee ? _self.perKmFee : perKmFee // ignore: cast_nullable_to_non_nullable
as int,minFee: null == minFee ? _self.minFee : minFee // ignore: cast_nullable_to_non_nullable
as int,maxFee: null == maxFee ? _self.maxFee : maxFee // ignore: cast_nullable_to_non_nullable
as int,detourFactor: null == detourFactor ? _self.detourFactor : detourFactor // ignore: cast_nullable_to_non_nullable
as double,roundingStep: null == roundingStep ? _self.roundingStep : roundingStep // ignore: cast_nullable_to_non_nullable
as int,courierBase: null == courierBase ? _self.courierBase : courierBase // ignore: cast_nullable_to_non_nullable
as int,courierPerKm: null == courierPerKm ? _self.courierPerKm : courierPerKm // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Address {

 String? get id; String get label; String get district; String get landmark; String? get instructions; double get latitude; double get longitude; String? get city; bool get isDefault;
/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressCopyWith<Address> get copyWith => _$AddressCopyWithImpl<Address>(this as Address, _$identity);

  /// Serializes this Address to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Address&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.district, district) || other.district == district)&&(identical(other.landmark, landmark) || other.landmark == landmark)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.city, city) || other.city == city)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,district,landmark,instructions,latitude,longitude,city,isDefault);

@override
String toString() {
  return 'Address(id: $id, label: $label, district: $district, landmark: $landmark, instructions: $instructions, latitude: $latitude, longitude: $longitude, city: $city, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class $AddressCopyWith<$Res>  {
  factory $AddressCopyWith(Address value, $Res Function(Address) _then) = _$AddressCopyWithImpl;
@useResult
$Res call({
 String? id, String label, String district, String landmark, String? instructions, double latitude, double longitude, String? city, bool isDefault
});




}
/// @nodoc
class _$AddressCopyWithImpl<$Res>
    implements $AddressCopyWith<$Res> {
  _$AddressCopyWithImpl(this._self, this._then);

  final Address _self;
  final $Res Function(Address) _then;

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? label = null,Object? district = null,Object? landmark = null,Object? instructions = freezed,Object? latitude = null,Object? longitude = null,Object? city = freezed,Object? isDefault = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,landmark: null == landmark ? _self.landmark : landmark // ignore: cast_nullable_to_non_nullable
as String,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Address].
extension AddressPatterns on Address {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Address value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Address() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Address value)  $default,){
final _that = this;
switch (_that) {
case _Address():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Address value)?  $default,){
final _that = this;
switch (_that) {
case _Address() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String label,  String district,  String landmark,  String? instructions,  double latitude,  double longitude,  String? city,  bool isDefault)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Address() when $default != null:
return $default(_that.id,_that.label,_that.district,_that.landmark,_that.instructions,_that.latitude,_that.longitude,_that.city,_that.isDefault);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String label,  String district,  String landmark,  String? instructions,  double latitude,  double longitude,  String? city,  bool isDefault)  $default,) {final _that = this;
switch (_that) {
case _Address():
return $default(_that.id,_that.label,_that.district,_that.landmark,_that.instructions,_that.latitude,_that.longitude,_that.city,_that.isDefault);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String label,  String district,  String landmark,  String? instructions,  double latitude,  double longitude,  String? city,  bool isDefault)?  $default,) {final _that = this;
switch (_that) {
case _Address() when $default != null:
return $default(_that.id,_that.label,_that.district,_that.landmark,_that.instructions,_that.latitude,_that.longitude,_that.city,_that.isDefault);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Address extends Address {
  const _Address({this.id, this.label = 'Maison', required this.district, required this.landmark, this.instructions, required this.latitude, required this.longitude, this.city, this.isDefault = false}): super._();
  factory _Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);

@override final  String? id;
@override@JsonKey() final  String label;
@override final  String district;
@override final  String landmark;
@override final  String? instructions;
@override final  double latitude;
@override final  double longitude;
@override final  String? city;
@override@JsonKey() final  bool isDefault;

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressCopyWith<_Address> get copyWith => __$AddressCopyWithImpl<_Address>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Address&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.district, district) || other.district == district)&&(identical(other.landmark, landmark) || other.landmark == landmark)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.city, city) || other.city == city)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,district,landmark,instructions,latitude,longitude,city,isDefault);

@override
String toString() {
  return 'Address(id: $id, label: $label, district: $district, landmark: $landmark, instructions: $instructions, latitude: $latitude, longitude: $longitude, city: $city, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class _$AddressCopyWith<$Res> implements $AddressCopyWith<$Res> {
  factory _$AddressCopyWith(_Address value, $Res Function(_Address) _then) = __$AddressCopyWithImpl;
@override @useResult
$Res call({
 String? id, String label, String district, String landmark, String? instructions, double latitude, double longitude, String? city, bool isDefault
});




}
/// @nodoc
class __$AddressCopyWithImpl<$Res>
    implements _$AddressCopyWith<$Res> {
  __$AddressCopyWithImpl(this._self, this._then);

  final _Address _self;
  final $Res Function(_Address) _then;

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? label = null,Object? district = null,Object? landmark = null,Object? instructions = freezed,Object? latitude = null,Object? longitude = null,Object? city = freezed,Object? isDefault = null,}) {
  return _then(_Address(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,landmark: null == landmark ? _self.landmark : landmark // ignore: cast_nullable_to_non_nullable
as String,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
