import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/client/addresses/application/addresses_providers.dart';
import 'package:mobile/features/client/payments/payments_providers.dart';
import 'package:mobile/features/orders/cart.dart';
import 'package:mobile/features/orders/data/order_repository.dart';
import 'package:mobile/features/orders/orders_providers.dart';
import 'package:mobile/features/orders/presentation/checkout_screen.dart';
import 'package:mobile/features/orders/presentation/order_detail_screen.dart';
import 'package:mobile/features/restaurant/presentation/restaurant_orders_screen.dart';
import 'package:mobile/features/restaurant/restaurant_providers.dart';

import 'small_screen.dart';

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

const cash = PaymentOption(
  id: 'p1',
  countryCode: 'CI',
  method: PaymentMethod.cash,
  provider: 'cash',
  label: 'Espèces',
  isEnabled: true,
);

class _NoPreference extends PreferredPayment {
  @override
  Future<PaymentMethod?> build() async => null;
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

OrderLive live(OrderStatus status) => (
  status: status,
  courierId: null,
  dispatchAlertedAt: null,
  paymentStatus: OrderPaymentStatus.unpaid,
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
    paymentOptionsProvider.overrideWith((ref) async => const [cash]),
    preferredPaymentProvider.overrideWith(_NoPreference.new),
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

  testWidgets('validation : aucun moyen de paiement actif, pas de commande', (
    tester,
  ) async {
    tall(tester);
    await tester.pumpWidget(
      app(const CheckoutScreen(), [
        cartControllerProvider.overrideWith(_FakeCart.new),
        addressesProvider.overrideWith(_FakeAddresses.new),
        preferredPaymentProvider.overrideWith(_NoPreference.new),
        paymentOptionsProvider.overrideWith((ref) async => const []),
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
    expect(
      find.text('Aucun moyen de paiement n\'est disponible pour le moment.'),
      findsOneWidget,
    );
    final button = find.widgetWithText(
      FilledButton,
      'Commander · ${formatMoney(3500)}',
    );
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
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
        orderLiveProvider(
          'o1',
        ).overrideWith((ref) => Stream.value(live(OrderStatus.pending))),
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

  testWidgets('suivi : livreur attribué, chronologie « Livreur assigné »', (
    tester,
  ) async {
    tall(tester);
    final assigned = order('o1', OrderStatus.preparing).copyWith(
      courierId: 'k1',
      courierInfo: const CourierInfo(
        firstName: 'Koffi',
        phone: '+2250700000031',
        vehicleType: VehicleType.motorbike,
        plateNumber: 'AB-123-CI',
      ),
    );
    await tester.pumpWidget(
      app(const OrderDetailScreen(orderId: 'o1'), [
        orderProvider('o1').overrideWith((ref) async => assigned),
        orderLiveProvider(
          'o1',
        ).overrideWith((ref) => Stream.value(live(OrderStatus.preparing))),
        orderEventsProvider('o1').overrideWith(
          (ref) async => [
            OrderEvent(
              status: OrderStatus.preparing,
              actorRole: 'restaurant',
              createdAt: DateTime.now(),
            ),
            OrderEvent(
              kind: 'courier_assigned',
              actorRole: 'courier',
              createdAt: DateTime.now(),
            ),
            OrderEvent(
              kind: 'dispatch_alert',
              actorRole: 'system',
              createdAt: DateTime.now(),
            ),
          ],
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Koffi'), findsOneWidget);
    expect(find.text('Votre livreur · Moto AB-123-CI'), findsOneWidget);
    expect(find.byTooltip('Appeler'), findsOneWidget);
    expect(find.text('Livreur assigné'), findsOneWidget);
    expect(
      find.text('Alerte : toujours sans livreur'),
      findsNothing,
      reason: 'alerte réservée à l\'admin',
    );
    expect(find.text('Annuler la commande'), findsNothing);
  });

  testWidgets('toujours sans livreur : attendre ou annuler sans frais', (
    tester,
  ) async {
    tall(tester);
    final searching = order(
      'o1',
      OrderStatus.preparing,
    ).copyWith(dispatchAlertedAt: DateTime.now());
    await tester.pumpWidget(
      app(const OrderDetailScreen(orderId: 'o1'), [
        orderProvider('o1').overrideWith((ref) async => searching),
        orderLiveProvider(
          'o1',
        ).overrideWith((ref) => Stream.value(live(OrderStatus.preparing))),
        orderEventsProvider('o1').overrideWith((ref) async => const []),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nous cherchons encore un livreur'), findsOneWidget);
    expect(find.text('Annuler la commande'), findsNWidgets(2));
    await tester.tap(find.text('Continuer d\'attendre'));
    await tester.pump();
    expect(find.text('Nous cherchons encore un livreur'), findsNothing);
    expect(
      find.text('Annuler la commande'),
      findsOneWidget,
      reason: 'l\'annulation reste possible en bas de l\'écran',
    );
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

  testWidgets('restaurant : livreur attribué, remise au livreur', (
    tester,
  ) async {
    final ready = order('o3', OrderStatus.ready).copyWith(
      courierId: 'k1',
      courierInfo: const CourierInfo(
        firstName: 'Koffi',
        vehicleType: VehicleType.motorbike,
        plateNumber: 'AB-123-CI',
      ),
    );
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
        restaurantOrdersProvider(
          'r1',
        ).overrideWith((ref) => Stream.value([ready])),
        orderItemsProvider('o3').overrideWith((ref) async => ready.items),
      ]),
    );
    await tester.pump();
    await tester.pump();
    await tester.tap(find.textContaining('En cours'));
    await tester.pumpAndSettle();

    expect(find.text('Livreur : Koffi · Moto AB-123-CI'), findsOneWidget);
    expect(find.text('Remise au livreur'), findsOneWidget);
  });

  testWidgets('petit écran, grande police : validation sans débordement', (
    tester,
  ) async {
    smallScreenLargeText(tester);
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
    expect(tester.takeException(), isNull);
  });

  testWidgets('petit écran, grande police : suivi sans débordement', (
    tester,
  ) async {
    smallScreenLargeText(tester);
    await tester.pumpWidget(
      app(const OrderDetailScreen(orderId: 'o1'), [
        orderProvider(
          'o1',
        ).overrideWith((ref) async => order('o1', OrderStatus.pending)),
        orderLiveProvider(
          'o1',
        ).overrideWith((ref) => Stream.value(live(OrderStatus.pending))),
        orderEventsProvider('o1').overrideWith((ref) async => const []),
      ]),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  parcelTests();
}

void parcelTests() {
  testWidgets('colis : trajet, code de livraison à partager, annulation', (
    tester,
  ) async {
    tall(tester);
    final parcel = order('o2', OrderStatus.searchingCourier).copyWith(
      type: OrderType.parcel,
      number: 'C-7K2P9',
      pickupDistrict: 'Cocody',
      pickupLandmark: 'Pharmacie',
      dropoffDistrict: 'Plateau',
      recipientName: 'Koffi',
      recipientPhone: '+2250700000022',
      subtotal: 0,
      total: 500,
      items: const [],
    );
    await tester.pumpWidget(
      app(const OrderDetailScreen(orderId: 'o2'), [
        orderProvider('o2').overrideWith((ref) async => parcel),
        orderLiveProvider('o2').overrideWith(
          (ref) => Stream.value(live(OrderStatus.searchingCourier)),
        ),
        orderEventsProvider('o2').overrideWith((ref) async => const []),
        deliveryCodeProvider('o2').overrideWith((ref) async => '4821'),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Commande C-7K2P9'), findsOneWidget);
    expect(find.text('Cocody → Plateau'), findsOneWidget);
    expect(find.text('Code de livraison'), findsOneWidget);
    expect(find.text('4 8 2 1'), findsOneWidget);
    expect(find.text('Partager au destinataire'), findsOneWidget);
    expect(find.text('Koffi'), findsOneWidget);
    expect(find.text('Annuler la commande'), findsOneWidget);
    final error = tester.takeException();
    expect(error, isNull, reason: '$error');
  });
}
