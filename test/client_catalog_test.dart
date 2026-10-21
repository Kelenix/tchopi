import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tchopi/features/client/addresses/application/addresses_providers.dart';
import 'package:tchopi/features/client/home/catalog_providers.dart';
import 'package:tchopi/features/client/home/client_home_screen.dart';
import 'package:tchopi/features/client/home/featured_dishes.dart';
import 'package:tchopi/features/client/home/product_options.dart';
import 'package:tchopi/features/client/home/restaurant_detail_screen.dart';
import 'package:tchopi/features/restaurant/restaurant_providers.dart';

import 'small_screen.dart';

const restaurant = Restaurant(
  id: 'r1',
  zoneId: 'z',
  name: 'Maquis Chez Tante',
  category: 'Ivoirien',
  phone: '+2250701020304',
  latitude: 5.35,
  longitude: -4,
  district: 'Cocody',
  landmark: 'Carrefour de la vie',
  isOpen: true,
);

class _FakeProfile extends CurrentProfile {
  @override
  Future<Profile?> build() async => const Profile(id: 'u', firstName: 'Awa');
}

class _FakeAddresses extends Addresses {
  @override
  Future<List<Address>> build() async => const [
    Address(
      id: 'a',
      district: 'Riviera 2',
      landmark: 'Pharmacie',
      latitude: 5.36,
      longitude: -3.97,
      isDefault: true,
    ),
  ];
}

Widget app(
  Widget home, {
  Map<String, List<OptionGroup>> options = const {},
  Duration optionsDelay = Duration.zero,
}) => ProviderScope(
  overrides: [
    currentProfileProvider.overrideWith(_FakeProfile.new),
    addressesProvider.overrideWith(_FakeAddresses.new),
    catalogRestaurantsProvider.overrideWith((ref) async => [restaurant]),
    featuredDishesProvider('z').overrideWith(
      (ref) async => [
        for (final n in ['Garba', 'Alloco', 'Poulet braisé'])
          (
            id: n,
            establishmentId: 'r1',
            establishmentName: 'Maquis Chez Tante',
            name: n,
            price: 1500,
            photoPath: null,
            isOpen: true,
          ),
      ],
    ),
    catalogRestaurantProvider('r1').overrideWith((ref) async => restaurant),
    productOptionsProvider('r1').overrideWith((ref) async {
      if (optionsDelay != Duration.zero) {
        await Future<void>.delayed(optionsDelay);
      }
      return options;
    }),
    restaurantMenuProvider('r1').overrideWith(
      (ref) async => (
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
            isAvailable: false,
          ),
        ],
      ),
    ),
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
  testWidgets('accueil : prénom, adresse de livraison, restaurants', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(800, 2400)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(const ClientHomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Bonjour Awa'), findsOneWidget);
    expect(find.text('Riviera 2 · Maison'), findsOneWidget);
    expect(find.text('Ce soir, on mange quoi ?'), findsOneWidget);
    expect(find.text('Alloco'), findsOneWidget);
    expect(find.text('Maquis Chez Tante'), findsWidgets);
    expect(find.text('Ivoirien · Cocody'), findsOneWidget);
    expect(find.text('Ouvert'), findsOneWidget);
    expect(find.text('Envoyer un colis'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('un produit personnalisable affiche son action et ses choix', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(800, 2400)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      app(
        const RestaurantDetailScreen(restaurantId: 'r1'),
        options: {
          'p1': [
            (
              id: 'g1',
              name: 'Suppléments',
              minChoices: 0,
              maxChoices: 2,
              options: [
                (id: 'o1', name: 'Avocat', priceDelta: 200, isAvailable: true),
              ],
            ),
          ],
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Personnaliser'), findsOneWidget);
    await tester.tap(find.text('Personnaliser'));
    await tester.pumpAndSettle();
    expect(find.text('Suppléments'), findsOneWidget);
    expect(find.text('Avocat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('un appui pendant le chargement attend les options du produit', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(800, 2400)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      app(
        const RestaurantDetailScreen(restaurantId: 'r1'),
        options: {
          'p1': [
            (
              id: 'g1',
              name: 'Taille',
              minChoices: 1,
              maxChoices: 1,
              options: [
                (id: 'o1', name: 'Grande', priceDelta: 500, isAvailable: true),
              ],
            ),
          ],
        },
        optionsDelay: const Duration(seconds: 1),
      ),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Ajouter au panier'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Taille'), findsOneWidget);
    expect(find.text('Grande'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fiche restaurant : menu par catégorie, produit indisponible', (
    tester,
  ) async {
    // Téléphone haut (400 × 1200 dp) : tout le menu est construit sans défilement.
    tester.view
      ..physicalSize = const Size(800, 2400)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      app(const RestaurantDetailScreen(restaurantId: 'r1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Maquis Chez Tante'), findsOneWidget);
    expect(find.text('20–35 min'), findsOneWidget);
    expect(find.text('Plats'), findsOneWidget);
    expect(find.text('Garba'), findsOneWidget);
    expect(find.text(formatMoney(1500)), findsOneWidget);
    expect(find.text('Autres'), findsOneWidget);
    expect(find.text('${formatMoney(500)} · Indisponible'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'petit écran, grande police : accueil et fiche sans débordement',
    (tester) async {
      smallScreenLargeText(tester);
      await tester.pumpWidget(app(const ClientHomeScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        app(const RestaurantDetailScreen(restaurantId: 'r1')),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
