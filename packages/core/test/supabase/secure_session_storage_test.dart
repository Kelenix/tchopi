import 'package:core/src/supabase/secure_session_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SecureSessionStorage storage;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    storage = SecureSessionStorage();
  });

  test('aucune session au départ', () async {
    expect(await storage.hasAccessToken(), isFalse);
    expect(await storage.accessToken(), isNull);
  });

  test('conserve puis efface la session', () async {
    await storage.persistSession('{"access_token":"jeton"}');
    expect(await storage.hasAccessToken(), isTrue);
    expect(await storage.accessToken(), '{"access_token":"jeton"}');

    await storage.removePersistedSession();
    expect(await storage.hasAccessToken(), isFalse);
  });
}
