import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/application/auth_providers.dart';
import '../auth/domain/app_failure.dart';
import '../supabase/supabase_setup.dart';
import 'models.dart';

part 'places_providers.g.dart';

/// Zones actives (lecture autorisée à tout compte connecté).
@riverpod
Future<List<Zone>> activeZones(Ref ref) async {
  ref.watch(currentUserIdProvider); // relu à chaque changement de compte
  final rows = await guardCall(
    () => ref
        .read(supabaseClientProvider)
        .from('zones')
        .select(
          'id, name, city, country_code, currency, timezone, center_lat, center_lng, radius_m, is_active',
        )
        .eq('is_active', true)
        .order('city'),
  );
  return rows.map(Zone.fromJson).toList();
}

/// Villes desservies, proposées dans le profil (AUTH-03).
@riverpod
Future<List<String>> servedCities(Ref ref) async => {
  for (final zone in await ref.watch(activeZonesProvider.future)) zone.city,
}.toList();
