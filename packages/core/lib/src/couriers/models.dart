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
