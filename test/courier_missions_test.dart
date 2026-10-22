import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:tchopi/features/courier/missions/data/mission_repository.dart';
import 'package:tchopi/features/courier/missions/missions_providers.dart';
import 'package:tchopi/features/courier/missions/presentation/courier_home_screen.dart';
import 'package:tchopi/features/courier/missions/presentation/offer_screen.dart';

class _Presence extends CourierPresence {
  _Presence(this.online);

  final bool online;

  @override
  Future<bool> build() async => online;
}

class _Profile extends CurrentProfile {
  @override
  Future<Profile?> build() async => const Profile(id: 'u', firstName: 'Koffi');
}

class _Missions implements MissionRepository {
  final responses = <bool>[];

  @override
  Future<void> respond(String offerId, {required bool accept}) async =>
      responses.add(accept);

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const summary = OfferSummary(
  number: 'R-48K2Q',
  type: 'food',
  pickupName: 'Chez Tantie Rose',
  pickupDistrict: 'Cocody',
  pickupLandmark: 'face à la station',
  recipientName: 'Aïcha',
  dropoffDistrict: 'Riviera 2',
  dropoffLandmark: 'pharmacie centrale',
  earning: 1100,
  toPickupM: 800,
  tripM: 3400,
  cashAmount: 8800,
);

const offer = DeliveryOffer(
  id: 'f1',
  orderId: 'o1',
  status: OfferStatus.pending,
  summary: summary,
);

final mission = Order(
  id: 'o1',
  number: 'R-48K2Q',
  status: OrderStatus.preparing,
  pickupName: 'Chez Tantie Rose',
  pickupDistrict: 'Cocody',
  pickupLandmark: 'Face à la station',
  recipientName: 'Aïcha',
  dropoffDistrict: 'Riviera 2',
  dropoffLandmark: 'Pharmacie centrale',
  subtotal: 8000,
  deliveryFee: 800,
  total: 8800,
  courierEarning: 1100,
  paymentMethod: PaymentMethod.cash,
  createdAt: DateTime.now(),
);

Widget app(Widget home, List<Override> overrides) => ProviderScope(
  overrides: [currentProfileProvider.overrideWith(_Profile.new), ...overrides],
  child: MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  ),
);

List<Override> courier({
  required bool online,
  Order? current,
  List<DeliveryOffer> pending = const [],
}) => [
  courierPresenceProvider.overrideWith(() => _Presence(online)),
  currentMissionProvider.overrideWith((ref) => Stream.value(current)),
  courierSummaryProvider.overrideWith(
    (ref) async => const CourierSummary(
      earningsToday: 2200,
      deliveriesToday: 2,
      cashDue: 17500,
    ),
  ),
  pendingOffersProvider.overrideWith((ref) => Stream.value(pending)),
];

void main() {
  testWidgets('hors ligne : l\'interrupteur invite à passer en ligne', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(const CourierHomeScreen(), courier(online: false)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bonjour Koffi'), findsOneWidget);
    expect(find.text('Hors ligne'), findsOneWidget);
    expect(
      find.text('Passez en ligne pour recevoir des missions.'),
      findsOneWidget,
    );
    expect(find.text('En attente d\'une mission'), findsNothing);
  });

  testWidgets('en ligne avec une mission : carte de la mission en cours', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(const CourierHomeScreen(), courier(online: true, current: mission)),
    );
    await tester.pumpAndSettle();
    expect(find.text('En ligne'), findsOneWidget);
    expect(find.text('Mission en cours'), findsOneWidget);
    expect(find.text(formatMoney(mission.courierEarning)), findsOneWidget);
    expect(find.text('Commande R-48K2Q'), findsOneWidget);
    expect(find.text('Retrait · Chez Tantie Rose'), findsOneWidget);
    expect(find.textContaining('Espèces à encaisser'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Missions livrées'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(formatMoney(2200)), findsOneWidget);
    expect(find.text('Missions livrées'), findsOneWidget);
    expect(find.text(formatMoney(17500)), findsOneWidget);
    expect(find.text('Espèces à reverser'), findsOneWidget);
  });

  testWidgets(
    'une commande prête est listée, son détail s\'ouvre et se referme',
    (tester) async {
      await tester.pumpWidget(
        app(
          const CourierHomeScreen(),
          courier(online: true, pending: const [offer]),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(OfferScreen), findsNothing);
      expect(
        find.text('Commandes à récupérer', skipOffstage: false),
        findsOneWidget,
      );
      // Le rappel « Nouvelle commande » disparaît seul, puis la carte est amenée au centre de l'écran.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      final tile = find.textContaining('Retrait · Chez Tantie Rose');
      await tester.ensureVisible(tile);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -150));
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(find.byType(OfferScreen), findsOneWidget);
      expect(find.text('Nouvelle mission · Repas'), findsOneWidget);
      expect(find.text('4,2 km au total'), findsOneWidget);
      expect(find.text('Votre gain'), findsOneWidget);
      expect(find.text('Retrait · Chez Tantie Rose'), findsOneWidget);
      expect(find.text('Livraison · Aïcha'), findsOneWidget);
      expect(find.textContaining('Espèces à encaisser'), findsOneWidget);
      expect(find.text('Accepter'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(OfferScreen), findsNothing);
      expect(find.text('Commandes à récupérer'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('refus : la commande reste aux autres livreurs', (tester) async {
    final missions = _Missions();
    await tester.pumpWidget(
      app(const OfferScreen(offer: offer), [
        missionRepositoryProvider.overrideWithValue(missions),
        pendingOffersProvider.overrideWith(
          (ref) => const Stream<List<DeliveryOffer>>.empty(),
        ),
      ]),
    );
    await tester.pump();
    await tester.tap(find.text('Refuser'));
    await tester.pump();
    expect(missions.responses, [false]);
    expect(find.text('Offre refusée'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('prise par un autre livreur : l\'offre disparaît', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(const OfferScreen(offer: offer), [
        pendingOffersProvider.overrideWith((ref) => Stream.value(const [])),
      ]),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Accepter'), findsNothing);
    expect(find.text('Cette mission n\'est plus disponible.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
