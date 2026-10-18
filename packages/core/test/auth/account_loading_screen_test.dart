import 'package:core/core.dart';
import 'package:core/src/auth/presentation/status_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailingProfile extends CurrentProfile {
  _FailingProfile(this.failure);

  final AppFailure failure;

  @override
  Future<Profile?> build() async => throw failure;
}

Widget app(AppFailure failure) => ProviderScope(
  overrides: [
    currentProfileProvider.overrideWith(() => _FailingProfile(failure)),
    accountRolesProvider.overrideWith((ref) async => const AccountRoles()),
  ],
  child: MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: const AccountLoadingScreen(),
  ),
);

void main() {
  testWidgets('coupure réseau : message réseau, réessayer possible', (
    tester,
  ) async {
    await tester.pumpWidget(app(AppFailure.network));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Pas de connexion internet. Vérifiez votre réseau puis réessayez.',
      ),
      findsOneWidget,
    );
    expect(find.text('Réessayer'), findsOneWidget);
    expect(find.text('Se déconnecter'), findsOneWidget);
  });

  testWidgets('session refusée ou compte supprimé : se reconnecter', (
    tester,
  ) async {
    await tester.pumpWidget(app(AppFailure.sessionExpired));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Votre session a expiré ou ce compte n\'existe plus. '
        'Reconnectez-vous pour continuer.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('connexion internet'), findsNothing);
    expect(find.text('Réessayer'), findsNothing);
    expect(find.text('Se reconnecter'), findsOneWidget);
  });
}
