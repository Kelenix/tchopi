import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/app_failure.dart';
import '../domain/models.dart';

/// Profil du compte connecté, rôles et suppression du compte.
class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  static const _columns = 'id, first_name, last_name, phone, city';

  Future<Profile> fetch(String userId) => guardCall(() async {
    final row = await _client
        .from('profiles')
        .select(_columns)
        .eq('id', userId)
        .single();
    return Profile.fromJson(row);
  });

  Future<Profile> update(Profile profile) => guardCall(() async {
    final row = await _client
        .from('profiles')
        .update({
          'first_name': profile.firstName?.trim(),
          'last_name': profile.lastName?.trim(),
          'phone': profile.phone,
          'city': profile.city?.trim(),
        })
        .eq('id', profile.id)
        .select(_columns)
        .single();
    return Profile.fromJson(row);
  });

  Future<AccountRoles> roles() => guardCall(() async {
    final json = await _client.rpc<Map<String, dynamic>>('my_roles');
    return AccountRoles.fromJson(json);
  });

  /// Anonymise le profil et supprime l'accès au compte (fonction serveur `account-delete`).
  Future<void> deleteAccount() => guardCall(() async {
    await _client.functions.invoke('account-delete');
    await _client.auth.signOut(scope: SignOutScope.local);
  });
}
