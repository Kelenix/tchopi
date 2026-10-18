import 'package:freezed_annotation/freezed_annotation.dart';

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
  const factory AccountRoles({@Default(false) bool isAdmin}) = _AccountRoles;

  factory AccountRoles.fromJson(Map<String, dynamic> json) =>
      _$AccountRolesFromJson(json);
}

/// Pourquoi un code de vérification est demandé.
enum CodePurpose { signup, recovery, loginChange }

/// Destinataire et motif d'un code à 6 chiffres (écran S-03).
class CodeTarget {
  const CodeTarget(this.identifier, this.purpose);

  final LoginIdentifier identifier;
  final CodePurpose purpose;
}
