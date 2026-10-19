// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'311cf5e4a0f378a02851703064d36ddb584fa042';

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileRepository,
          ProfileRepository,
          ProfileRepository
        >
    with $Provider<ProfileRepository> {
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'ae38b14b12f65cba9317db127821ef29f957fd3f';

/// Session courante, puis chacun de ses changements (connexion, renouvellement, déconnexion).

@ProviderFor(session)
final sessionProvider = SessionProvider._();

/// Session courante, puis chacun de ses changements (connexion, renouvellement, déconnexion).

final class SessionProvider
    extends
        $FunctionalProvider<AsyncValue<Session?>, Session?, Stream<Session?>>
    with $FutureModifier<Session?>, $StreamProvider<Session?> {
  /// Session courante, puis chacun de ses changements (connexion, renouvellement, déconnexion).
  SessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionHash();

  @$internal
  @override
  $StreamProviderElement<Session?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Session?> create(Ref ref) {
    return session(ref);
  }
}

String _$sessionHash() => r'd5c5418917a6dd0fe35127faee372f5c86cdced9';

/// Identifiant de l'utilisateur connecté. Un renouvellement de jeton garde la même valeur :
/// les providers qui en dépendent ne sont donc pas recalculés (filtrage par égalité de Riverpod).

@ProviderFor(currentUserId)
final currentUserIdProvider = CurrentUserIdProvider._();

/// Identifiant de l'utilisateur connecté. Un renouvellement de jeton garde la même valeur :
/// les providers qui en dépendent ne sont donc pas recalculés (filtrage par égalité de Riverpod).

final class CurrentUserIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Identifiant de l'utilisateur connecté. Un renouvellement de jeton garde la même valeur :
  /// les providers qui en dépendent ne sont donc pas recalculés (filtrage par égalité de Riverpod).
  CurrentUserIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentUserId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentUserIdHash() => r'6dc38f6ccfb502b4213e09de6a6365fa7fb2b6a3';

@ProviderFor(CurrentProfile)
final currentProfileProvider = CurrentProfileProvider._();

final class CurrentProfileProvider
    extends $AsyncNotifierProvider<CurrentProfile, Profile?> {
  CurrentProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentProfileHash();

  @$internal
  @override
  CurrentProfile create() => CurrentProfile();
}

String _$currentProfileHash() => r'0a870adbee8fddc88fae8f175da0819efc772f98';

abstract class _$CurrentProfile extends $AsyncNotifier<Profile?> {
  FutureOr<Profile?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Profile?>, Profile?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Profile?>, Profile?>,
              AsyncValue<Profile?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(accountRoles)
final accountRolesProvider = AccountRolesProvider._();

final class AccountRolesProvider
    extends
        $FunctionalProvider<
          AsyncValue<AccountRoles?>,
          AccountRoles?,
          FutureOr<AccountRoles?>
        >
    with $FutureModifier<AccountRoles?>, $FutureProvider<AccountRoles?> {
  AccountRolesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountRolesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountRolesHash();

  @$internal
  @override
  $FutureProviderElement<AccountRoles?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AccountRoles?> create(Ref ref) {
    return accountRoles(ref);
  }
}

String _$accountRolesHash() => r'31e8b6c52f457bedfe4bb1a289dda4434cebf882';

/// En cas d'erreur réseau, seul l'email est proposé (le téléphone demande un fournisseur SMS confirmé).

@ProviderFor(loginMethods)
final loginMethodsProvider = LoginMethodsProvider._();

/// En cas d'erreur réseau, seul l'email est proposé (le téléphone demande un fournisseur SMS confirmé).

final class LoginMethodsProvider
    extends
        $FunctionalProvider<
          AsyncValue<LoginMethods>,
          LoginMethods,
          FutureOr<LoginMethods>
        >
    with $FutureModifier<LoginMethods>, $FutureProvider<LoginMethods> {
  /// En cas d'erreur réseau, seul l'email est proposé (le téléphone demande un fournisseur SMS confirmé).
  LoginMethodsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginMethodsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginMethodsHash();

  @$internal
  @override
  $FutureProviderElement<LoginMethods> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LoginMethods> create(Ref ref) {
    return loginMethods(ref);
  }
}

String _$loginMethodsHash() => r'2bb055dad5e40e32556686fe0d6ca537f3eb6465';
