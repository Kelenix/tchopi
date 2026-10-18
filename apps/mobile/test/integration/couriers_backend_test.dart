@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/admin/people/data/admin_people_repository.dart';
import 'package:mobile/features/courier/profile/data/courier_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Livreur et administration réels contre Supabase local : inscription livreur avec photo, validation,
/// suspension qui bloque la connexion, réactivation, changement d'identifiant par l'admin.
void main() {
  setUpAll(() => HttpOverrides.global = null);

  final env =
      jsonDecode(File('../../env/local.json').readAsStringSync())
          as Map<String, dynamic>;
  final url = env['SUPABASE_URL'] as String;
  final anonKey = env['SUPABASE_ANON_KEY'] as String;
  final stamp = DateTime.now().microsecondsSinceEpoch;
  final courierEmail = 'livreur$stamp@exemple.ci';
  final adminEmail = 'admin$stamp@exemple.ci';
  late SupabaseClient service;
  late String courierId;
  late String adminId;

  SupabaseClient anonClient() => SupabaseClient(url, anonKey);

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
    Future<String> createUser(String email) async =>
        (await service.auth.admin.createUser(
          AdminUserAttributes(
            email: email,
            password: 'motdepasse1',
            emailConfirm: true,
          ),
        )).user!.id;
    courierId = await createUser(courierEmail);
    adminId = await createUser(adminEmail);
    await service.from('admins').insert({'user_id': adminId});
  });

  tearDownAll(() async {
    await service.auth.admin.deleteUser(courierId);
    await service.auth.admin.deleteUser(adminId);
    await service.dispose();
  });

  test(
    'inscription livreur, validation, suspension, réactivation, changement d\'identifiant',
    () async {
      final courierClient = anonClient();
      await courierClient.auth.signInWithPassword(
        email: courierEmail,
        password: 'motdepasse1',
      );
      final zone =
          (await courierClient
                  .from('zones')
                  .select('id')
                  .eq('is_active', true)
                  .limit(1)
                  .single())['id']
              as String;
      final couriers = CourierRepository(courierClient);

      final submitted = await couriers.submit(
        userId: courierId,
        zoneId: zone,
        vehicle: VehicleType.motorbike,
        plate: '4821 HJ 01',
        newPhoto: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]),
      );
      expect(submitted.status, CourierStatus.pending);
      expect(await couriers.photoUrl(submitted.photoPath), contains('token='));

      final adminClient = anonClient();
      await adminClient.auth.signInWithPassword(
        email: adminEmail,
        password: 'motdepasse1',
      );
      final people = AdminPeopleRepository(adminClient);
      final pending = await people.couriers(CourierStatus.pending);
      expect(pending.any((entry) => entry.courier.userId == courierId), isTrue);

      await expectLater(
        people.setCourierStatus(courierId, CourierStatus.rejected),
        throwsA(
          isA<AppFailure>().having((f) => f.code, 'code', 'reason_required'),
        ),
      );
      await people.setCourierStatus(courierId, CourierStatus.approved);
      expect(
        (await couriers.fetchMine(courierId))!.status,
        CourierStatus.approved,
      );

      await people.setSuspended(
        courierId,
        suspended: true,
        reason: 'Vérification en cours',
      );
      final blocked = anonClient();
      await expectLater(
        blocked.auth
            .signInWithPassword(email: courierEmail, password: 'motdepasse1')
            .catchError((Object e) => throw toFailure(e)),
        throwsA(
          isA<AppFailure>().having((f) => f.code, 'code', 'account_suspended'),
        ),
      );

      await people.setSuspended(courierId, suspended: false);
      final newEmail = 'nouveau$stamp@exemple.ci';
      await people.updateLogin(courierId, LoginIdentifier.email(newEmail));
      final again = anonClient();
      await again.auth.signInWithPassword(
        email: newEmail,
        password: 'motdepasse1',
      );
      expect(again.auth.currentUser!.id, courierId);

      for (final client in [courierClient, adminClient, blocked, again]) {
        await client.dispose();
      }
    },
  );
}
