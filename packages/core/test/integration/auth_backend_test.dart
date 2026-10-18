@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:core/src/auth/data/auth_repository.dart';
import 'package:core/src/auth/data/profile_repository.dart';
import 'package:core/src/auth/domain/app_failure.dart';
import 'package:core/src/auth/domain/login_identifier.dart';
import 'package:core/src/auth/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Parcours réels contre Supabase local (`supabase start`), avec les vrais dépôts de l'app.
/// Les codes email sont lus dans la boîte de test locale (Mailpit) ; le téléphone utilise un numéro de test.
void main() {
  final env =
      jsonDecode(File('../../env/local.json').readAsStringSync())
          as Map<String, dynamic>;
  final url = env['SUPABASE_URL'] as String;
  final key = env['SUPABASE_ANON_KEY'] as String;

  // Le binding de test bloque le réseau par défaut ; ces tests appellent le vrai serveur local.
  setUpAll(() => HttpOverrides.global = null);

  late SupabaseClient client;
  late AuthRepository auth;
  late ProfileRepository profiles;

  setUp(() {
    client = SupabaseClient(
      url,
      key,
      authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
    );
    auth = AuthRepository(client.auth, apiUrl: url, apiKey: key);
    profiles = ProfileRepository(client);
  });

  tearDown(() => client.dispose());

  Future<String> latestCodeFor(String email) async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:54324/api/v1/messages'),
    );
    final messages =
        (jsonDecode(response.body) as Map<String, dynamic>)['messages']
            as List<dynamic>;
    final message = messages.cast<Map<String, dynamic>>().firstWhere(
      (m) => (m['To'] as List<dynamic>).any(
        (to) => (to as Map<String, dynamic>)['Address'] == email,
      ),
    );
    return RegExp(
      r'\b\d{6}\b',
    ).firstMatch(message['Snippet'] as String)!.group(0)!;
  }

  test(
    'email : inscription, code, profil, rôles, mot de passe oublié, suppression',
    () async {
      final email = 'test${DateTime.now().microsecondsSinceEpoch}@exemple.ci';
      final id = LoginIdentifier.email(email);

      await auth.signUp(id, 'motdepasse1');
      await expectLater(
        auth.signIn(id, 'motdepasse1'),
        throwsA(
          isA<AppFailure>().having((f) => f.code, 'code', 'not_confirmed'),
        ),
      );

      await auth.verifyCode(
        CodeTarget(id, CodePurpose.signup),
        await latestCodeFor(email),
      );
      final userId = auth.currentSession!.user.id;

      final created = await profiles.fetch(userId);
      expect(created.isComplete, isFalse);
      final saved = await profiles.update(
        created.copyWith(
          firstName: 'Aïcha',
          lastName: 'Koné',
          phone: '+2250544183108',
          city: 'Abidjan',
        ),
      );
      expect(saved.isComplete, isTrue);
      expect((await profiles.roles()).isAdmin, isFalse);

      await auth.signOut();
      await expectLater(
        auth.signIn(id, 'mauvais1'),
        throwsA(
          isA<AppFailure>().having(
            (f) => f.code,
            'code',
            'invalid_credentials',
          ),
        ),
      );

      await Future<void>.delayed(const Duration(seconds: 1));
      await auth.requestPasswordReset(id);
      await auth.verifyCode(
        CodeTarget(id, CodePurpose.recovery),
        await latestCodeFor(email),
      );
      await auth.updatePassword('nouveaumdp2');
      await auth.signOut();
      await auth.signIn(id, 'nouveaumdp2');

      await profiles.deleteAccount();
      await expectLater(
        auth.signIn(id, 'nouveaumdp2'),
        throwsA(isA<AppFailure>()),
      );
    },
  );

  test('email déjà utilisé : refus explicite', () async {
    final email = 'double${DateTime.now().microsecondsSinceEpoch}@exemple.ci';
    final id = LoginIdentifier.email(email);
    await auth.signUp(id, 'motdepasse1');
    await auth.verifyCode(
      CodeTarget(id, CodePurpose.signup),
      await latestCodeFor(email),
    );
    await auth.signOut();

    await expectLater(
      auth.signUp(id, 'motdepasse1'),
      throwsA(
        isA<AppFailure>().having((f) => f.code, 'code', 'user_already_exists'),
      ),
    );
  });

  test(
    'téléphone : inscription avec un numéro de test et le profil reprend le numéro',
    () async {
      expect(await auth.isPhoneAuthEnabled(), isTrue);
      const id = LoginIdentifier.phone('+2250700000001');
      try {
        await auth.signUp(id, 'motdepasse1');
        await auth.verifyCode(
          const CodeTarget(id, CodePurpose.signup),
          '123456',
        );
      } on AppFailure catch (failure) {
        // Numéro déjà inscrit par un passage précédent : on se connecte simplement.
        if (failure.code != 'user_already_exists') rethrow;
        await auth.signIn(id, 'motdepasse1');
      }
      final profile = await profiles.fetch(auth.currentSession!.user.id);
      expect(profile.phone, '+2250700000001');
    },
  );
}
