import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Erreur présentable : un code stable, traduit en message français par l'interface.
class AppFailure implements Exception {
  const AppFailure(this.code);

  final String code;

  static const network = AppFailure('network');
  static const unknown = AppFailure('unknown');

  @override
  String toString() => 'AppFailure($code)';
}

const _authCodes = {
  'invalid_credentials': 'invalid_credentials',
  'user_already_exists': 'user_already_exists',
  'email_exists': 'user_already_exists',
  'phone_exists': 'user_already_exists',
  'otp_expired': 'code_invalid',
  'over_email_send_rate_limit': 'rate_limited',
  'over_sms_send_rate_limit': 'rate_limited',
  'over_request_rate_limit': 'rate_limited',
  'weak_password': 'weak_password',
  'same_password': 'same_password',
  'user_banned': 'account_suspended',
  'email_not_confirmed': 'not_confirmed',
  'phone_not_confirmed': 'not_confirmed',
};

/// Convertit toute erreur d'accès au serveur en [AppFailure] ; aucun détail technique n'atteint l'écran.
AppFailure toFailure(Object error) => switch (error) {
  AppFailure() => error,
  AuthRetryableFetchException() ||
  SocketException() ||
  http.ClientException() ||
  TimeoutException() => AppFailure.network,
  AuthException(:final code) => AppFailure(_authCodes[code] ?? 'unknown'),
  PostgrestException(:final code, :final message) when code == 'P0001' =>
    AppFailure(message),
  FunctionException(:final details) => AppFailure(
    details is Map && details['code'] is String
        ? details['code'] as String
        : 'unknown',
  ),
  _ => AppFailure.unknown,
};

/// Exécute un appel serveur en convertissant ses erreurs.
Future<T> guardCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } catch (error) {
    throw toFailure(error);
  }
}
