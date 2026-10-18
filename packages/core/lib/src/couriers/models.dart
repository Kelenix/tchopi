import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

enum VehicleType {
  motorbike,
  bicycle,
  car,
  @JsonValue('on_foot')
  onFoot;

  /// Immatriculation obligatoire pour les véhicules motorisés (règle aussi imposée par la base).
  bool get needsPlate => this == motorbike || this == car;

  String get wireName => this == onFoot ? 'on_foot' : name;
}

enum CourierStatus { pending, approved, rejected, suspended }

/// Profil livreur (COU-01) ; le statut n'est modifiable que par l'admin.
@freezed
abstract class Courier with _$Courier {
  const factory Courier({
    required String userId,
    required String zoneId,
    required VehicleType vehicleType,
    String? plateNumber,
    required String photoPath,
    required CourierStatus status,
    String? statusReason,
    @Default(false) bool isOnline,
  }) = _Courier;

  factory Courier.fromJson(Map<String, dynamic> json) =>
      _$CourierFromJson(json);
}

/// Livreur figé sur la commande à l'attribution (visible du client et du restaurant).
@freezed
abstract class CourierInfo with _$CourierInfo {
  const factory CourierInfo({
    required String firstName,
    String? phone,
    required VehicleType vehicleType,
    String? plateNumber,
  }) = _CourierInfo;

  factory CourierInfo.fromJson(Map<String, dynamic> json) =>
      _$CourierInfoFromJson(json);
}

enum OfferStatus { pending, accepted, declined, expired, cancelled }

/// Offre de mission (DIS-02), valable jusqu'à [expiresAt].
@freezed
abstract class DeliveryOffer with _$DeliveryOffer {
  const factory DeliveryOffer({
    required String id,
    required String orderId,
    required OfferStatus status,
    required DateTime expiresAt,
    required OfferSummary summary,
  }) = _DeliveryOffer;

  factory DeliveryOffer.fromJson(Map<String, dynamic> json) =>
      _$DeliveryOfferFromJson(json);
}

/// Ce que voit le livreur avant d'accepter : type, gain, distances, quartiers et repères, espèces à encaisser.
@freezed
abstract class OfferSummary with _$OfferSummary {
  const factory OfferSummary({
    required String number,
    required String type,
    String? pickupName,
    required String pickupDistrict,
    required String pickupLandmark,
    required String recipientName,
    required String dropoffDistrict,
    required String dropoffLandmark,
    String? parcelType,
    required int earning,
    required int toPickupM,
    required int tripM,
    required int cashAmount,
    @Default('XOF') String currency,
  }) = _OfferSummary;

  factory OfferSummary.fromJson(Map<String, dynamic> json) =>
      _$OfferSummaryFromJson(json);
}

/// Livreur en ligne proposé à l'admin pour une attribution manuelle (DIS-04).
@freezed
abstract class DispatchCandidate with _$DispatchCandidate {
  const factory DispatchCandidate({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
    required VehicleType vehicleType,
    String? plateNumber,
    int? distanceM,
    int? locationAgeS,
    required bool busy,
    required bool offerPending,
  }) = _DispatchCandidate;

  factory DispatchCandidate.fromJson(Map<String, dynamic> json) =>
      _$DispatchCandidateFromJson(json);
}
