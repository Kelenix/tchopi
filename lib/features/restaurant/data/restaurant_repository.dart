import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Restaurant géré par le compte connecté : profil, horaires, catégories, produits (RLS : ses gérants seulement).
class RestaurantRepository {
  RestaurantRepository(this._client);

  final SupabaseClient _client;

  Future<Restaurant> fetch(String id) => guardCall(() async {
    final row = await _client
        .from('restaurants')
        .select('*, is_open')
        .eq('id', id)
        .single();
    return Restaurant.fromJson(row);
  });

  /// Restaurants proposés aux clients : actifs, ouverts d'abord (RLS : actifs seulement).
  Future<List<Restaurant>> active() => guardCall(() async {
    final rows = await _client
        .from('restaurants')
        .select('*, is_open')
        .eq('is_active', true)
        .order('name', ascending: true);
    final restaurants = rows.map(Restaurant.fromJson).toList();
    return [
      ...restaurants.where((r) => r.isOpen),
      ...restaurants.where((r) => !r.isOpen),
    ];
  });

  Future<void> updateProfile(Restaurant restaurant) => guardCall(
    () => _client
        .from('restaurants')
        .update({
          'description': restaurant.description?.trim(),
          'category': restaurant.category?.trim(),
          'cover_path': restaurant.coverPath,
          'phone': restaurant.phone,
          'prep_time_min': restaurant.prepTimeMin,
          'is_temporarily_closed': restaurant.isTemporarilyClosed,
        })
        .eq('id', restaurant.id),
  );

  Future<void> setTemporarilyClosed(String id, {required bool closed}) =>
      guardCall(
        () => _client
            .from('restaurants')
            .update({'is_temporarily_closed': closed})
            .eq('id', id),
      );

  Future<List<OpeningHour>> hours(String id) => guardCall(() async {
    final rows = await _client
        .from('opening_hours')
        .select('weekday, opens_at, closes_at')
        .eq('restaurant_id', id)
        .order('weekday', ascending: true)
        .order('opens_at', ascending: true);
    return rows.map(OpeningHour.fromJson).toList();
  });

  Future<void> saveHours(String id, List<OpeningHour> hours) => guardCall(
    () => _client.rpc<void>(
      'save_opening_hours',
      params: {
        'p_restaurant_id': id,
        'p_hours': [for (final hour in hours) hour.toJson()],
      },
    ),
  );

  Future<List<MenuCategory>> categories(String id) => guardCall(() async {
    final rows = await _client
        .from('categories')
        .select('id, name, position')
        .eq('restaurant_id', id)
        .order('position', ascending: true)
        .order('name', ascending: true);
    return rows.map(MenuCategory.fromJson).toList();
  });

  Future<MenuCategory> addCategory(
    String restaurantId,
    String name,
    int position,
  ) => guardCall(() async {
    final row = await _client
        .from('categories')
        .insert({
          'restaurant_id': restaurantId,
          'name': name.trim(),
          'position': position,
        })
        .select('id, name, position')
        .single();
    return MenuCategory.fromJson(row);
  });

  /// Produits au menu (les produits retirés restent en base pour l'historique des commandes).
  Future<List<Product>> products(String id) => guardCall(() async {
    final rows = await _client
        .from('products')
        .select()
        .eq('restaurant_id', id)
        .isFilter('archived_at', null)
        .order('name', ascending: true);
    return rows.map(Product.fromJson).toList();
  });

  Future<void> saveProduct(Product product) => guardCall(() async {
    final fields = {
      'restaurant_id': product.restaurantId,
      'category_id': product.categoryId,
      'name': product.name.trim(),
      'description': (product.description?.trim().isEmpty ?? true)
          ? null
          : product.description!.trim(),
      'price': product.price,
      'photo_path': product.photoPath,
      'is_available': product.isAvailable,
    };
    final id = product.id;
    await (id == null
        ? _client.from('products').insert(fields)
        : _client.from('products').update(fields).eq('id', id));
  });

  Future<void> setAvailable(String productId, {required bool available}) =>
      guardCall(
        () => _client
            .from('products')
            .update({'is_available': available})
            .eq('id', productId),
      );

  Future<void> archive(String productId) => guardCall(
    () => _client
        .from('products')
        .update({'archived_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', productId),
  );
}
