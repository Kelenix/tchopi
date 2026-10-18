import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/restaurant/presentation/menu_screen.dart';
import 'package:mobile/features/restaurant/restaurant_providers.dart';

const restaurant = Restaurant(
  id: 'r1',
  zoneId: 'z',
  name: 'Maquis Chez Tante',
  phone: '+2250701020304',
  latitude: 5.35,
  longitude: -4,
  district: 'Cocody',
  landmark: 'Carrefour de la vie',
  isOpen: true,
);

Widget app(Menu menu) => ProviderScope(
  overrides: [
    managedRestaurantIdProvider.overrideWithValue('r1'),
    managedRestaurantProvider('r1').overrideWith((ref) async => restaurant),
    restaurantMenuProvider('r1').overrideWith((ref) async => menu),
  ],
  child: MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: const MenuScreen(),
  ),
);

void main() {
  testWidgets('menu vide : invitation à ajouter un produit', (tester) async {
    await tester.pumpWidget(app((categories: [], products: [])));
    await tester.pumpAndSettle();
    expect(find.text('Ajouter un produit'), findsWidgets);
  });

  testWidgets('produits regroupés par catégorie, état d\'ouverture affiché', (
    tester,
  ) async {
    await tester.pumpWidget(
      app((
        categories: [const MenuCategory(id: 'c1', name: 'Plats')],
        products: [
          const Product(
            id: 'p1',
            restaurantId: 'r1',
            categoryId: 'c1',
            name: 'Garba',
            price: 1500,
          ),
          const Product(
            id: 'p2',
            restaurantId: 'r1',
            name: 'Bissap',
            price: 500,
          ),
        ],
      )),
    );
    await tester.pumpAndSettle();
    expect(find.text('Maquis Chez Tante'), findsOneWidget);
    expect(find.text('Ouvert'), findsOneWidget);
    expect(find.text('Plats'), findsOneWidget);
    expect(find.text('Garba'), findsOneWidget);
    expect(find.text('Sans catégorie'), findsOneWidget);
    expect(find.text('Bissap'), findsOneWidget);
  });
}
