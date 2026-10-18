import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/client/addresses/application/addresses_providers.dart';
import 'package:mobile/features/client/home/catalog_providers.dart';
import 'package:mobile/features/client/home/client_home_screen.dart';
import 'package:mobile/features/client/home/restaurant_detail_screen.dart';
import 'package:mobile/features/restaurant/restaurant_providers.dart';

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

Widget app(Widget home) => ProviderScope(
  overrides: [
    currentProfileProvider.overrideWith(_FakeProfile.new),
    addressesProvider.overrideWith(_FakeAddresses.new),
    catalogRestaurantsProvider.overrideWith((ref) async => [restaurant]),
    catalogRestaurantProvider('r1').overrideWith((ref) async => restaurant),
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
    await tester.pumpWidget(app(const ClientHomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Bonjour Awa'), findsOneWidget);
    expect(find.text('Maison · Riviera 2'), findsOneWidget);
    expect(find.text('Repas'), findsOneWidget);
    expect(find.text('Maquis Chez Tante'), findsOneWidget);
    expect(find.text('Ivoirien · Cocody'), findsOneWidget);
    expect(find.text('Ouvert'), findsOneWidget);
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
}
