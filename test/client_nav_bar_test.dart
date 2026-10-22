import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tchopi/features/client/client_nav_bar.dart';
import 'package:tchopi/features/client/home/catalog_providers.dart';
import 'package:tchopi/features/orders/orders_providers.dart';

void main() {
  testWidgets('le bouton central propose de commander dans un restaurant', (
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
          catalogRestaurantsProvider.overrideWith(
            (ref) async => const [
              Restaurant(
                id: 'r1',
                zoneId: 'z',
                name: 'Maquis Chez Tante',
                phone: '+2250701020304',
                latitude: 5.35,
                longitude: -4,
                district: 'Cocody',
                landmark: 'Carrefour',
                isOpen: true,
              ),
            ],
          ),
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
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(
      find.text('Choisissez un restaurant, puis vos plats.'),
      findsOneWidget,
    );
    expect(find.text('Maquis Chez Tante'), findsOneWidget);
    expect(find.text('Envoyer un colis'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
