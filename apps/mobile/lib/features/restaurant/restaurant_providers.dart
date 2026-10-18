import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/media.dart';
import 'data/restaurant_repository.dart';

part 'restaurant_providers.g.dart';

@riverpod
RestaurantRepository restaurantRepository(Ref ref) =>
    RestaurantRepository(ref.watch(supabaseClientProvider));

@riverpod
MediaRepository mediaRepository(Ref ref) =>
    MediaRepository(ref.watch(supabaseClientProvider));

/// Restaurant géré : le premier du compte (un gérant gère un restaurant au MVP).
@riverpod
String? managedRestaurantId(Ref ref) =>
    ref.watch(accountRolesProvider).value?.restaurantIds.firstOrNull;

@riverpod
Future<Restaurant> managedRestaurant(Ref ref, String id) =>
    ref.watch(restaurantRepositoryProvider).fetch(id);

@riverpod
Future<List<OpeningHour>> openingHours(Ref ref, String id) =>
    ref.watch(restaurantRepositoryProvider).hours(id);

typedef Menu = ({List<MenuCategory> categories, List<Product> products});

@riverpod
Future<Menu> restaurantMenu(Ref ref, String id) async {
  final repository = ref.watch(restaurantRepositoryProvider);
  return (
    categories: await repository.categories(id),
    products: await repository.products(id),
  );
}

/// Produits groupés par catégorie, dans l'ordre du menu ; ceux sans catégorie à la fin, sous `otherLabel`.
List<(String, List<Product>)> menuSections(Menu menu, String otherLabel) {
  final known = {for (final category in menu.categories) category.id};
  final others = menu.products.where((p) => !known.contains(p.categoryId));
  return [
    for (final category in menu.categories)
      if (menu.products.any((p) => p.categoryId == category.id))
        (
          category.name,
          menu.products.where((p) => p.categoryId == category.id).toList(),
        ),
    if (others.isNotEmpty) (otherLabel, others.toList()),
  ];
}
