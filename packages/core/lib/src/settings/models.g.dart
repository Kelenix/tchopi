// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlatformSettings _$PlatformSettingsFromJson(Map<String, dynamic> json) =>
    _PlatformSettings(
      offerTimeoutS: (json['offer_timeout_s'] as num).toInt(),
      restaurantTimeoutS: (json['restaurant_timeout_s'] as num).toInt(),
      paymentTimeoutS: (json['payment_timeout_s'] as num).toInt(),
      dispatchAlertS: (json['dispatch_alert_s'] as num).toInt(),
      dispatchCancelS: (json['dispatch_cancel_s'] as num).toInt(),
      supportPhone: json['support_phone'] as String?,
    );

Map<String, dynamic> _$PlatformSettingsToJson(_PlatformSettings instance) =>
    <String, dynamic>{
      'offer_timeout_s': instance.offerTimeoutS,
      'restaurant_timeout_s': instance.restaurantTimeoutS,
      'payment_timeout_s': instance.paymentTimeoutS,
      'dispatch_alert_s': instance.dispatchAlertS,
      'dispatch_cancel_s': instance.dispatchCancelS,
      'support_phone': instance.supportPhone,
    };
