import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/app_failure.dart';
import '../domain/login_identifier.dart';
import '../domain/models.dart';
import 'auth_providers.dart';

part 'auth_controllers.g.dart';

/// État d'envoi d'un formulaire : au repos, en cours, ou erreur présentable ([AppFailure]).
/// Un écran = une instance (clé [form]) ; chaque action renvoie `true` si elle a réussi.
@riverpod
class FormSubmission extends _$FormSubmission {
  @override
  AsyncValue<void> build(String form) => const AsyncData(null);

  Future<bool> run(Future<void> Function() action) async {
    if (state.isLoading) return false; // protège du double toucher
    state = const AsyncLoading();
    final result = await AsyncValue.guard(action);
    if (ref.mounted) state = result;
    return !result.hasError;
  }

  void clearError() => state = const AsyncData(null);
}

/// Parcours d'authentification : chaque méthode enchaîne les appels nécessaires à un écran.
class AuthFlows {
  AuthFlows(this._ref);

  final Ref _ref;

  Future<void> signUp(LoginIdentifier id, String password) =>
      _ref.read(authRepositoryProvider).signUp(id, password);

  /// Connexion ; un compte jamais vérifié reçoit un nouveau code et l'écran de vérification s'ouvre.
  Future<void> signIn(LoginIdentifier id, String password) async {
    final repository = _ref.read(authRepositoryProvider);
    try {
      await repository.signIn(id, password);
    } on AppFailure catch (failure) {
      if (failure.code != 'not_confirmed') rethrow;
      await repository.resendCode(CodeTarget(id, CodePurpose.signup));
      rethrow;
    }
  }

  Future<void> verify(CodeTarget target, String code) =>
      _ref.read(authRepositoryProvider).verifyCode(target, code);

  Future<void> resend(CodeTarget target) =>
      _ref.read(authRepositoryProvider).resendCode(target);

  Future<void> requestPasswordReset(LoginIdentifier id) =>
      _ref.read(authRepositoryProvider).requestPasswordReset(id);

  /// Vérifie le code de réinitialisation puis enregistre le nouveau mot de passe, en une étape.
  Future<void> resetPassword(
    LoginIdentifier id,
    String code,
    String newPassword,
  ) async {
    final repository = _ref.read(authRepositoryProvider);
    await repository.verifyCode(CodeTarget(id, CodePurpose.recovery), code);
    await repository.updatePassword(newPassword);
  }

  Future<void> saveProfile(Profile profile) =>
      _ref.read(currentProfileProvider.notifier).save(profile);

  Future<void> requestLoginChange(LoginIdentifier id) =>
      _ref.read(authRepositoryProvider).requestLoginChange(id);

  Future<void> signOut() => _ref.read(authRepositoryProvider).signOut();

  Future<void> deleteAccount() =>
      _ref.read(profileRepositoryProvider).deleteAccount();
}

@riverpod
AuthFlows authFlows(Ref ref) => AuthFlows(ref);
