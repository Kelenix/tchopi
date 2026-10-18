// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  phone: json['phone'] as String?,
  city: json['city'] as String?,
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'phone': instance.phone,
  'city': instance.city,
};

_AccountRoles _$AccountRolesFromJson(Map<String, dynamic> json) =>
    _AccountRoles(
      isAdmin: json['is_admin'] as bool? ?? false,
      courierStatus: $enumDecodeNullable(
        _$CourierStatusEnumMap,
        json['courier_status'],
      ),
      restaurantIds:
          (json['restaurant_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$AccountRolesToJson(_AccountRoles instance) =>
    <String, dynamic>{
      'is_admin': instance.isAdmin,
      'courier_status': _$CourierStatusEnumMap[instance.courierStatus],
      'restaurant_ids': instance.restaurantIds,
    };

const _$CourierStatusEnumMap = {
  CourierStatus.pending: 'pending',
  CourierStatus.approved: 'approved',
  CourierStatus.rejected: 'rejected',
  CourierStatus.suspended: 'suspended',
};
