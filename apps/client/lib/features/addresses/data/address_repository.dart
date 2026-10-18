import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Adresses du client connecté (RLS : chacun ne voit que les siennes).
class AddressRepository {
  AddressRepository(this._client);

  final SupabaseClient _client;

  static const _columns =
      'id, label, district, landmark, instructions, latitude, longitude, city, is_default';

  Future<List<Address>> list() => guardCall(() async {
    final rows = await _client
        .from('addresses')
        .select(_columns)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);
    return rows.map(Address.fromJson).toList();
  });

  Future<void> save(Address address) => guardCall(() async {
    final id = address.id;
    final query = _client.from('addresses');
    await (id == null
        ? query.insert(address.toWritableJson())
        : query.update(address.toWritableJson()).eq('id', id));
  });

  Future<void> setDefault(String id) => guardCall(
    () => _client.from('addresses').update({'is_default': true}).eq('id', id),
  );

  Future<void> delete(String id) =>
      guardCall(() => _client.from('addresses').delete().eq('id', id));
}
