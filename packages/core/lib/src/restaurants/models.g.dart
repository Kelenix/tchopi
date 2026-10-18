// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Restaurant _$RestaurantFromJson(Map<String, dynamic> json) => _Restaurant(
  id: json['id'] as String,
  zoneId: json['zone_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  category: json['category'] as String?,
  coverPath: json['cover_path'] as String?,
  phone: json['phone'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  district: json['district'] as String,
  landmark: json['landmark'] as String,
  commissionRate: (json['commission_rate'] as num?)?.toDouble() ?? 15,
  prepTimeMin: (json['prep_time_min'] as num?)?.toInt() ?? 20,
  isActive: json['is_active'] as bool? ?? true,
  isTemporarilyClosed: json['is_temporarily_closed'] as bool? ?? false,
  isOpen: json['is_open'] as bool? ?? false,
);

Map<String, dynamic> _$RestaurantToJson(_Restaurant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'zone_id': instance.zoneId,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'cover_path': instance.coverPath,
      'phone': instance.phone,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'district': instance.district,
      'landmark': instance.landmark,
      'commission_rate': instance.commissionRate,
      'prep_time_min': instance.prepTimeMin,
      'is_active': instance.isActive,
      'is_temporarily_closed': instance.isTemporarilyClosed,
      'is_open': instance.isOpen,
    };

_OpeningHour _$OpeningHourFromJson(Map<String, dynamic> json) => _OpeningHour(
  weekday: (json['weekday'] as num).toInt(),
  opensAt: json['opens_at'] as String,
  closesAt: json['closes_at'] as String,
);

Map<String, dynamic> _$OpeningHourToJson(_OpeningHour instance) =>
    <String, dynamic>{
      'weekday': instance.weekday,
      'opens_at': instance.opensAt,
      'closes_at': instance.closesAt,
    };

_MenuCategory _$MenuCategoryFromJson(Map<String, dynamic> json) =>
    _MenuCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      position: (json['position'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$MenuCategoryToJson(_MenuCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'position': instance.position,
    };

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String?,
  restaurantId: json['restaurant_id'] as String,
  categoryId: json['category_id'] as String?,
  name: json['name'] as String,
  description: json['description'] as String?,
  price: (json['price'] as num).toInt(),
  photoPath: json['photo_path'] as String?,
  isAvailable: json['is_available'] as bool? ?? true,
  archivedAt: json['archived_at'] == null
      ? null
      : DateTime.parse(json['archived_at'] as String),
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'restaurant_id': instance.restaurantId,
  'category_id': instance.categoryId,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'photo_path': instance.photoPath,
  'is_available': instance.isAvailable,
  'archived_at': instance.archivedAt?.toIso8601String(),
};
