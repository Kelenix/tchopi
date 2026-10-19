import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget welcomeApp(ThemeData theme) => MaterialApp(
  theme: theme,
  locale: const Locale('fr'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: const WelcomeScreen(
    headline: 'Vos plats et vos colis, livrés partout dans votre ville.',
    subtitle: 'Payez en Mobile Money, par carte ou en espèces.',
    features: [
      WelcomeFeature(Icons.storefront_outlined, 'Restaurants du quartier'),
      WelcomeFeature(Icons.inventory_2_outlined, "Colis d'un point à un autre"),
      WelcomeFeature(Icons.near_me_outlined, 'Suivi en direct'),
    ],
  ),
);

void main() {
  // Petit écran d'entrée de gamme (320 × 568 dp), police agrandie à 130 %.
  Future<void> pumpSmallScreen(WidgetTester tester, ThemeData theme) async {
    tester.view
      ..physicalSize = const Size(640, 1136)
      ..devicePixelRatio = 2;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(welcomeApp(theme));
  }

  testWidgets('affiche la promesse et les atouts sans débordement', (
    tester,
  ) async {
    await pumpSmallScreen(tester, AppTheme.light);
    await tester.pumpAndSettle();

    expect(
      find.text('Vos plats et vos colis, livrés partout dans votre ville.'),
      findsOneWidget,
    );
    expect(find.text('Suivi en direct'), findsOneWidget);
    expect(find.textContaining('tchopi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
