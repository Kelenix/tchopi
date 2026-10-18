// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Zone _$ZoneFromJson(Map<String, dynamic> json) => _Zone(
  id: json['id'] as String,
  name: json['name'] as String,
  city: json['city'] as String,
  countryCode: json['country_code'] as String? ?? 'CI',
  currency: json['currency'] as String? ?? 'XOF',
  timezone: json['timezone'] as String? ?? 'Africa/Abidjan',
  centerLat: (json['center_lat'] as num).toDouble(),
  centerLng: (json['center_lng'] as num).toDouble(),
  radiusM: (json['radius_m'] as num).toInt(),
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$ZoneToJson(_Zone instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'city': instance.city,
  'country_code': instance.countryCode,
  'currency': instance.currency,
  'timezone': instance.timezone,
  'center_lat': instance.centerLat,
  'center_lng': instance.centerLng,
  'radius_m': instance.radiusM,
  'is_active': instance.isActive,
};

_PricingRule _$PricingRuleFromJson(Map<String, dynamic> json) => _PricingRule(
  zoneId: json['zone_id'] as String,
  service: $enumDecode(_$ServiceEnumMap, json['service']),
  baseFee: (json['base_fee'] as num).toInt(),
  perKmFee: (json['per_km_fee'] as num).toInt(),
  minFee: (json['min_fee'] as num).toInt(),
  maxFee: (json['max_fee'] as num).toInt(),
  detourFactor: (json['detour_factor'] as num?)?.toDouble() ?? 1.3,
  roundingStep: (json['rounding_step'] as num?)?.toInt() ?? 25,
  courierBase: (json['courier_base'] as num).toInt(),
  courierPerKm: (json['courier_per_km'] as num).toInt(),
);

Map<String, dynamic> _$PricingRuleToJson(_PricingRule instance) =>
    <String, dynamic>{
      'zone_id': instance.zoneId,
      'service': _$ServiceEnumMap[instance.service]!,
      'base_fee': instance.baseFee,
      'per_km_fee': instance.perKmFee,
      'min_fee': instance.minFee,
      'max_fee': instance.maxFee,
      'detour_factor': instance.detourFactor,
      'rounding_step': instance.roundingStep,
      'courier_base': instance.courierBase,
      'courier_per_km': instance.courierPerKm,
    };

const _$ServiceEnumMap = {Service.food: 'food', Service.parcel: 'parcel'};

_Address _$AddressFromJson(Map<String, dynamic> json) => _Address(
  id: json['id'] as String?,
  label: json['label'] as String? ?? 'Maison',
  district: json['district'] as String,
  landmark: json['landmark'] as String,
  instructions: json['instructions'] as String?,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  city: json['city'] as String?,
  isDefault: json['is_default'] as bool? ?? false,
);

Map<String, dynamic> _$AddressToJson(_Address instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'district': instance.district,
  'landmark': instance.landmark,
  'instructions': instance.instructions,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'city': instance.city,
  'is_default': instance.isDefault,
};
