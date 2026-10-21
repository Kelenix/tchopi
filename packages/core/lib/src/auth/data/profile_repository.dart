import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/app_failure.dart';
import '../domain/models.dart';

/// Profil du compte connecté, rôles et suppression du compte.
class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  static const _columns = 'id, first_name, last_name, phone, city';

  /// Sans profil, le compte a été supprimé depuis la connexion (le profil naît avec le compte).
  Future<Profile> fetch(String userId) => guardCall(() async {
    final row = await _client
        .from('profiles')
        .select(_columns)
        .eq('id', userId)
        .maybeSingle();
    if (row == null) throw AppFailure.sessionExpired;
    return Profile.fromJson(row);
  });

  /// Photo de profil (bucket public « media », dossier du titulaire) ; null sans photo.
  Future<String?> avatarUrl(String userId) => guardCall(() async {
    final row = await _client
        .from('profiles')
        .select('avatar_path')
        .eq('id', userId)
        .maybeSingle();
    final path = row?['avatar_path'] as String?;
    return path == null
        ? null
        : _client.storage.from('media').getPublicUrl(path);
  });

  Future<void> uploadAvatar(String userId, Uint8List jpeg) =>
      guardCall(() async {
        final path =
            'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
        await _client.storage
            .from('media')
            .uploadBinary(
              path,
              jpeg,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
        await _client
            .from('profiles')
            .update({'avatar_path': path})
            .eq('id', userId);
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
    final saved = Profile.fromJson(row);
    // Inscription terminée sur le mobile : le web ne repropose pas l'onboarding (sans effet si déjà fait).
    if (saved.isComplete) await _client.rpc<void>('complete_onboarding');
    return saved;
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
