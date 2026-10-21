import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tchopi/features/client/client_nav_bar.dart';
import 'package:tchopi/features/orders/orders_providers.dart';

void main() {
  testWidgets('le bouton central ouvre directement les restaurants', (
    tester,
  ) async {
    Widget page(String title, int current) => Scaffold(
      body: Center(child: Text(title)),
      bottomNavigationBar: ClientNavBar(current: current),
    );

    final router = GoRouter(
      initialLocation: ClientNavBar.ordersPath,
      routes: [
        GoRoute(
          path: ClientNavBar.homePath,
          builder: (_, _) => page('Restaurants', 0),
        ),
        GoRoute(
          path: ClientNavBar.ordersPath,
          builder: (_, _) => page('Mes commandes', 1),
        ),
        GoRoute(
          path: ClientNavBar.paymentsPath,
          builder: (_, _) => page('Paiements', 2),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myOrdersProvider.overrideWith((ref) async => const <Order>[]),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Envoyer un colis'), findsNothing);
    await tester.tap(find.byTooltip('Commander un repas'));
    await tester.pumpAndSettle();

    expect(find.text('Restaurants'), findsOneWidget);
    expect(find.text('Envoyer un colis'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
