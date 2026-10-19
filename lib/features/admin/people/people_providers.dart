import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'data/admin_people_repository.dart';

part 'people_providers.g.dart';

@riverpod
AdminPeopleRepository adminPeopleRepository(Ref ref) =>
    AdminPeopleRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<List<CourierEntry>> adminCouriers(Ref ref, CourierStatus status) =>
    ref.watch(adminPeopleRepositoryProvider).couriers(status);

@riverpod
Future<String> adminCourierPhoto(Ref ref, String path) =>
    ref.watch(adminPeopleRepositoryProvider).courierPhotoUrl(path);

@riverpod
Future<List<UserEntry>> adminUsers(Ref ref, String query) =>
    ref.watch(adminPeopleRepositoryProvider).searchUsers(query);
