import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/client/addresses/application/addresses_providers.dart';
import 'package:mobile/features/orders/cart.dart';
import 'package:mobile/features/orders/orders_providers.dart';
import 'package:mobile/features/orders/presentation/checkout_screen.dart';
import 'package:mobile/features/orders/presentation/order_detail_screen.dart';
import 'package:mobile/features/restaurant/presentation/restaurant_orders_screen.dart';
import 'package:mobile/features/restaurant/restaurant_providers.dart';

const cart = Cart(
  restaurantId: 'r1',
  restaurantName: 'Maquis Chez Tante',
  lines: [
    CartLine(productId: 'p1', name: 'Garba', unitPrice: 1500, quantity: 2),
  ],
);

class _FakeCart extends CartController {
  @override
  Future<Cart?> build() async => cart;
}

class _FakeAddresses extends Addresses {
  @override
  Future<List<Address>> build() async => const [
    Address(
      id: 'a1',
      district: 'Riviera 2',
      landmark: 'Pharmacie',
      latitude: 5.36,
      longitude: -3.97,
      isDefault: true,
    ),
  ];
}

Order order(String id, OrderStatus status) => Order(
  id: id,
  number: 'R-48K2Q',
  status: status,
  restaurantId: 'r1',
  pickupName: 'Maquis Chez Tante',
  recipientName: 'Awa',
  dropoffDistrict: 'Riviera 2',
  dropoffLandmark: 'Pharmacie',
  subtotal: 3000,
  deliveryFee: 500,
  total: 3500,
  commissionAmount: 300,
  paymentMethod: PaymentMethod.cash,
  createdAt: DateTime.now(),
  items: const [
    OrderItem(
      orderId: 'o1',
      name: 'Garba',
      unitPrice: 1500,
      quantity: 2,
      lineTotal: 3000,
    ),
  ],
);

Widget app(Widget home, List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  ),
);

/// Téléphone haut (400 × 1200 dp) : tout l'écran est construit sans défilement.
void tall(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(800, 2400)
    ..devicePixelRatio = 2;
  addTearDown(tester.view.reset);
}

void main() {
  final base = [
    cartControllerProvider.overrideWith(_FakeCart.new),
    addressesProvider.overrideWith(_FakeAddresses.new),
  ];

  testWidgets('validation : montants du devis serveur et bouton Commander', (
    tester,
  ) async {
    tall(tester);
    await tester.pumpWidget(
      app(const CheckoutScreen(), [
        ...base,
        cartQuoteProvider('a1').overrideWith(
          (ref) async => const FoodQuote(
            subtotal: 3000,
            deliveryFee: 500,
            total: 3500,
            distanceM: 2400,
          ),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Maison · Riviera 2'), findsOneWidget);
    expect(find.text('Espèces à la livraison'), findsOneWidget);
    expect(find.text(formatMoney(500)), findsOneWidget);
    final button = find.widgetWithText(
      FilledButton,
      'Commander · ${formatMoney(3500)}',
    );
    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
  });

  testWidgets('validation : un écart bloque la commande et s\'explique', (
    tester,
  ) async {
    tall(tester);
    await tester.pumpWidget(
      app(const CheckoutScreen(), [
        ...base,
        cartQuoteProvider('a1').overrideWith(
          (ref) async => const FoodQuote(
            subtotal: 0,
            deliveryFee: 500,
            total: 500,
            distanceM: 2400,
            issues: [
              QuoteIssue(
                issue: 'product_unavailable',
                productId: 'p1',
                name: 'Garba',
              ),
            ],
          ),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('« Garba » n\'est plus disponible.'), findsOneWidget);
    expect(find.text('Mettre à jour le panier'), findsOneWidget);
    final button = find.byType(FilledButton);
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
  });

  testWidgets('suivi : statut, chronologie, annulation tant qu\'en attente', (
    tester,
  ) async {
    tall(tester);
    await tester.pumpWidget(
      app(const OrderDetailScreen(orderId: 'o1'), [
        orderProvider(
          'o1',
        ).overrideWith((ref) async => order('o1', OrderStatus.pending)),
        orderStatusProvider(
          'o1',
        ).overrideWith((ref) => Stream.value(OrderStatus.pending)),
        orderEventsProvider('o1').overrideWith(
          (ref) async => [
            OrderEvent(
              status: OrderStatus.pending,
              actorRole: 'customer',
              createdAt: DateTime.now(),
            ),
          ],
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Commande R-48K2Q'), findsOneWidget);
    expect(find.text('En attente de confirmation'), findsWidgets);
    expect(find.text('2 × Garba'), findsOneWidget);
    expect(find.text('Annuler la commande'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('restaurant : nouvelles commandes, actions et totaux du jour', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(const RestaurantOrdersScreen(), [
        managedRestaurantIdProvider.overrideWithValue('r1'),
        managedRestaurantProvider('r1').overrideWith(
          (ref) async => const Restaurant(
            id: 'r1',
            zoneId: 'z',
            name: 'Maquis Chez Tante',
            phone: '+2250701020304',
            latitude: 5.35,
            longitude: -4,
            district: 'Cocody',
            landmark: 'Carrefour',
          ),
        ),
        restaurantOrdersProvider('r1').overrideWith(
          (ref) => Stream.value([
            order('o1', OrderStatus.pending),
            order('o2', OrderStatus.accepted),
          ]),
        ),
        orderItemsProvider(
          'o1',
        ).overrideWith((ref) async => order('o1', OrderStatus.pending).items),
      ]),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Nouvelles (1)'), findsOneWidget);
    expect(find.text('Nouvelle commande !'), findsOneWidget);
    expect(find.text('Accepter'), findsOneWidget);
    expect(find.text('Refuser'), findsOneWidget);
    expect(find.text('2 × Garba'), findsOneWidget);
    expect(find.text(formatMoney(6000)), findsOneWidget, reason: 'ventes');
    expect(find.text(formatMoney(5400)), findsOneWidget, reason: 'net');

    // Arrête l'alerte répétée avant la fin du test.
    await tester.tap(find.text('Nouvelle commande !'));
    await tester.pump();
    expect(find.text('Nouvelle commande !'), findsNothing);
  });
}
