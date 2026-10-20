import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/application/auth_providers.dart';
import '../auth/domain/models.dart';
import '../auth/presentation/account_screen.dart';
import '../auth/presentation/login_change_screen.dart';
import '../auth/presentation/profile_form_screen.dart';
import '../auth/presentation/reset_password_screen.dart';
import '../auth/presentation/sign_in_screen.dart';
import '../auth/presentation/sign_up_screen.dart';
import '../auth/presentation/status_screens.dart';
import '../auth/presentation/verify_code_screen.dart';

abstract final class AppRoutes {
  static const welcome = '/welcome';
  static const signUp = '/sign-up';
  static const signIn = '/sign-in';
  static const verify = '/verify';
  static const reset = '/reset';
  static const loading = '/loading';
  static const profileSetup = '/profile-setup';
  static const account = '/account';

  static const public = {welcome, signUp, signIn, verify, reset};
  // Écrans de transition : quand la situation du compte est réglée, on en sort vers l'accueil.
  static const gates = {...public, loading, profileSetup};
}

/// Règle de navigation unique (AUTH-09). Le serveur reste seul juge des droits (RLS) :
/// cette règle n'évite que d'afficher un écran inutilisable.
String? resolveRedirect({
  required String location,
  required bool isSignedIn,
  required AsyncValue<Profile?> profile,
  required AsyncValue<AccountRoles?> roles,
  required String home,
  String? Function(String location, AccountRoles roles)? roleRedirect,
}) {
  String? goTo(String target) => location == target ? null : target;

  if (!isSignedIn) {
    return AppRoutes.public.contains(location) ? null : AppRoutes.welcome;
  }
  // Code de vérification ou réinitialisation en cours : l'écran termine son parcours lui-même.
  if (location == AppRoutes.verify || location == AppRoutes.reset) return null;

  final currentProfile = profile.value;
  final currentRoles = roles.value;
  if (currentProfile == null || currentRoles == null) {
    return goTo(AppRoutes.loading);
  }
  if (!currentProfile.isComplete) return goTo(AppRoutes.profileSetup);
  // Aiguillage propre à l'app (ex. app Livreur sans profil livreur → inscription livreur).
  final roleTarget = roleRedirect?.call(location, currentRoles);
  if (roleTarget != null) return goTo(roleTarget);
  return AppRoutes.gates.contains(location) || location == '/' ? home : null;
}

/// Navigation commune aux 3 apps : accès, profil, compte. L'app fournit son écran de bienvenue
/// et, à partir des incréments suivants, ses propres écrans.
GoRouter buildAppRouter(
  Ref ref, {
  required WidgetBuilder welcome,
  String home = AppRoutes.account,
  List<RouteBase> routes = const [],
  List<AccountLink> accountLinks = const [],
  Future<Uint8List?> Function(BuildContext context)? pickAvatar,
  String? Function(String location, AccountRoles roles)? roleRedirect,
}) {
  final refresh = ValueNotifier(0);
  void bump(Object? _, Object? _) => refresh.value++;
  ref
    ..listen(sessionProvider, bump)
    ..listen(currentProfileProvider, bump)
    ..listen(accountRolesProvider, bump)
    ..onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.welcome,
    refreshListenable: refresh,
    redirect: (context, state) => resolveRedirect(
      location: state.matchedLocation,
      isSignedIn: ref.read(sessionProvider).value != null,
      profile: ref.read(currentProfileProvider),
      roles: ref.read(accountRolesProvider),
      home: home,
      roleRedirect: roleRedirect,
    ),
    routes: [
      GoRoute(path: '/', redirect: (_, _) => home),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, _) => welcome(context),
      ),
      GoRoute(path: AppRoutes.signUp, builder: (_, _) => const SignUpScreen()),
      GoRoute(path: AppRoutes.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(
        path: AppRoutes.verify,
        builder: (_, state) =>
            VerifyCodeScreen(target: state.extra as CodeTarget?),
      ),
      GoRoute(
        path: AppRoutes.reset,
        builder: (_, _) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.loading,
        builder: (_, _) => const AccountLoadingScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (_, _) => const ProfileFormScreen(isSetup: true),
      ),
      GoRoute(
        path: AppRoutes.account,
        builder: (_, _) =>
            AccountScreen(links: accountLinks, pickAvatar: pickAvatar),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, _) => const ProfileFormScreen(isSetup: false),
          ),
          GoRoute(path: 'login', builder: (_, _) => const LoginChangeScreen()),
        ],
      ),
      ...routes,
    ],
  );
}
