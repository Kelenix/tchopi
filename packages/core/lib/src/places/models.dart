import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

/// Zone desservie : une ville, un centre et un rayon (H-02).
@freezed
abstract class Zone with _$Zone {
  const factory Zone({
    required String id,
    required String name,
    required String city,
    @Default('CI') String countryCode,
    @Default('XOF') String currency,
    @Default('Africa/Abidjan') String timezone,
    required double centerLat,
    required double centerLng,
    required int radiusM,
    @Default(true) bool isActive,
  }) = _Zone;

  factory Zone.fromJson(Map<String, dynamic> json) => _$ZoneFromJson(json);
}

enum Service { food, parcel }

/// Règle tarifaire d'une zone pour un service (H-04). Montants en unités de la devise.
@freezed
abstract class PricingRule with _$PricingRule {
  const factory PricingRule({
    required String zoneId,
    required Service service,
    required int baseFee,
    required int perKmFee,
    required int minFee,
    required int maxFee,
    @Default(1.3) double detourFactor,
    @Default(25) int roundingStep,
    required int courierBase,
    required int courierPerKm,
  }) = _PricingRule;

  factory PricingRule.fromJson(Map<String, dynamic> json) =>
      _$PricingRuleFromJson(json);
}

/// Adresse sans nom de rue : position, quartier, point de repère, instructions (ADR-02).
/// Zone et ville sont déduites de la position par le serveur.
@freezed
abstract class Address with _$Address {
  const Address._();

  const factory Address({
    String? id,
    @Default('Maison') String label,
    required String district,
    required String landmark,
    String? instructions,
    required double latitude,
    required double longitude,
    String? city,
    @Default(false) bool isDefault,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  /// Champs modifiables depuis l'app (la zone et la ville sont calculées par la base).
  Map<String, dynamic> toWritableJson() => {
    'label': label.trim(),
    'district': district.trim(),
    'landmark': landmark.trim(),
    'instructions': (instructions?.trim().isEmpty ?? true)
        ? null
        : instructions!.trim(),
    'latitude': latitude,
    'longitude': longitude,
  };
}
