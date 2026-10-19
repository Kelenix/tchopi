import 'dart:io';

import 'package:core/src/auth/domain/app_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('les codes Auth deviennent des codes stables', () {
    expect(
      toFailure(const AuthException('x', code: 'invalid_credentials')).code,
      'invalid_credentials',
    );
    expect(
      toFailure(const AuthException('x', code: 'email_exists')).code,
      'user_already_exists',
    );
    expect(
      toFailure(const AuthException('x', code: 'otp_expired')).code,
      'code_invalid',
    );
    expect(
      toFailure(const AuthException('x', code: 'user_banned')).code,
      'account_suspended',
    );
    expect(
      toFailure(const AuthException('x', code: 'sms_send_failed')).code,
      'sms_failed',
    );
    expect(
      toFailure(const AuthException('x', code: 'inconnu')).code,
      'unknown',
    );
  });

  test('session refusée ou compte supprimé : se reconnecter', () {
    for (final code in ['session_not_found', 'user_not_found', 'bad_jwt']) {
      expect(toFailure(AuthException('x', code: code)).code, 'session_expired');
    }
    expect(
      toFailure(
        const PostgrestException(message: 'JWT', code: 'PGRST301'),
      ).code,
      'session_expired',
    );
  });

  test('les coupures réseau sont reconnues', () {
    expect(toFailure(const SocketException('hors ligne')).code, 'network');
    expect(toFailure(AuthRetryableFetchException()).code, 'network');
  });

  test('les refus métier de la base gardent leur code', () {
    expect(
      toFailure(
        const PostgrestException(message: 'active_order', code: 'P0001'),
      ).code,
      'active_order',
    );
  });

  test('toute autre erreur reste muette', () {
    expect(toFailure(StateError('détail interne')).code, 'unknown');
  });
}
