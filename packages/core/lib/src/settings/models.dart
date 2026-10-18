import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

/// Paramètres de la plateforme (ADM-05), en secondes ; s'appliquent aux nouvelles commandes.
@freezed
abstract class PlatformSettings with _$PlatformSettings {
  const factory PlatformSettings({
    required int offerTimeoutS,
    required int restaurantTimeoutS,
    required int paymentTimeoutS,
    required int dispatchAlertS,
    required int dispatchCancelS,
    String? supportPhone,
  }) = _PlatformSettings;

  factory PlatformSettings.fromJson(Map<String, dynamic> json) =>
      _$PlatformSettingsFromJson(json);
}
