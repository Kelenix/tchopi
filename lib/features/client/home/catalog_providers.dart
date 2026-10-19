import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../restaurant/restaurant_providers.dart';

part 'catalog_providers.g.dart';

@riverpod
Future<List<Restaurant>> catalogRestaurants(Ref ref) =>
    ref.watch(restaurantRepositoryProvider).active();

@riverpod
Future<Restaurant> catalogRestaurant(Ref ref, String id) =>
    ref.watch(restaurantRepositoryProvider).fetch(id);
