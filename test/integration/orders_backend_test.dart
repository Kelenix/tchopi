@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tchopi/features/admin/supervision/data/supervision_repository.dart';
import 'package:tchopi/features/client/payments/data/payment_repository.dart';
import 'package:tchopi/features/courier/missions/data/mission_repository.dart';
import 'package:tchopi/features/orders/cart.dart';
import 'package:tchopi/features/orders/data/order_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Commande de repas réelle contre Supabase local : devis, commande unique malgré un double envoi,
/// réception en temps réel par le restaurant, acceptation, annulation refusée ensuite ; colis ;
/// attribution : offre reçue en direct par le livreur en ligne, acceptation, livreur visible du client ;
/// mission jusqu'à la livraison par code et l'encaissement des espèces.
void main() {
  setUpAll(() => HttpOverrides.global = null);

  final env =
      jsonDecode(File('env/local.json').readAsStringSync())
          as Map<String, dynamic>;
  final url = env['SUPABASE_URL'] as String;
  final anonKey = env['SUPABASE_ANON_KEY'] as String;
  final stamp = DateTime.now().microsecondsSinceEpoch;
  final emails = {
    for (final role in ['gerant', 'client', 'livreur', 'admin'])
      role: '$role$stamp@exemple.ci',
  };
  final ids = <String, String>{};
  late SupabaseClient service;
  late String restaurantId, productId, addressId;

  Future<SupabaseClient> signedIn(String role) async {
    final client = SupabaseClient(url, anonKey);
    await client.auth.signInWithPassword(
      email: emails[role]!,
      password: 'motdepasse1',
    );
    return client;
  }

  setUpAll(() async {
    final status = await Process.run('supabase', [
      'status',
      '-o',
      'env',
    ], runInShell: true);
    final serviceKey = RegExp(
      r'^SERVICE_ROLE_KEY="?([^"\r\n]+)',
      multiLine: true,
    ).firstMatch(status.stdout as String)!.group(1)!;
    service = SupabaseClient(url, serviceKey);
    for (final MapEntry(key: role, value: email) in emails.entries) {
      ids[role] = (await service.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: 'motdepasse1',
          emailConfirm: true,
        ),
      )).user!.id;
    }
    final zoneId =
        (await service
                .from('zones')
                .select('id')
                .eq('is_active', true)
                .limit(1)
                .single())['id']
            as String;
    restaurantId =
        (await service
                .from('restaurants')
                .insert({
                  'zone_id': zoneId,
                  'name': 'Maquis Commande $stamp',
                  'phone': '+2250701020304',
                  'latitude': 5.36,
                  'longitude': -3.97,
                  'district': 'Cocody',
                  'landmark': 'Carrefour de la vie',
                })
                .select('id')
                .single())['id']
            as String;
    await service.from('restaurant_members').insert({
      'restaurant_id': restaurantId,
      'user_id': ids['gerant'],
      'login_email': emails['gerant'],
    });
    await service.from('opening_hours').insert([
      for (var day = 1; day <= 7; day++)
        {
          'restaurant_id': restaurantId,
          'weekday': day,
          'opens_at': '00:00',
          'closes_at': '23:59:59',
        },
    ]);
    productId =
        (await service
                .from('products')
                .insert({
                  'restaurant_id': restaurantId,
                  'name': 'Garba',
                  'price': 1500,
                })
                .select('id')
                .single())['id']
            as String;
    // Zone et ville sont calculées par la base à l'insertion du client lui-même.
    final owner = await signedIn('client');
    addressId =
        (await owner
                .from('addresses')
                .insert({
                  'district': 'Riviera 2',
                  'landmark': 'Pharmacie',
                  'latitude': 5.37,
                  'longitude': -3.95,
                })
                .select('id')
                .single())['id']
            as String;
    await owner.dispose();

    // Livreur approuvé, en ligne au restaurant : sans lui, aucune commande n'est acceptée (ORD-07).
    await service
        .from('profiles')
        .update({'first_name': 'Moussa', 'phone': '+2250700000033'})
        .eq('id', ids['livreur']!);
    await service.from('couriers').insert({
      'user_id': ids['livreur'],
      'zone_id': zoneId,
      'vehicle_type': 'motorbike',
      'plate_number': 'AB-123-CI',
      'photo_path': '${ids['livreur']}/p.jpg',
      'status': 'approved',
    });
    final courier = await signedIn('livreur');
    await MissionRepository(courier).setOnline(true);
    await MissionRepository(courier).reportLocation(5.36, -3.97, 10);
    await courier.dispose();
    await service.from('admins').insert({'user_id': ids['admin']});
  });

  tearDownAll(() async {
    await service.from('addresses').delete().eq('id', addressId);
    await service.from('orders').delete().eq('customer_id', ids['client']!);
    await service
        .from('cash_ledger')
        .delete()
        .eq('courier_id', ids['livreur']!);
    await service.from('restaurants').delete().eq('id', restaurantId);
    for (final id in ids.values) {
      await service.auth.admin.deleteUser(id);
    }
    await service.dispose();
  });

  test(
    'le client commande, le restaurant la reçoit en direct et accepte',
    () async {
      final clientClient = await signedIn('client');
      final managerClient = await signedIn('gerant');
      final client = OrderRepository(clientClient);
      final manager = OrderRepository(managerClient);

      // Le restaurant écoute avant la commande.
      final received = manager
          .watchRestaurant(restaurantId)
          .firstWhere((orders) => orders.isNotEmpty);
      await Future<void>.delayed(const Duration(seconds: 3));

      final cart = Cart(
        restaurantId: restaurantId,
        restaurantName: 'Maquis',
        lines: [
          CartLine(
            productId: productId,
            name: 'Garba',
            unitPrice: 1500,
            quantity: 2,
          ),
        ],
      );
      final quote = await client.quote(cart, addressId);
      expect(quote.subtotal, 3000);
      expect(quote.issues, isEmpty);

      Future<Order> place() => client.place(
        cart: cart,
        addressId: addressId,
        method: PaymentMethod.cash,
        expectedTotal: quote.total,
        idempotencyKey: '00000000-0000-4000-8000-$stamp'.substring(0, 36),
      );
      final first = await place();
      final again = await place();
      expect(again.id, first.id, reason: 'double envoi : une seule commande');
      expect(first.status, OrderStatus.pending);
      expect(first.total, quote.total);

      // Juste après « supabase db reset », le premier abonnement temps réel peut tarder ; le flux recharge les
      // données dès qu'il est abonné.
      final live = await received.timeout(const Duration(seconds: 30));
      expect(live.single.id, first.id);

      await manager.transition(first.id, OrderStatus.accepted);
      await expectLater(
        client.cancel(first.id),
        throwsA(
          isA<AppFailure>().having((f) => f.code, 'code', 'already_accepted'),
        ),
      );
      final events = await client.events(first.id);
      expect(events.map((e) => e.status), [
        OrderStatus.pending,
        OrderStatus.accepted,
      ]);
      expect((await client.mine()).single.items.single.quantity, 2);

      await clientClient.dispose();
      await managerClient.dispose();
    },
  );

  test(
    'le client envoie un colis : devis, demande unique, code de livraison',
    () async {
      final clientClient = await signedIn('client');
      final client = OrderRepository(clientClient);
      final type = (await client.parcelTypes(
        5.37,
        -3.95,
      )).firstWhere((t) => t.code == 'small');
      const pickup = ParcelPoint(
        lat: 5.37,
        lng: -3.95,
        district: 'Riviera 2',
        landmark: 'Pharmacie',
      );
      const dropoff = ParcelPoint(
        lat: 5.32,
        lng: -4.02,
        district: 'Plateau',
        landmark: 'Tour A',
        instructions: 'Accueil',
      );
      final quote = await client.quoteParcel(pickup, dropoff, type.id);
      expect(quote.deliveryFee, greaterThan(0));

      Future<Order> place() => client.placeParcel(
        pickup: pickup,
        dropoff: dropoff,
        recipientName: 'Koffi',
        recipientPhone: '+2250700000022',
        parcelTypeId: type.id,
        description: 'Documents',
        rulesAccepted: true,
        method: PaymentMethod.cash,
        expectedTotal: quote.total,
        idempotencyKey: '00000000-0000-4000-9000-$stamp'.substring(0, 36),
      );
      final first = await place();
      expect(
        (await place()).id,
        first.id,
        reason: 'double envoi : une seule demande',
      );
      expect(first.type, OrderType.parcel);
      expect(first.status, OrderStatus.searchingCourier);
      expect(first.number, startsWith('C-'));
      expect(await client.deliveryCode(first.id), matches(RegExp(r'^\d{4}$')));

      await client.cancel(first.id);
      expect((await client.fetch(first.id)).status, OrderStatus.cancelled);
      // PAY-02 : annulée avant encaissement, la transaction est annulée.
      final parcelTx = (await PaymentRepository(
        clientClient,
      ).mine()).firstWhere((t) => t.orderId == first.id);
      expect(parcelTx.status, TransactionStatus.cancelled);
      await clientClient.dispose();
    },
  );

  test(
    'attribution : offre en direct au livreur, acceptation, livreur visible',
    () async {
      final clientClient = await signedIn('client');
      final managerClient = await signedIn('gerant');
      final courierClient = await signedIn('livreur');
      final client = OrderRepository(clientClient);
      final manager = OrderRepository(managerClient);
      final missions = MissionRepository(courierClient);

      // Le livreur écoute ses offres avant la commande.
      final offered = missions
          .watchPendingOffer(ids['livreur']!)
          .firstWhere((offer) => offer != null);
      await Future<void>.delayed(const Duration(seconds: 3));

      final cart = Cart(
        restaurantId: restaurantId,
        restaurantName: 'Maquis',
        lines: [
          CartLine(
            productId: productId,
            name: 'Garba',
            unitPrice: 1500,
            quantity: 1,
          ),
        ],
      );
      final quote = await client.quote(cart, addressId);
      expect(quote.couriersAvailable, isTrue);
      final order = await client.place(
        cart: cart,
        addressId: addressId,
        method: PaymentMethod.cash,
        expectedTotal: quote.total,
        idempotencyKey: '00000000-0000-4000-a000-$stamp'.substring(0, 36),
      );
      await manager.transition(order.id, OrderStatus.accepted);
      await manager.transition(order.id, OrderStatus.preparing);

      final offer = (await offered.timeout(const Duration(seconds: 10)))!;
      expect(offer.orderId, order.id);
      expect(offer.summary.earning, greaterThan(0));
      expect(offer.summary.cashAmount, order.total);
      expect(offer.expiresAt.isAfter(DateTime.now()), isTrue);

      await missions.respond(offer.id, accept: true);
      final assigned = await client.fetch(order.id);
      expect(assigned.courierId, ids['livreur']);
      expect(assigned.courierInfo?.firstName, 'Moussa');
      expect(
        (await client.events(order.id)).map((e) => e.kind),
        contains('courier_assigned'),
      );
      // Suivi (TRK-01) et notifications (NOT-01) : position du livreur visible du client, étapes en file.
      final position = await client
          .watchCourier(ids['livreur']!)
          .firstWhere((p) => p != null)
          .timeout(const Duration(seconds: 10));
      expect(position!.isStale(DateTime.now()), isFalse);
      final notified = await clientClient
          .from('notifications')
          .select('kind')
          .eq('order_id', order.id);
      expect(
        notified.map((n) => n['kind']),
        containsAll(['order_accepted', 'courier_assigned']),
      );

      final mission = await missions
          .watchMission(ids['livreur']!)
          .firstWhere((m) => m != null)
          .timeout(const Duration(seconds: 10));
      expect(mission?.id, order.id);
      await expectLater(
        missions.setOnline(false),
        throwsA(
          isA<AppFailure>().having(
            (f) => f.code,
            'code',
            'mission_in_progress',
          ),
        ),
      );

      // Mission : prête, récupérée, en route, code faux puis juste, espèces encaissées (MIS-04 à MIS-06).
      await expectLater(
        missions.confirmPickup(order.id),
        throwsA(isA<AppFailure>().having((f) => f.code, 'code', 'not_ready')),
      );
      await manager.transition(order.id, OrderStatus.ready);
      await missions.confirmPickup(order.id);
      await missions.startDelivery(order.id);
      final code = (await client.deliveryCode(order.id))!;
      final wrong = ((int.parse(code) + 1) % 10000).toString().padLeft(4, '0');
      final miss = await missions.confirmDelivery(order.id, wrong);
      expect(miss.delivered, isFalse);
      expect(miss.attemptsLeft, 4);
      expect(
        (await missions.confirmDelivery(order.id, code)).delivered,
        isTrue,
      );
      await missions.confirmCash(order.id);
      final done = await client.fetch(order.id);
      expect(done.status, OrderStatus.delivered);
      expect(done.paymentStatus, OrderPaymentStatus.paid);
      final summary = await missions.summary();
      expect(summary.deliveriesToday, 1);
      expect(summary.cashDue, order.total);
      expect((await missions.history()).single.status, OrderStatus.delivered);
      // TRX-01 : transaction réussie, montant égal au total.
      final paid = (await PaymentRepository(
        clientClient,
      ).mine()).firstWhere((t) => t.orderId == order.id);
      expect(paid.status, TransactionStatus.succeeded);
      expect(paid.amount, order.total);

      await clientClient.dispose();
      await managerClient.dispose();
      await courierClient.dispose();
    },
  );

  test(
    "remboursement : colis payé puis en échec, décidé et remboursé par l'admin",
    () async {
      final clientClient = await signedIn('client');
      final courierClient = await signedIn('livreur');
      final adminClient = await signedIn('admin');
      final client = OrderRepository(clientClient);
      final missions = MissionRepository(courierClient);
      final admin = SupervisionRepository(adminClient);

      final type = (await client.parcelTypes(
        5.37,
        -3.95,
      )).firstWhere((t) => t.code == 'small');
      const pickup = ParcelPoint(
        lat: 5.36,
        lng: -3.97,
        district: 'Cocody',
        landmark: 'Carrefour de la vie',
      );
      const dropoff = ParcelPoint(
        lat: 5.32,
        lng: -4.02,
        district: 'Plateau',
        landmark: 'Tour A',
      );
      final offered = missions
          .watchPendingOffer(ids['livreur']!)
          .firstWhere((offer) => offer != null);
      await Future<void>.delayed(const Duration(seconds: 3));
      final quote = await client.quoteParcel(pickup, dropoff, type.id);
      final parcel = await client.placeParcel(
        pickup: pickup,
        dropoff: dropoff,
        recipientName: 'Koffi',
        recipientPhone: '+2250700000022',
        parcelTypeId: type.id,
        description: 'Documents',
        rulesAccepted: true,
        method: PaymentMethod.cash,
        expectedTotal: quote.total,
        idempotencyKey: '00000000-0000-4000-b000-$stamp'.substring(0, 36),
      );
      final offer = (await offered.timeout(const Duration(seconds: 15)))!;
      expect(offer.orderId, parcel.id);
      await missions.respond(offer.id, accept: true);
      await missions.confirmPickup(parcel.id, cashReceived: true);
      await missions.declareFailure(parcel.id, 'Destinataire absent');

      await admin.requestRefund(parcel.id, 'Destinataire absent');
      expect(
        (await client.fetch(parcel.id)).paymentStatus,
        OrderPaymentStatus.refundPending,
      );
      await admin.markRefunded(parcel.id, 'Espèces rendues, reçu 7');
      final refunded = (await PaymentRepository(
        clientClient,
      ).mine()).firstWhere((t) => t.orderId == parcel.id);
      expect(refunded.status, TransactionStatus.refunded);

      final now = DateTime.now();
      final stats = await admin.stats(
        now.subtract(const Duration(days: 1)),
        now.add(const Duration(minutes: 1)),
      );
      expect(stats['orders'], greaterThanOrEqualTo(3));
      expect((stats['by_status'] as Map)['failed'], greaterThanOrEqualTo(1));

      await clientClient.dispose();
      await courierClient.dispose();
      await adminClient.dispose();
    },
  );
}
