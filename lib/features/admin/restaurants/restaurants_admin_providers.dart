import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'data/admin_restaurant_repository.dart';

part 'restaurants_admin_providers.g.dart';

@riverpod
AdminRestaurantRepository adminRestaurantRepository(Ref ref) =>
    AdminRestaurantRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<List<Restaurant>> adminRestaurants(Ref ref) =>
    ref.watch(adminRestaurantRepositoryProvider).list();

@riverpod
Future<List<RestaurantMember>> restaurantMembers(Ref ref, String id) =>
    ref.watch(adminRestaurantRepositoryProvider).members(id);

@riverpod
Future<Set<String>> restaurantCouriers(Ref ref, String id) =>
    ref.watch(adminRestaurantRepositoryProvider).affiliatedCouriers(id);
