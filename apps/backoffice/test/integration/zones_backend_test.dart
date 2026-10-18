@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:backoffice/features/zones/data/admin_zone_repository.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Zones et tarifs réels contre Supabase local, avec un compte admin créé pour le test
/// (clé de service locale lue via `supabase status`, jamais écrite sur disque).
void main() {
  setUpAll(() => HttpOverrides.global = null);

  final env =
      jsonDecode(File('../../env/local.json').readAsStringSync())
          as Map<String, dynamic>;
  final url = env['SUPABASE_URL'] as String;
  late SupabaseClient service;
  late SupabaseClient admin;
  late String adminId;
  String? zoneId;

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
    final email = 'admin${DateTime.now().microsecondsSinceEpoch}@exemple.ci';
    adminId = (await service.auth.admin.createUser(
      AdminUserAttributes(
        email: email,
        password: 'motdepasse1',
        emailConfirm: true,
      ),
    )).user!.id;
    await service.from('admins').insert({'user_id': adminId});

    admin = SupabaseClient(url, env['SUPABASE_ANON_KEY'] as String);
    await admin.auth.signInWithPassword(email: email, password: 'motdepasse1');
  });

  tearDownAll(() async {
    if (zoneId != null) await service.from('zones').delete().eq('id', zoneId!);
    await service.auth.admin.deleteUser(adminId);
    admin.dispose();
    service.dispose();
  });

  test(
    'création d\'une zone avec ses deux règles, lecture, simulation et modification',
    () async {
      final repository = AdminZoneRepository(admin);
      const rules = [
        PricingRule(
          zoneId: '',
          service: Service.food,
          baseFee: 500,
          perKmFee: 150,
          minFee: 500,
          maxFee: 3000,
          courierBase: 400,
          courierPerKm: 100,
        ),
        PricingRule(
          zoneId: '',
          service: Service.parcel,
          baseFee: 700,
          perKmFee: 175,
          minFee: 700,
          maxFee: 4000,
          courierBase: 500,
          courierPerKm: 120,
        ),
      ];
      zoneId = await repository.save(
        const Zone(
          id: '',
          name: 'Yamoussoukro test',
          city: 'Yamoussoukro',
          centerLat: 6.8276,
          centerLng: -5.2893,
          radiusM: 8000,
        ),
        rules,
        isNew: true,
      );

      expect((await repository.list()).any((z) => z.id == zoneId), isTrue);
      expect((await repository.pricing(zoneId!)).length, 2);

      final simulation = await repository.simulate(zoneId!, Service.food, 4);
      expect(simulation, (
        distanceM: 5200,
        deliveryFee: 1300,
        courierEarning: 925,
      ));

      await repository.save(
        Zone(
          id: zoneId!,
          name: 'Yamoussoukro test',
          city: 'Yamoussoukro',
          centerLat: 6.8276,
          centerLng: -5.2893,
          radiusM: 8000,
          isActive: false,
        ),
        [rules.first.copyWith(baseFee: 600), rules.last],
        isNew: false,
      );
      final updated = (await repository.list()).firstWhere(
        (z) => z.id == zoneId,
      );
      expect(updated.isActive, isFalse);
      expect(
        (await repository.simulate(zoneId!, Service.food, 4)).deliveryFee,
        1400,
      );
    },
  );
}
