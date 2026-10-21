import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/app_failure.dart';
import '../domain/login_identifier.dart';
import '../domain/models.dart';

/// Inscription, connexion, codes de vérification et mots de passe (Supabase Auth).
/// Toute erreur est convertie en [AppFailure].
class AuthRepository {
  AuthRepository(this._auth, {required this.apiUrl, required this.apiKey});

  final GoTrueClient _auth;
  final String apiUrl;
  final String apiKey;

  Session? get currentSession => _auth.currentSession;

  Stream<Session?> get sessionChanges =>
      _auth.onAuthStateChange.map((state) => state.session);

  /// Seuls les modes actifs sur le serveur sont proposés (fournisseur SMS, envoi d'emails).
  Future<LoginMethods> loginMethods() => guardCall(() async {
    final response = await http
        .get(Uri.parse('$apiUrl/auth/v1/settings'), headers: {'apikey': apiKey})
        .timeout(const Duration(seconds: 10));
    final settings = jsonDecode(response.body) as Map<String, dynamic>;
    final external = settings['external'] as Map<String, dynamic>?;
    return (
      email: external?['email'] == true,
      phone: external?['phone'] == true,
    );
  });

  Future<void> signUp(
    LoginIdentifier id,
    String password,
  ) => guardCall(() async {
    final response = id.isEmail
        ? await _auth.signUp(email: id.value, password: password)
        : await _auth.signUp(phone: id.value, password: password);
    // Avec confirmation obligatoire, Auth répond « succès » sans identité pour un compte existant.
    if (response.user?.identities?.isEmpty ?? false) {
      throw const AppFailure('user_already_exists');
    }
  });

  Future<void> signIn(LoginIdentifier id, String password) => guardCall(
    () => id.isEmail
        ? _auth.signInWithPassword(email: id.value, password: password)
        : _auth.signInWithPassword(phone: id.value, password: password),
  );

  /// Connexion ou inscription par téléphone : un seul parcours, le compte est créé s'il n'existe pas (sans doublon,
  /// le numéro est unique). Le code arrive par SMS ou, si le serveur l'a activé, par WhatsApp.
  Future<void> sendPhoneCode(String phone, {bool whatsapp = false}) =>
      guardCall(
        () => _auth.signInWithOtp(
          phone: phone,
          channel: whatsapp ? OtpChannel.whatsapp : OtpChannel.sms,
        ),
      );

  /// Google (OAuth Supabase) : retrouve le compte lié à l'adresse Google ou le crée ; retour dans l'app par
  /// [redirectTo] (lien profond déclaré dans l'app et autorisé sur le serveur).
  Future<void> signInWithGoogle(String redirectTo) => guardCall(
    () => _auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectTo,
      authScreenLaunchMode: LaunchMode.externalApplication,
      // Choix du compte Google à chaque fois : sinon le navigateur reprend en silence le dernier compte utilisé
      // (téléphone partagé, compte supprimé puis recréé).
      queryParams: const {'prompt': 'select_account'},
    ),
  );

  Future<void> verifyCode(CodeTarget target, String code) => guardCall(
    () async {
      final id = target.identifier;
      final type = switch ((target.purpose, id.kind)) {
        (CodePurpose.signup, IdentifierKind.email) => OtpType.signup,
        (CodePurpose.recovery, IdentifierKind.email) => OtpType.recovery,
        (CodePurpose.loginChange, IdentifierKind.email) => OtpType.emailChange,
        (CodePurpose.loginChange, IdentifierKind.phone) => OtpType.phoneChange,
        (CodePurpose.phoneLogin, IdentifierKind.email) => OtpType.email,
        (_, IdentifierKind.phone) => OtpType.sms,
      };
      await (id.isEmail
          ? _auth.verifyOTP(type: type, email: id.value, token: code)
          : _auth.verifyOTP(type: type, phone: id.value, token: code));
    },
  );

  Future<void> resendCode(CodeTarget target) {
    final id = target.identifier;
    return switch (target.purpose) {
      CodePurpose.recovery => requestPasswordReset(id),
      CodePurpose.phoneLogin => sendPhoneCode(
        id.value,
        whatsapp: target.whatsapp,
      ),
      CodePurpose.signup => guardCall(
        () => id.isEmail
            ? _auth.resend(type: OtpType.signup, email: id.value)
            : _auth.resend(type: OtpType.sms, phone: id.value),
      ),
      CodePurpose.loginChange => guardCall(
        () => id.isEmail
            ? _auth.resend(type: OtpType.emailChange, email: id.value)
            : _auth.resend(type: OtpType.phoneChange, phone: id.value),
      ),
    };
  }

  /// Envoie un code de réinitialisation ; la réponse est identique que le compte existe ou non.
  Future<void> requestPasswordReset(LoginIdentifier id) => guardCall(
    () => id.isEmail
        ? _auth.resetPasswordForEmail(id.value)
        : _auth.signInWithOtp(phone: id.value, shouldCreateUser: false),
  );

  /// Après vérification du code de réinitialisation (session ouverte), enregistre le nouveau mot de passe.
  Future<void> updatePassword(String password) =>
      guardCall(() => _auth.updateUser(UserAttributes(password: password)));

  /// Demande le changement d'identifiant ; il n'est effectif qu'après vérification du code envoyé au nouveau.
  Future<void> requestLoginChange(LoginIdentifier id) => guardCall(
    () => _auth.updateUser(
      id.isEmail
          ? UserAttributes(email: id.value)
          : UserAttributes(phone: id.value),
    ),
  );

  Future<void> signOut() => guardCall(() => _auth.signOut());
}
