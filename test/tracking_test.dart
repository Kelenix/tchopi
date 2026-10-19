import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:tchopi/features/orders/orders_providers.dart';
import 'package:tchopi/features/orders/presentation/order_detail_screen.dart';
import 'package:tchopi/features/orders/presentation/order_widgets.dart';
import 'package:tchopi/features/orders/tracking.dart';
import 'package:tchopi/shared/push.dart';

class FakePush extends Push {
  FakePush(this.value);

  final PushState value;

  @override
  Future<PushState> build() async => value;
}

/// Restaurant au Plateau, client à Cocody (≈ 6 km à vol d'oiseau).
Order order(OrderStatus status) => Order(
  id: 'o1',
  number: 'R-48K2Q',
  status: status,
  pickupName: 'Le Grill du Plateau',
  pickupLat: 5.324,
  pickupLng: -4.02,
  recipientName: 'Awa',
  dropoffDistrict: 'Cocody',
  dropoffLandmark: 'Pharmacie',
  dropoffLat: 5.36,
  dropoffLng: -3.99,
  subtotal: 3000,
  deliveryFee: 500,
  total: 3500,
  paymentMethod: PaymentMethod.cash,
  createdAt: DateTime.now(),
  courierId: 'k1',
  courierInfo: const CourierInfo(
    firstName: 'Koffi',
    vehicleType: VehicleType.motorbike,
    plateNumber: 'AB-123-CI',
  ),
);

CourierLocation at(double lat, double lng, {Duration age = Duration.zero}) =>
    CourierLocation(
      latitude: lat,
      longitude: lng,
      recordedAt: DateTime.now().subtract(age),
    );

Widget app(Order o, List<Override> overrides) => ProviderScope(
  overrides: [
    orderProvider('o1').overrideWith((ref) async => o),
    orderEventsProvider('o1').overrideWith((ref) async => const []),
    ...overrides,
  ],
  child: MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: const OrderDetailScreen(orderId: 'o1'),
  ),
);

void tall(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(800, 2600)
    ..devicePixelRatio = 2;
  addTearDown(tester.view.reset);
}

void main() {
  final now = DateTime.now();

  test(
    'estimation : jusqu\'au client, ou par le retrait avant récupération',
    () {
      final enRoute = arrivalMinutes(
        order(OrderStatus.inTransit),
        VehicleType.motorbike,
        at(5.36, -3.99),
        now,
      );
      expect(enRoute, 1, reason: 'déjà sur place : au moins une minute');
      final beforePickup = arrivalMinutes(
        order(OrderStatus.preparing),
        VehicleType.motorbike,
        at(5.324, -4.02),
        now,
      )!;
      expect(beforePickup, inInclusiveRange(15, 25));
      final onFoot = arrivalMinutes(
        order(OrderStatus.preparing),
        VehicleType.onFoot,
        at(5.324, -4.02),
        now,
      )!;
      expect(onFoot, greaterThan(beforePickup * 4));
    },
  );

  test('TRK-02 : position de plus de 60 s, pas d\'estimation', () {
    expect(
      arrivalMinutes(
        order(OrderStatus.inTransit),
        VehicleType.motorbike,
        at(5.34, -4.0, age: const Duration(minutes: 3)),
        now,
      ),
      isNull,
    );
    expect(formatAge(const Duration(seconds: 45)), '45 s');
    expect(formatAge(const Duration(minutes: 3, seconds: 10)), '3 min');
  });

  testWidgets('suivi : position récente, estimation d\'arrivée', (
    tester,
  ) async {
    tall(tester);
    await tester.pumpWidget(
      app(order(OrderStatus.inTransit), [
        orderLiveProvider('o1').overrideWith(
          (ref) => Stream.value((
            status: OrderStatus.inTransit,
            courierId: 'k1',
            dispatchAlertedAt: null,
            paymentStatus: OrderPaymentStatus.unpaid,
          )),
        ),
        courierLocationProvider(
          'k1',
        ).overrideWith((ref) => Stream.value(at(5.35, -4.0))),
      ]),
    );
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('Arrivée estimée : environ'), findsOneWidget);
    expect(find.text('Connexion perdue — reconnexion…'), findsNothing);
  });

  testWidgets('suivi : position ancienne grisée, estimation indisponible', (
    tester,
  ) async {
    tall(tester);
    await tester.pumpWidget(
      app(order(OrderStatus.inTransit), [
        orderLiveProvider('o1').overrideWith(
          (ref) => Stream.value((
            status: OrderStatus.inTransit,
            courierId: 'k1',
            dispatchAlertedAt: null,
            paymentStatus: OrderPaymentStatus.unpaid,
          )),
        ),
        courierLocationProvider('k1').overrideWith(
          (ref) =>
              Stream.value(at(5.35, -4.0, age: const Duration(minutes: 3))),
        ),
      ]),
    );
    await tester.pump();
    await tester.pump();
    expect(
      find.text('Position il y a 3 min · estimation indisponible'),
      findsOneWidget,
    );
  });

  testWidgets('connexion perdue : bandeau, rappel des notifications refusées', (
    tester,
  ) async {
    tall(tester);
    await tester.pumpWidget(
      app(order(OrderStatus.preparing), [
        orderLiveProvider(
          'o1',
        ).overrideWith((ref) => Stream.error(AppFailure.network)),
        courierLocationProvider(
          'k1',
        ).overrideWith((ref) => const Stream.empty()),
        pushProvider.overrideWith(() => FakePush(PushState.denied)),
      ]),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Connexion perdue — reconnexion…'), findsOneWidget);
    expect(find.textContaining('Notifications désactivées'), findsOneWidget);
    expect(find.text('Activer'), findsOneWidget);
  });
}
