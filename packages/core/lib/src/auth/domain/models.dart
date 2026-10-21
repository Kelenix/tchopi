import 'package:freezed_annotation/freezed_annotation.dart';

import '../../couriers/models.dart';
import 'login_identifier.dart';

part 'models.freezed.dart';
part 'models.g.dart';

@freezed
abstract class Profile with _$Profile {
  const Profile._();

  const factory Profile({
    required String id,
    String? firstName,
    String? lastName,
    String? phone,
    String? city,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  /// Prénom, nom, téléphone et ville sont exigés avant d'utiliser l'app (AUTH-03).
  bool get isComplete => [
    firstName,
    lastName,
    phone,
    city,
  ].every((value) => value?.trim().isNotEmpty ?? false);
}

@freezed
abstract class AccountRoles with _$AccountRoles {
  const factory AccountRoles({
    @Default(false) bool isAdmin,
    // Statut du profil livreur ; absent tant que le compte n'a pas demandé à devenir livreur.
    CourierStatus? courierStatus,
    // Restaurants dont le compte est gérant (espace Restaurant).
    @Default(<String>[]) List<String> restaurantIds,
  }) = _AccountRoles;

  factory AccountRoles.fromJson(Map<String, dynamic> json) =>
      _$AccountRolesFromJson(json);
}

/// Pourquoi un code de vérification est demandé.
/// `phoneLogin` : connexion ou inscription par code, sans mot de passe (écran d'accès, ADR-053).
enum CodePurpose { signup, recovery, loginChange, phoneLogin }

/// Destinataire et motif d'un code à 6 chiffres (écran S-03).
class CodeTarget {
  const CodeTarget(this.identifier, this.purpose, {this.whatsapp = false});

  final LoginIdentifier identifier;
  final CodePurpose purpose;

  /// Code envoyé par WhatsApp plutôt que par SMS (connexion par téléphone).
  final bool whatsapp;
}

/// Écran d'accès : bannière administrable et vérification WhatsApp disponible.
typedef AuthEntryConfig = ({
  String? bannerTitle,
  String? bannerBody,
  bool whatsapp,
});
