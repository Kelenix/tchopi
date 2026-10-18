import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef FeeSimulation = ({int distanceM, int deliveryFee, int courierEarning});

/// Zones desservies et règles tarifaires (admins uniquement, garanti par la RLS).
class AdminZoneRepository {
  AdminZoneRepository(this._client);

  final SupabaseClient _client;

  Future<List<Zone>> list() => guardCall(() async {
    final rows = await _client
        .from('zones')
        .select()
        .order('city')
        .order('name');
    return rows.map(Zone.fromJson).toList();
  });

  Future<List<PricingRule>> pricing(String zoneId) => guardCall(() async {
    final rows = await _client
        .from('pricing_rules')
        .select()
        .eq('zone_id', zoneId);
    return rows.map(PricingRule.fromJson).toList();
  });

  /// Enregistre la zone puis ses règles (une par service) ; renvoie l'identifiant de la zone.
  Future<String> save(
    Zone zone,
    List<PricingRule> rules, {
    required bool isNew,
  }) => guardCall(() async {
    final fields = {
      'name': zone.name.trim(),
      'city': zone.city.trim(),
      'center_lat': zone.centerLat,
      'center_lng': zone.centerLng,
      'radius_m': zone.radiusM,
      'is_active': zone.isActive,
    };
    final row = await (isNew
        ? _client.from('zones').insert(fields).select('id').single()
        : _client
              .from('zones')
              .update(fields)
              .eq('id', zone.id)
              .select('id')
              .single());
    final zoneId = row['id'] as String;
    await _client.from('pricing_rules').upsert([
      for (final rule in rules) rule.copyWith(zoneId: zoneId).toJson(),
    ]);
    return zoneId;
  });

  Future<FeeSimulation> simulate(
    String zoneId,
    Service service,
    double straightKm,
  ) => guardCall(() async {
    final rows = await _client.rpc<List<dynamic>>(
      'admin_simulate_fee',
      params: {
        'p_zone_id': zoneId,
        'p_service': service.name,
        'p_straight_km': straightKm,
      },
    );
    final row = rows.single as Map<String, dynamic>;
    return (
      distanceM: row['distance_m'] as int,
      deliveryFee: row['delivery_fee'] as int,
      courierEarning: row['courier_earning'] as int,
    );
  });
}
