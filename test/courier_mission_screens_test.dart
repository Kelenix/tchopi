import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:tchopi/features/courier/missions/data/mission_repository.dart';
import 'package:tchopi/features/courier/missions/missions_providers.dart';
import 'package:tchopi/features/courier/missions/presentation/code_screen.dart';
import 'package:tchopi/features/courier/missions/presentation/history_screen.dart';
import 'package:tchopi/features/courier/missions/presentation/mission_screen.dart';
import 'package:tchopi/features/orders/orders_providers.dart';

import 'small_screen.dart';

class FakeMissions implements MissionRepository {
  FakeMissions([this.codeResults = const []]);

  final List<CodeResult> codeResults;
  final calls = <String>[];

  @override
  Future<void> confirmPickup(
    String orderId, {
    bool cashReceived = false,
  }) async => calls.add('pickup cash=$cashReceived');

  @override
  Future<CodeResult> confirmDelivery(String orderId, String code) async {
    calls.add('code $code');
    return codeResults[calls.where((c) => c.startsWith('code')).length - 1];
  }

  @override
  Future<void> confirmCash(String orderId) async => calls.add('cash');

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Order mission(
  OrderStatus status, {
  OrderType type = OrderType.food,
  OrderPaymentStatus payment = OrderPaymentStatus.unpaid,
}) => Order(
  id: 'o1',
  number: 'R-48K2Q',
  type: type,
  status: status,
  pickupName: 'Chez Tantie Rose',
  pickupPhone: '+2250701000002',
  pickupDistrict: 'Plateau',
  pickupLandmark: 'Face à la tour',
  pickupLat: 5.324,
  pickupLng: -4.02,
  recipientName: 'Aïcha',
  recipientPhone: '+2250700000011',
  dropoffDistrict: 'Cocody',
  dropoffLandmark: 'Pharmacie centrale',
  dropoffLat: 5.36,
  dropoffLng: -3.99,
  subtotal: 8000,
  deliveryFee: 800,
  total: 8800,
  courierEarning: 1100,
  paymentMethod: PaymentMethod.cash,
  paymentStatus: payment,
  parcelDescription: type == OrderType.parcel ? 'Un sac' : null,
  createdAt: DateTime.now(),
);

Widget app(Widget home, List<Override> overrides) => ProviderScope(
  overrides: [
    supportPhoneProvider.overrideWith((ref) async => '+2250700000099'),
    ...overrides,
  ],
  child: MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  ),
);

/// Téléphone haut : tout l'écran est construit sans défilement.
void tall(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(800, 2600)
    ..devicePixelRatio = 2;
  addTearDown(tester.view.reset);
}

List<Override> showing(Order order, [FakeMissions? missions]) => [
  missionProvider('o1').overrideWith((ref) => Stream.value(order)),
  orderItemsProvider('o1').overrideWith(
    (ref) async => const [
      OrderItem(
        orderId: 'o1',
        name: 'Garba',
        unitPrice: 4000,
        quantity: 2,
        lineTotal: 8000,
      ),
    ],
  ),
  if (missions != null) missionRepositoryProvider.overrideWithValue(missions),
];

Future<void> typeCode(WidgetTester tester, String code) async {
  for (final digit in code.split('')) {
    await tester.tap(find.widgetWithText(TextButton, digit));
    await tester.pump();
  }
  await tester.pump();
}

void main() {
  testWidgets('avant récupération : retrait, destination, contenu, actions', (
    tester,
  ) async {
    tall(tester);
    await tester.pumpWidget(
      app(
        const MissionScreen(orderId: 'o1'),
        showing(mission(OrderStatus.ready)),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Aller au retrait'), findsOneWidget);
    expect(find.text('Retrait · Chez Tantie Rose'), findsOneWidget);
    expect(find.text('Livraison · Aïcha'), findsOneWidget);
    expect(find.text('2 × Garba'), findsOneWidget);
    expect(find.textContaining('À encaisser'), findsOneWidget);
    expect(find.byTooltip('Appeler'), findsNWidgets(2));
    expect(find.text('Google Maps'), findsOneWidget);
    expect(find.text('Commande récupérée'), findsOneWidget);
    expect(find.text('Abandonner la mission'), findsOneWidget);
  });

  testWidgets(
    'colis en espèces : encaissement confirmé avant la récupération',
    (tester) async {
      tall(tester);
      final missions = FakeMissions();
      final parcel = mission(
        OrderStatus.courierAssigned,
        type: OrderType.parcel,
      );
      await tester.pumpWidget(
        app(const MissionScreen(orderId: 'o1'), showing(parcel, missions)),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Commande récupérée'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Encaisser'), findsOneWidget);
      await tester.tap(find.textContaining('J\'ai reçu'));
      await tester.pumpAndSettle();
      expect(missions.calls, ['pickup cash=true']);
    },
  );

  testWidgets('en route : essai restant, puis encaissement et fin', (
    tester,
  ) async {
    tall(tester);
    final missions = FakeMissions(const [
      CodeResult(delivered: false, attemptsLeft: 4, locked: false),
      CodeResult(delivered: true, attemptsLeft: 4, locked: false),
    ]);
    await tester.pumpWidget(
      app(CodeScreen(order: mission(OrderStatus.inTransit)), [
        missionRepositoryProvider.overrideWithValue(missions),
      ]),
    );
    await tester.pump();

    expect(find.text('Demandez le code au destinataire'), findsOneWidget);
    await typeCode(tester, '1234');
    expect(find.text('Code incorrect : encore 4 essai(s).'), findsOneWidget);

    await typeCode(tester, '4821');
    expect(find.textContaining('Encaissez'), findsOneWidget);
    await tester.tap(find.textContaining('J\'ai reçu'));
    await tester.pump();
    expect(missions.calls, ['code 1234', 'code 4821', 'cash']);
    expect(find.text('Livraison terminée'), findsOneWidget);
  });

  testWidgets('code bloqué après trop d\'erreurs', (tester) async {
    tall(tester);
    await tester.pumpWidget(
      app(CodeScreen(order: mission(OrderStatus.inTransit)), [
        missionRepositoryProvider.overrideWithValue(
          FakeMissions(const [
            CodeResult(delivered: false, attemptsLeft: 0, locked: true),
          ]),
        ),
      ]),
    );
    await tester.pump();
    await typeCode(tester, '0000');
    expect(
      find.text('Saisie bloquée après trop d\'erreurs. Contactez le support.'),
      findsOneWidget,
    );
    expect(
      find.text('Le destinataire n\'a pas de code ? Appeler le support'),
      findsOneWidget,
    );
  });

  testWidgets('historique : gains du jour et des 7 derniers jours', (
    tester,
  ) async {
    final now = DateTime.now();
    MissionRecord record(String number, OrderStatus status, DateTime at) =>
        MissionRecord(
          id: number,
          number: number,
          type: OrderType.food,
          status: status,
          pickupDistrict: 'Plateau',
          dropoffDistrict: 'Cocody',
          courierEarning: 1100,
          assignedAt: at,
          closedAt: at,
        );
    await tester.pumpWidget(
      app(const HistoryScreen(), [
        missionHistoryProvider.overrideWith(
          (ref) async => [
            record('R-1', OrderStatus.delivered, now),
            record(
              'R-2',
              OrderStatus.delivered,
              now.subtract(const Duration(days: 3)),
            ),
            record('R-3', OrderStatus.failed, now),
          ],
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aujourd\'hui'), findsOneWidget);
    expect(find.text(formatMoney(1100)), findsOneWidget);
    expect(find.text(formatMoney(2200)), findsOneWidget);
    expect(find.text('Plateau → Cocody'), findsNWidgets(3));
    expect(find.text('Échec de livraison'), findsOneWidget);
  });

  testWidgets('petit écran, grande police : mission sans débordement', (
    tester,
  ) async {
    smallScreenLargeText(tester);
    await tester.pumpWidget(
      app(
        const MissionScreen(orderId: 'o1'),
        showing(mission(OrderStatus.ready)),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
