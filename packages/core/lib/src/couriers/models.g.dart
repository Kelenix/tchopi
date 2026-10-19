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

_CourierInfo _$CourierInfoFromJson(Map<String, dynamic> json) => _CourierInfo(
  firstName: json['first_name'] as String,
  phone: json['phone'] as String?,
  vehicleType: $enumDecode(_$VehicleTypeEnumMap, json['vehicle_type']),
  plateNumber: json['plate_number'] as String?,
  photoPath: json['photo_path'] as String?,
);

Map<String, dynamic> _$CourierInfoToJson(_CourierInfo instance) =>
    <String, dynamic>{
      'first_name': instance.firstName,
      'phone': instance.phone,
      'vehicle_type': _$VehicleTypeEnumMap[instance.vehicleType]!,
      'plate_number': instance.plateNumber,
      'photo_path': instance.photoPath,
    };

_DeliveryOffer _$DeliveryOfferFromJson(Map<String, dynamic> json) =>
    _DeliveryOffer(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      status: $enumDecode(_$OfferStatusEnumMap, json['status']),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      summary: OfferSummary.fromJson(json['summary'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DeliveryOfferToJson(_DeliveryOffer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'status': _$OfferStatusEnumMap[instance.status]!,
      'expires_at': instance.expiresAt.toIso8601String(),
      'summary': instance.summary,
    };

const _$OfferStatusEnumMap = {
  OfferStatus.pending: 'pending',
  OfferStatus.accepted: 'accepted',
  OfferStatus.declined: 'declined',
  OfferStatus.expired: 'expired',
  OfferStatus.cancelled: 'cancelled',
};

_OfferSummary _$OfferSummaryFromJson(Map<String, dynamic> json) =>
    _OfferSummary(
      number: json['number'] as String,
      type: json['type'] as String,
      pickupName: json['pickup_name'] as String?,
      pickupDistrict: json['pickup_district'] as String,
      pickupLandmark: json['pickup_landmark'] as String,
      recipientName: json['recipient_name'] as String,
      dropoffDistrict: json['dropoff_district'] as String,
      dropoffLandmark: json['dropoff_landmark'] as String,
      parcelType: json['parcel_type'] as String?,
      earning: (json['earning'] as num).toInt(),
      toPickupM: (json['to_pickup_m'] as num).toInt(),
      tripM: (json['trip_m'] as num).toInt(),
      cashAmount: (json['cash_amount'] as num).toInt(),
      currency: json['currency'] as String? ?? 'XOF',
    );

Map<String, dynamic> _$OfferSummaryToJson(_OfferSummary instance) =>
    <String, dynamic>{
      'number': instance.number,
      'type': instance.type,
      'pickup_name': instance.pickupName,
      'pickup_district': instance.pickupDistrict,
      'pickup_landmark': instance.pickupLandmark,
      'recipient_name': instance.recipientName,
      'dropoff_district': instance.dropoffDistrict,
      'dropoff_landmark': instance.dropoffLandmark,
      'parcel_type': instance.parcelType,
      'earning': instance.earning,
      'to_pickup_m': instance.toPickupM,
      'trip_m': instance.tripM,
      'cash_amount': instance.cashAmount,
      'currency': instance.currency,
    };

_DispatchCandidate _$DispatchCandidateFromJson(Map<String, dynamic> json) =>
    _DispatchCandidate(
      userId: json['user_id'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      vehicleType: $enumDecode(_$VehicleTypeEnumMap, json['vehicle_type']),
      plateNumber: json['plate_number'] as String?,
      distanceM: (json['distance_m'] as num?)?.toInt(),
      locationAgeS: (json['location_age_s'] as num?)?.toInt(),
      busy: json['busy'] as bool,
      offerPending: json['offer_pending'] as bool,
    );

Map<String, dynamic> _$DispatchCandidateToJson(_DispatchCandidate instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone': instance.phone,
      'vehicle_type': _$VehicleTypeEnumMap[instance.vehicleType]!,
      'plate_number': instance.plateNumber,
      'distance_m': instance.distanceM,
      'location_age_s': instance.locationAgeS,
      'busy': instance.busy,
      'offer_pending': instance.offerPending,
    };

_CourierSummary _$CourierSummaryFromJson(Map<String, dynamic> json) =>
    _CourierSummary(
      earningsToday: (json['earnings_today'] as num?)?.toInt() ?? 0,
      deliveriesToday: (json['deliveries_today'] as num?)?.toInt() ?? 0,
      cashDue: (json['cash_due'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CourierSummaryToJson(_CourierSummary instance) =>
    <String, dynamic>{
      'earnings_today': instance.earningsToday,
      'deliveries_today': instance.deliveriesToday,
      'cash_due': instance.cashDue,
    };

_CodeResult _$CodeResultFromJson(Map<String, dynamic> json) => _CodeResult(
  delivered: json['delivered'] as bool,
  attemptsLeft: (json['attempts_left'] as num).toInt(),
  locked: json['locked'] as bool,
);

Map<String, dynamic> _$CodeResultToJson(_CodeResult instance) =>
    <String, dynamic>{
      'delivered': instance.delivered,
      'attempts_left': instance.attemptsLeft,
      'locked': instance.locked,
    };

_CourierLocation _$CourierLocationFromJson(Map<String, dynamic> json) =>
    _CourierLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recorded_at'] as String),
    );

Map<String, dynamic> _$CourierLocationToJson(_CourierLocation instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'recorded_at': instance.recordedAt.toIso8601String(),
    };
