import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/more_pages.dart';

/// Livreur vu par l'admin : profil livreur + identité + zone.
typedef CourierEntry = ({
  Courier courier,
  String name,
  String phone,
  String zone,
});

/// Compte vu par l'admin (A-06).
typedef UserEntry = ({
  String id,
  String name,
  String phone,
  String city,
  bool isSuspended,
});

/// Livreurs et comptes (admins uniquement, garanti par la RLS et les fonctions serveur).
class AdminPeopleRepository {
  AdminPeopleRepository(this._client);

  final SupabaseClient _client;

  static String _name(Map<String, dynamic>? profile) => [
    profile?['first_name'],
    profile?['last_name'],
  ].whereType<String>().join(' ').trim();

  Future<List<CourierEntry>> couriers(
    CourierStatus status,
  ) => guardCall(() async {
    final rows = await _client
        .from('couriers')
        .select(
          '*, profile:profiles(first_name, last_name, phone), zone:zones(name)',
        )
        .eq('status', status.name)
        .order('updated_at', ascending: false);
    return [
      for (final row in rows)
        (
          courier: Courier.fromJson(row),
          name: _name(row['profile'] as Map<String, dynamic>?),
          phone:
              (row['profile'] as Map<String, dynamic>?)?['phone'] as String? ??
              '',
          zone:
              (row['zone'] as Map<String, dynamic>?)?['name'] as String? ?? '',
        ),
    ];
  });

  Future<void> setCourierStatus(
    String userId,
    CourierStatus status, {
    String? reason,
  }) => guardCall(
    () => _client.rpc<void>(
      'admin_set_courier_status',
      params: {
        'p_user_id': userId,
        'p_status': status.name,
        'p_reason': reason,
      },
    ),
  );

  Future<String> courierPhotoUrl(String path) => guardCall(
    () => _client.storage.from('couriers').createSignedUrl(path, 3600),
  );

  /// Recherche par prénom, nom ou téléphone, les plus récents d'abord, page par page.
  Future<List<UserEntry>> searchUsers(
    String query, {
    int offset = 0,
    int limit = pageSize,
  }) => guardCall(() async {
    final term = query.trim().replaceAll(RegExp(r'[,()*%]'), '');
    var request = _client
        .from('profiles')
        .select('id, first_name, last_name, phone, city, is_suspended');
    if (term.isNotEmpty) {
      request = request.or(
        'first_name.ilike.*$term*,last_name.ilike.*$term*,phone.ilike.*$term*',
      );
    }
    final rows = await request
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return [
      for (final row in rows)
        (
          id: row['id'] as String,
          name: _name(row),
          phone: row['phone'] as String? ?? '',
          city: row['city'] as String? ?? '',
          isSuspended: row['is_suspended'] as bool,
        ),
    ];
  });

  Future<void> setSuspended(
    String userId, {
    required bool suspended,
    String? reason,
  }) => _adminAction({
    'action': suspended ? 'suspend' : 'reactivate',
    'user_id': userId,
    'reason': reason,
  });

  Future<void> updateLogin(String userId, LoginIdentifier identifier) =>
      _adminAction({
        'action': 'update_login',
        'user_id': userId,
        if (identifier.isEmail)
          'email': identifier.value
        else
          'phone': identifier.value,
      });

  Future<void> _adminAction(Map<String, dynamic> body) =>
      guardCall(() => _client.functions.invoke('admin-users', body: body));
}
