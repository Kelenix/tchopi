@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:client/features/addresses/data/address_repository.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Adresses réelles contre Supabase local (`supabase db reset` : zone « Abidjan » des données de développement).
void main() {
  setUpAll(() => HttpOverrides.global = null);

  final env =
      jsonDecode(File('../../env/local.json').readAsStringSync())
          as Map<String, dynamic>;
  late SupabaseClient client;
  late AddressRepository addresses;

  setUpAll(() async {
    client = SupabaseClient(
      env['SUPABASE_URL'] as String,
      env['SUPABASE_ANON_KEY'] as String,
      authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
    );
    // Numéro de test local (code fixe 123456) ; créé au premier passage.
    const phone = '+2250700000002';
    try {
      await client.auth.signInWithPassword(
        phone: phone,
        password: 'motdepasse1',
      );
    } on AuthException {
      await client.auth.signUp(phone: phone, password: 'motdepasse1');
      await client.auth.verifyOTP(
        type: OtpType.sms,
        phone: phone,
        token: '123456',
      );
    }
    addresses = AddressRepository(client);
    for (final address in await addresses.list()) {
      await addresses.delete(address.id!);
    }
  });

  tearDownAll(() => client.dispose());

  test(
    'ajout, ville déduite, adresse par défaut, refus hors zone, suppression',
    () async {
      await addresses.save(
        const Address(
          district: 'Cocody',
          landmark: 'Derrière la pharmacie centrale',
          latitude: 5.3600,
          longitude: -3.9900,
        ),
      );
      var list = await addresses.list();
      expect(list.single.city, 'Abidjan');
      expect(list.single.isDefault, isTrue);

      await addresses.save(
        const Address(
          label: 'Bureau',
          district: 'Plateau',
          landmark: 'Tour A',
          latitude: 5.3250,
          longitude: -4.0200,
        ),
      );
      final office = (await addresses.list()).firstWhere(
        (a) => a.label == 'Bureau',
      );
      await addresses.setDefault(office.id!);
      list = await addresses.list();
      expect(list.where((a) => a.isDefault).single.label, 'Bureau');

      await expectLater(
        addresses.save(
          const Address(
            district: 'Bouaké',
            landmark: 'Gare',
            latitude: 7.69,
            longitude: -5.03,
          ),
        ),
        throwsA(
          isA<AppFailure>().having(
            (f) => f.code,
            'code',
            'address_out_of_zone',
          ),
        ),
      );

      await addresses.delete(office.id!);
      list = await addresses.list();
      expect(
        list.single.isDefault,
        isTrue,
        reason: 'la dernière adresse redevient l\'adresse par défaut',
      );
    },
  );
}
