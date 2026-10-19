// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'people_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminPeopleRepository)
final adminPeopleRepositoryProvider = AdminPeopleRepositoryProvider._();

final class AdminPeopleRepositoryProvider
    extends
        $FunctionalProvider<
          AdminPeopleRepository,
          AdminPeopleRepository,
          AdminPeopleRepository
        >
    with $Provider<AdminPeopleRepository> {
  AdminPeopleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminPeopleRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminPeopleRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminPeopleRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdminPeopleRepository create(Ref ref) {
    return adminPeopleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminPeopleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminPeopleRepository>(value),
    );
  }
}

String _$adminPeopleRepositoryHash() =>
    r'25ac720654ac8d0993d5a598365bcb4de199fc78';

@ProviderFor(adminCouriers)
final adminCouriersProvider = AdminCouriersFamily._();

final class AdminCouriersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CourierEntry>>,
          List<CourierEntry>,
          FutureOr<List<CourierEntry>>
        >
    with
        $FutureModifier<List<CourierEntry>>,
        $FutureProvider<List<CourierEntry>> {
  AdminCouriersProvider._({
    required AdminCouriersFamily super.from,
    required CourierStatus super.argument,
  }) : super(
         retry: null,
         name: r'adminCouriersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminCouriersHash();

  @override
  String toString() {
    return r'adminCouriersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CourierEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CourierEntry>> create(Ref ref) {
    final argument = this.argument as CourierStatus;
    return adminCouriers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminCouriersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminCouriersHash() => r'93a95551d319f843220f643bc717fd175c324b9d';

final class AdminCouriersFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<CourierEntry>>, CourierStatus> {
  AdminCouriersFamily._()
    : super(
        retry: null,
        name: r'adminCouriersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AdminCouriersProvider call(CourierStatus status) =>
      AdminCouriersProvider._(argument: status, from: this);

  @override
  String toString() => r'adminCouriersProvider';
}

@ProviderFor(adminCourierPhoto)
final adminCourierPhotoProvider = AdminCourierPhotoFamily._();

final class AdminCourierPhotoProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  AdminCourierPhotoProvider._({
    required AdminCourierPhotoFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'adminCourierPhotoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminCourierPhotoHash();

  @override
  String toString() {
    return r'adminCourierPhotoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as String;
    return adminCourierPhoto(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminCourierPhotoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminCourierPhotoHash() => r'13ef9b856aec7660f77e904c931d30afd0bb9edb';

final class AdminCourierPhotoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  AdminCourierPhotoFamily._()
    : super(
        retry: null,
        name: r'adminCourierPhotoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AdminCourierPhotoProvider call(String path) =>
      AdminCourierPhotoProvider._(argument: path, from: this);

  @override
  String toString() => r'adminCourierPhotoProvider';
}

@ProviderFor(adminUsers)
final adminUsersProvider = AdminUsersFamily._();

final class AdminUsersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserEntry>>,
          List<UserEntry>,
          FutureOr<List<UserEntry>>
        >
    with $FutureModifier<List<UserEntry>>, $FutureProvider<List<UserEntry>> {
  AdminUsersProvider._({
    required AdminUsersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'adminUsersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminUsersHash();

  @override
  String toString() {
    return r'adminUsersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<UserEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UserEntry>> create(Ref ref) {
    final argument = this.argument as String;
    return adminUsers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminUsersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminUsersHash() => r'df5c2aafc40b8d0b3e2b29f6e57ccba1ab4a8423';

final class AdminUsersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<UserEntry>>, String> {
  AdminUsersFamily._()
    : super(
        retry: null,
        name: r'adminUsersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AdminUsersProvider call(String query) =>
      AdminUsersProvider._(argument: query, from: this);

  @override
  String toString() => r'adminUsersProvider';
}
