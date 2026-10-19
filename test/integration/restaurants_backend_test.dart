@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tchopi/features/admin/restaurants/data/admin_restaurant_repository.dart';
import 'package:tchopi/features/restaurant/data/restaurant_repository.dart';
import 'package:tchopi/shared/media.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Restaurants réels contre Supabase local : création par l'admin, invitation d'un gérant,
/// profil, horaires, menu et photo par le gérant, visibilité pour un client.
void main() {
  setUpAll(() => HttpOverrides.global = null);

  final env =
      jsonDecode(File('env/local.json').readAsStringSync())
          as Map<String, dynamic>;
  final url = env['SUPABASE_URL'] as String;
  final anonKey = env['SUPABASE_ANON_KEY'] as String;
  final stamp = DateTime.now().microsecondsSinceEpoch;
  final emails = {
    for (final role in ['admin', 'gerant', 'client'])
      role: '$role$stamp@exemple.ci',
  };
  final ids = <String, String>{};
  late SupabaseClient service;
  String? restaurantId;

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
    await service.from('admins').insert({'user_id': ids['admin']});
  });

  tearDownAll(() async {
    if (restaurantId != null) {
      await service.from('restaurants').delete().eq('id', restaurantId!);
    }
    for (final id in ids.values) {
      await service.auth.admin.deleteUser(id);
    }
    await service.dispose();
  });

  test(
    'admin crée le restaurant, le gérant tient son menu, le client le voit',
    () async {
      final adminClient = await signedIn('admin');
      final admin = AdminRestaurantRepository(adminClient);
      final zoneId =
          (await adminClient
                  .from('zones')
                  .select('id')
                  .eq('city', 'Abidjan')
                  .limit(1)
                  .single())['id']
              as String;

      final id = await admin.save(
        Restaurant(
          id: '',
          zoneId: zoneId,
          name: 'Maquis Test $stamp',
          phone: '+2250701020304',
          latitude: 5.35,
          longitude: -4.0,
          district: 'Cocody',
          landmark: 'Carrefour de la vie',
          commissionRate: 12,
        ),
        isNew: true,
      );
      restaurantId = id;
      await admin.invite(id, LoginIdentifier.parse(emails['gerant']!)!);
      final members = await admin.members(id);
      expect(members.single.linked, isTrue, reason: 'compte déjà inscrit');

      final managerClient = await signedIn('gerant');
      final roles = await managerClient.rpc<Map<String, dynamic>>('my_roles');
      expect(roles['restaurant_ids'], [id]);

      final manager = RestaurantRepository(managerClient);
      final restaurant = await manager.fetch(id);
      await manager.updateProfile(
        restaurant.copyWith(description: 'Garba et alloco', prepTimeMin: 25),
      );
      await manager.saveHours(id, const [
        OpeningHour(weekday: 1, opensAt: '11:00', closesAt: '22:00'),
      ]);
      expect(await manager.hours(id), hasLength(1));
      await expectLater(
        managerClient
            .from('restaurants')
            .update({'commission_rate': 1})
            .eq('id', id),
        throwsA(isA<PostgrestException>()),
        reason: 'la commission est réservée à l\'admin',
      );

      final category = await manager.addCategory(id, 'Plats', 0);
      final photo = await MediaRepository(managerClient).uploadRestaurantImage(
        id,
        Uint8List.fromList(List.filled(64, 1)),
        'product',
      );
      await manager.saveProduct(
        Product(
          restaurantId: id,
          categoryId: category.id,
          name: 'Garba',
          price: 1500,
          photoPath: photo,
        ),
      );
      await manager.saveProduct(
        Product(restaurantId: id, name: 'Ancien plat', price: 1000),
      );
      final products = await manager.products(id);
      await manager.archive(
        products.firstWhere((p) => p.name == 'Ancien plat').id!,
      );

      final clientClient = await signedIn('client');
      final visible = await clientClient
          .from('products')
          .select('name')
          .eq('restaurant_id', id);
      expect(visible.map((row) => row['name']), ['Garba']);
      await expectLater(
        clientClient.from('products').insert({
          'restaurant_id': id,
          'name': 'Intrus',
          'price': 1,
        }),
        throwsA(isA<PostgrestException>()),
      );

      final memberId = members.single.id;
      await admin.remove(memberId);
      expect(await admin.members(id), isEmpty);

      for (final client in [adminClient, managerClient, clientClient]) {
        await client.dispose();
      }
    },
  );
}
