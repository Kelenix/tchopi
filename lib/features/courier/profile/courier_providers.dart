import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'data/courier_repository.dart';

part 'courier_providers.g.dart';

@riverpod
CourierRepository courierRepository(Ref ref) =>
    CourierRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<Courier?> myCourier(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  return userId == null
      ? null
      : ref.watch(courierRepositoryProvider).fetchMine(userId);
}

@riverpod
Future<String> courierPhotoUrl(Ref ref, String path) =>
    ref.watch(courierRepositoryProvider).photoUrl(path);
