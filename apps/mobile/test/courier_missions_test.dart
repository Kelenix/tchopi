import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/courier/missions/data/mission_repository.dart';
import 'package:mobile/features/courier/missions/missions_providers.dart';
import 'package:mobile/features/courier/missions/presentation/courier_home_screen.dart';
import 'package:mobile/features/courier/missions/presentation/offer_screen.dart';

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

DeliveryOffer offer(Duration left) => DeliveryOffer(
  id: 'f1',
  orderId: 'o1',
  status: OfferStatus.pending,
  expiresAt: DateTime.now().add(left),
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
  DeliveryOffer? pending,
}) => [
  courierPresenceProvider.overrideWith(() => _Presence(online)),
  currentMissionProvider.overrideWith((ref) => Stream.value(current)),
  pendingOfferProvider.overrideWith((ref) => Stream.value(pending)),
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
    expect(find.text('Commande R-48K2Q'), findsOneWidget);
    expect(find.text('Retrait · Chez Tantie Rose'), findsOneWidget);
    expect(find.textContaining('Espèces à encaisser'), findsOneWidget);
  });

  testWidgets('une nouvelle offre s\'ouvre en plein écran', (tester) async {
    await tester.pumpWidget(
      app(
        const CourierHomeScreen(),
        courier(online: true, pending: offer(const Duration(seconds: 40))),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(OfferScreen), findsOneWidget);
    expect(find.text('Nouvelle mission · Repas'), findsOneWidget);
    expect(find.text('4,2 km au total'), findsOneWidget);
    expect(find.text('Votre gain'), findsOneWidget);
    expect(find.text('Retrait · Chez Tantie Rose'), findsOneWidget);
    expect(find.text('Livraison · Aïcha'), findsOneWidget);
    expect(find.textContaining('Espèces à encaisser'), findsOneWidget);
    expect(find.text('Accepter'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('refus : l\'offre part au livreur suivant', (tester) async {
    final missions = _Missions();
    await tester.pumpWidget(
      app(OfferScreen(offer: offer(const Duration(seconds: 40))), [
        missionRepositoryProvider.overrideWithValue(missions),
        pendingOfferProvider.overrideWith((ref) => const Stream.empty()),
      ]),
    );
    await tester.pump();
    await tester.tap(find.text('Refuser'));
    await tester.pump();
    expect(missions.responses, [false]);
    expect(find.text('Offre refusée'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('sans réponse, l\'offre expire', (tester) async {
    await tester.pumpWidget(
      app(OfferScreen(offer: offer(Duration.zero)), [
        pendingOfferProvider.overrideWith((ref) => const Stream.empty()),
      ]),
    );
    await tester.pump();
    expect(find.text('Accepter'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Offre expirée'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
