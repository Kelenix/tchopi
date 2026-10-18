// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Courier _$CourierFromJson(Map<String, dynamic> json) => _Courier(
  userId: json['user_id'] as String,
  zoneId: json['zone_id'] as String,
  vehicleType: $enumDecode(_$VehicleTypeEnumMap, json['vehicle_type']),
  plateNumber: json['plate_number'] as String?,
  photoPath: json['photo_path'] as String,
  status: $enumDecode(_$CourierStatusEnumMap, json['status']),
  statusReason: json['status_reason'] as String?,
  isOnline: json['is_online'] as bool? ?? false,
);

Map<String, dynamic> _$CourierToJson(_Courier instance) => <String, dynamic>{
  'user_id': instance.userId,
  'zone_id': instance.zoneId,
  'vehicle_type': _$VehicleTypeEnumMap[instance.vehicleType]!,
  'plate_number': instance.plateNumber,
  'photo_path': instance.photoPath,
  'status': _$CourierStatusEnumMap[instance.status]!,
  'status_reason': instance.statusReason,
  'is_online': instance.isOnline,
};

const _$VehicleTypeEnumMap = {
  VehicleType.motorbike: 'motorbike',
  VehicleType.bicycle: 'bicycle',
  VehicleType.car: 'car',
  VehicleType.onFoot: 'on_foot',
};

const _$CourierStatusEnumMap = {
  CourierStatus.pending: 'pending',
  CourierStatus.approved: 'approved',
  CourierStatus.rejected: 'rejected',
  CourierStatus.suspended: 'suspended',
};
