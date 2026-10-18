@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/orders/cart.dart';
import 'package:mobile/features/orders/data/order_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Commande de repas réelle contre Supabase local : devis, commande unique malgré un double envoi,
/// réception en temps réel par le restaurant, acceptation, annulation refusée ensuite.
void main() {
  setUpAll(() => HttpOverrides.global = null);

  final env =
      jsonDecode(File('../../env/local.json').readAsStringSync())
          as Map<String, dynamic>;
  final url = env['SUPABASE_URL'] as String;
  final anonKey = env['SUPABASE_ANON_KEY'] as String;
  final stamp = DateTime.now().microsecondsSinceEpoch;
  final emails = {
    for (final role in ['gerant', 'client']) role: '$role$stamp@exemple.ci',
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
    final status = await Process.run(
      'supabase',
      ['status', '-o', 'env'],
      workingDirectory: '../..',
      runInShell: true,
    );
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
  });

  tearDownAll(() async {
    await service.from('addresses').delete().eq('id', addressId);
    await service.from('orders').delete().eq('restaurant_id', restaurantId);
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

      final live = await received.timeout(const Duration(seconds: 10));
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
}
