import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'data/admin_zone_repository.dart';

part 'zones_providers.g.dart';

@riverpod
AdminZoneRepository adminZoneRepository(Ref ref) =>
    AdminZoneRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<List<Zone>> adminZones(Ref ref) =>
    ref.watch(adminZoneRepositoryProvider).list();

@riverpod
Future<List<PricingRule>> zonePricing(Ref ref, String zoneId) =>
    ref.watch(adminZoneRepositoryProvider).pricing(zoneId);
