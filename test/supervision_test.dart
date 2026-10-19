import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tchopi/features/admin/supervision/presentation/dashboard_screen.dart';
import 'package:tchopi/features/admin/supervision/presentation/settings_screen.dart';
import 'package:tchopi/features/admin/supervision/presentation/supervision_screen.dart';
import 'package:tchopi/features/admin/supervision/supervision_providers.dart';
import 'package:tchopi/features/admin/zones/zones_providers.dart';

const settings = PlatformSettings(
  offerTimeoutS: 45,
  restaurantTimeoutS: 600,
  paymentTimeoutS: 900,
  dispatchAlertS: 600,
  dispatchCancelS: 1800,
);

Order order(
  String number,
  OrderStatus status, {
  OrderType type = OrderType.food,
  DateTime? created,
  DateTime? alerted,
}) => Order(
  id: number,
  number: number,
  type: type,
  status: status,
  zoneId: 'z',
  pickupName: 'Chez Tantie Rose',
  recipientName: 'Awa',
  dropoffDistrict: 'Lobia',
  dropoffLandmark: 'Marché',
  subtotal: 3000,
  deliveryFee: 500,
  total: 3500,
  paymentMethod: PaymentMethod.cash,
  createdAt: created ?? DateTime.now(),
  dispatchAlertedAt: alerted,
);

Widget app(Widget home, List<Order> orders) => ProviderScope(
  overrides: [
    activeOrdersProvider.overrideWith((ref) => Stream.value(orders)),
    platformSettingsProvider.overrideWith((ref) async => settings),
    adminZonesProvider.overrideWith((ref) async => const []),
    adminStatsProvider(1).overrideWith(
      (ref) async => {
        'orders': 12,
        'by_status': {'delivered': 9, 'cancelled': 3},
        'by_type': {'food': 10, 'parcel': 2},
        'revenue': 45000,
        'delivery_fees': 9000,
        'commissions': 3600,
        'courier_earnings': 7200,
        'platform': 5400,
        'cash_to_reconcile': 17500,
        'refunds_pending': 1,
        'couriers_online': 4,
      },
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
  final now = DateTime.now();

  test('alertes : sans livreur après le délai, restaurant silencieux', () {
    expect(
      orderAlerts(
        order('R-1', OrderStatus.preparing, alerted: now),
        settings,
        now,
      ),
      {OrderAlert.noCourier},
    );
    expect(
      orderAlerts(
        order(
          'R-2',
          OrderStatus.pending,
          created: now.subtract(const Duration(minutes: 6)),
        ),
        settings,
        now,
      ),
      {OrderAlert.restaurantSilent},
    );
    expect(
      orderAlerts(order('R-3', OrderStatus.pending), settings, now),
      isEmpty,
    );
    expect(
      orderAlerts(
        order('C-4', OrderStatus.inTransit).copyWith(codeLockedAt: now),
        settings,
        now,
      ),
      {OrderAlert.codeLocked},
    );
    expect(
      orderAlerts(
        order('C-5', OrderStatus.failed).copyWith(problemReportedAt: now),
        settings,
        now,
      ),
      {OrderAlert.problem},
      reason: "un échec attend la décision de l'admin",
    );
  });

  testWidgets('supervision : bandeau d\'alertes et filtres', (tester) async {
    await tester.pumpWidget(
      app(const SupervisionScreen(), [
        order('R-AAAAA', OrderStatus.preparing, alerted: now),
        order('C-BBBBB', OrderStatus.searchingCourier, type: OrderType.parcel),
        order('R-CCCCC', OrderStatus.pending),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Commandes en cours'), findsOneWidget);
    expect(find.text('Sans livreur : 1'), findsOneWidget);
    expect(find.textContaining('Restaurant sans réponse'), findsNothing);
    expect(find.textContaining('R-AAAAA'), findsOneWidget);
    expect(find.textContaining('C-BBBBB'), findsOneWidget);

    await tester.tap(find.text('Sans livreur : 1'));
    await tester.pumpAndSettle();
    expect(find.textContaining('C-BBBBB'), findsNothing);
    expect(find.textContaining('R-AAAAA'), findsOneWidget);

    await tester.tap(find.text('Sans livreur : 1'));
    await tester.tap(find.text('Colis'));
    await tester.pumpAndSettle();
    expect(find.textContaining('C-BBBBB'), findsOneWidget);
    expect(find.textContaining('R-AAAAA'), findsNothing);
  });

  testWidgets('paramètres : l\'annulation vient après l\'alerte', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(800, 2400)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(const SettingsScreen(), const []));
    await tester.pumpAndSettle();

    expect(find.text('45'), findsOneWidget);
    expect(find.text('30'), findsOneWidget, reason: '1 800 s en minutes');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Annulation sans livreur (minutes)'),
      '8',
    );
    await tester.tap(find.text('Enregistrer'));
    await tester.pump();
    expect(
      find.text('L\'annulation doit venir après l\'alerte.'),
      findsOneWidget,
    );
  });

  testWidgets('tableau de bord : indicateurs du jour et alertes', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(800, 2600)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      app(const DashboardScreen(), [
        order('R-AAAAA', OrderStatus.preparing, alerted: now),
      ]),
    );
    await tester.pumpAndSettle();
    expect(find.text(formatMoney(45000)), findsOneWidget);
    expect(find.text("Chiffre d'affaires"), findsOneWidget);
    expect(find.text(formatMoney(17500)), findsOneWidget);
    expect(find.text('Livreurs en ligne'), findsOneWidget);
    expect(find.text('Livrée'), findsOneWidget, reason: 'par statut');
    expect(find.text('Commandes en cours'), findsOneWidget, reason: 'alerte');
  });
}
