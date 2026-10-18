import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Gérant ou invitation en attente ; `login` est l'email ou le numéro invité.
typedef RestaurantMember = ({String id, String login, bool linked});

/// Restaurants partenaires et leurs gérants (admins uniquement, garanti par la RLS et les fonctions SQL).
class AdminRestaurantRepository {
  AdminRestaurantRepository(this._client);

  final SupabaseClient _client;

  Future<List<Restaurant>> list() => guardCall(() async {
    final rows = await _client
        .from('restaurants')
        .select('*, is_open')
        .order('name', ascending: true);
    return rows.map(Restaurant.fromJson).toList();
  });

  /// Crée ou met à jour le restaurant (zone, position, commission, activation) ; renvoie son identifiant.
  Future<String> save(Restaurant restaurant, {required bool isNew}) =>
      guardCall(
        () => _client.rpc<String>(
          'admin_save_restaurant',
          params: {
            'p_id': isNew ? null : restaurant.id,
            'p_zone_id': restaurant.zoneId,
            'p_name': restaurant.name,
            'p_description': restaurant.description,
            'p_category': restaurant.category,
            'p_phone': restaurant.phone,
            'p_latitude': restaurant.latitude,
            'p_longitude': restaurant.longitude,
            'p_district': restaurant.district,
            'p_landmark': restaurant.landmark,
            'p_commission_rate': restaurant.commissionRate,
            'p_is_active': restaurant.isActive,
          },
        ),
      );

  Future<List<RestaurantMember>> members(String restaurantId) =>
      guardCall(() async {
        final rows = await _client
            .from('restaurant_members')
            .select('id, user_id, login_email, login_phone')
            .eq('restaurant_id', restaurantId)
            .order('created_at', ascending: true);
        return [
          for (final row in rows)
            (
              id: row['id'] as String,
              login: (row['login_email'] ?? row['login_phone']) as String,
              linked: row['user_id'] != null,
            ),
        ];
      });

  Future<void> invite(String restaurantId, LoginIdentifier login) => guardCall(
    () => _client.rpc<void>(
      'admin_invite_member',
      params: {
        'p_restaurant_id': restaurantId,
        'p_email': login.isEmail ? login.value : null,
        'p_phone': login.isEmail ? null : login.value,
      },
    ),
  );

  Future<void> remove(String memberId) => guardCall(
    () => _client.rpc<void>(
      'admin_remove_member',
      params: {'p_member_id': memberId},
    ),
  );
}
