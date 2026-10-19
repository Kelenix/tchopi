import 'package:core/core.dart';
import 'package:core/src/auth/presentation/sign_in_screen.dart';
import 'package:core/src/auth/presentation/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget signUpApp({
  required bool phoneEnabled,
  Widget home = const SignUpScreen(),
}) => ProviderScope(
  overrides: [
    phoneAuthEnabledProvider.overrideWith((ref) async => phoneEnabled),
  ],
  child: MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  ),
);

void main() {
  testWidgets(
    'sans fournisseur SMS, seule l\'inscription par email est proposée',
    (tester) async {
      await tester.pumpWidget(signUpApp(phoneEnabled: false));
      await tester.pumpAndSettle();

      expect(find.text('Téléphone'), findsNothing);
      expect(find.text('Email'), findsOneWidget);
    },
  );

  testWidgets('avec fournisseur SMS, le choix email / téléphone apparaît', (
    tester,
  ) async {
    await tester.pumpWidget(signUpApp(phoneEnabled: true));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Téléphone'));
    await tester.pumpAndSettle();
    expect(find.text('+225 07 00 00 00 00'), findsOneWidget);
  });

  testWidgets('les saisies invalides sont signalées avant tout envoi', (
    tester,
  ) async {
    await tester.pumpWidget(signUpApp(phoneEnabled: false));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'aicha@');
    await tester.enterText(find.byType(TextFormField).last, 'court');
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Adresse email invalide.'), findsOneWidget);
    expect(
      find.textContaining('8 caractères minimum, avec des lettres'),
      findsWidgets,
    );
  });

  testWidgets(
    'petit écran, grande police : connexion et inscription lisibles',
    (tester) async {
      tester.view
        ..physicalSize = const Size(640, 1136)
        ..devicePixelRatio = 2;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(() {
        tester.view.reset();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });
      for (final home in [const SignInScreen(), const SignUpScreen()]) {
        await tester.pumpWidget(signUpApp(phoneEnabled: true, home: home));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    },
  );
}
