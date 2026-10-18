import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const complete = Profile(
  id: 'u',
  firstName: 'Aïcha',
  lastName: 'Koné',
  phone: '+2250544183108',
  city: 'Abidjan',
);

String? redirect(
  String location, {
  bool signedIn = true,
  AsyncValue<Profile?> profile = const AsyncData(complete),
  AsyncValue<AccountRoles?> roles = const AsyncData(AccountRoles()),
  bool requiresAdmin = false,
}) => resolveRedirect(
  location: location,
  isSignedIn: signedIn,
  profile: profile,
  roles: roles,
  requiresAdmin: requiresAdmin,
  home: AppRoutes.account,
);

void main() {
  test('visiteur : écrans publics seulement', () {
    expect(redirect(AppRoutes.signUp, signedIn: false), isNull);
    expect(redirect(AppRoutes.account, signedIn: false), AppRoutes.welcome);
  });

  test('compte en chargement : écran d\'attente', () {
    expect(
      redirect(AppRoutes.account, profile: const AsyncLoading()),
      AppRoutes.loading,
    );
    expect(redirect(AppRoutes.loading, profile: const AsyncLoading()), isNull);
  });

  test('profil incomplet : saisie obligatoire', () {
    const incomplete = AsyncData<Profile?>(Profile(id: 'u'));
    expect(
      redirect(AppRoutes.account, profile: incomplete),
      AppRoutes.profileSetup,
    );
    expect(redirect(AppRoutes.profileSetup, profile: incomplete), isNull);
  });

  test('profil complet : les écrans d\'accès renvoient à l\'accueil', () {
    expect(redirect(AppRoutes.signIn), AppRoutes.account);
    expect(redirect(AppRoutes.profileSetup), AppRoutes.account);
    expect(redirect(AppRoutes.account), isNull);
  });

  test('code ou réinitialisation en cours : pas d\'interruption', () {
    expect(redirect(AppRoutes.verify, profile: const AsyncLoading()), isNull);
    expect(redirect(AppRoutes.reset), isNull);
  });

  test('back-office : réservé aux admins', () {
    expect(
      redirect(AppRoutes.account, requiresAdmin: true),
      AppRoutes.restricted,
    );
    expect(
      redirect(
        AppRoutes.account,
        requiresAdmin: true,
        roles: const AsyncData(AccountRoles(isAdmin: true)),
      ),
      isNull,
    );
  });
}
