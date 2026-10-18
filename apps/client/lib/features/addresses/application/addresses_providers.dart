import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/address_repository.dart';
import '../data/location_service.dart';

part 'addresses_providers.g.dart';

@riverpod
AddressRepository addressRepository(Ref ref) =>
    AddressRepository(ref.watch(supabaseClientProvider));

@riverpod
LocationService locationService(Ref ref) => LocationService();

/// Mes adresses (C-13) ; chaque modification relit la liste depuis le serveur, seul juge de l'adresse par défaut.
@riverpod
class Addresses extends _$Addresses {
  @override
  Future<List<Address>> build() {
    ref.watch(currentUserIdProvider);
    return ref.watch(addressRepositoryProvider).list();
  }

  Future<void> save(Address address) =>
      _mutate((repository) => repository.save(address));

  Future<void> setDefault(String id) =>
      _mutate((repository) => repository.setDefault(id));

  Future<void> delete(String id) =>
      _mutate((repository) => repository.delete(id));

  Future<void> _mutate(
    Future<void> Function(AddressRepository repository) change,
  ) async {
    final repository = ref.read(addressRepositoryProvider);
    await change(repository);
    state = AsyncData(await repository.list());
  }
}
