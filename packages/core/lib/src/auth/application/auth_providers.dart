import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/env.dart';
import '../../supabase/supabase_setup.dart';
import '../data/auth_repository.dart';
import '../data/profile_repository.dart';
import '../domain/login_identifier.dart';
import '../domain/models.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepository(
  ref.watch(supabaseClientProvider).auth,
  apiUrl: Env.supabaseUrl,
  apiKey: Env.supabaseAnonKey,
);

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) =>
    ProfileRepository(ref.watch(supabaseClientProvider));

/// Session courante, puis chacun de ses changements (connexion, renouvellement, déconnexion).
@Riverpod(keepAlive: true)
Stream<Session?> session(Ref ref) async* {
  final repository = ref.watch(authRepositoryProvider);
  yield repository.currentSession;
  yield* repository.sessionChanges;
}

/// Identifiant de l'utilisateur connecté. Un renouvellement de jeton garde la même valeur :
/// les providers qui en dépendent ne sont donc pas recalculés (filtrage par égalité de Riverpod).
@Riverpod(keepAlive: true)
String? currentUserId(Ref ref) => ref.watch(sessionProvider).value?.user.id;

@Riverpod(keepAlive: true)
class CurrentProfile extends _$CurrentProfile {
  @override
  Future<Profile?> build() async {
    final userId = ref.watch(currentUserIdProvider);
    return userId == null
        ? null
        : ref.watch(profileRepositoryProvider).fetch(userId);
  }

  Future<void> save(Profile profile) async {
    state = AsyncData(
      await ref.read(profileRepositoryProvider).update(profile),
    );
  }
}

@Riverpod(keepAlive: true)
Future<AccountRoles?> accountRoles(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  return userId == null ? null : ref.watch(profileRepositoryProvider).roles();
}

/// En cas d'erreur réseau, seul l'email est proposé (le téléphone demande un fournisseur SMS confirmé).
@riverpod
Future<LoginMethods> loginMethods(Ref ref) => ref
    .watch(authRepositoryProvider)
    .loginMethods()
    .catchError((_) => (email: true, phone: false));
