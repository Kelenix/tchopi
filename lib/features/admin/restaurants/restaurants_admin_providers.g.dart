// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurants_admin_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminRestaurantRepository)
final adminRestaurantRepositoryProvider = AdminRestaurantRepositoryProvider._();

final class AdminRestaurantRepositoryProvider
    extends
        $FunctionalProvider<
          AdminRestaurantRepository,
          AdminRestaurantRepository,
          AdminRestaurantRepository
        >
    with $Provider<AdminRestaurantRepository> {
  AdminRestaurantRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminRestaurantRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminRestaurantRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminRestaurantRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdminRestaurantRepository create(Ref ref) {
    return adminRestaurantRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminRestaurantRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminRestaurantRepository>(value),
    );
  }
}

String _$adminRestaurantRepositoryHash() =>
    r'71c7bf755ff16b7ef1285430630e4528e88e74d2';

@ProviderFor(adminRestaurants)
final adminRestaurantsProvider = AdminRestaurantsProvider._();

final class AdminRestaurantsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Restaurant>>,
          List<Restaurant>,
          FutureOr<List<Restaurant>>
        >
    with $FutureModifier<List<Restaurant>>, $FutureProvider<List<Restaurant>> {
  AdminRestaurantsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminRestaurantsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminRestaurantsHash();

  @$internal
  @override
  $FutureProviderElement<List<Restaurant>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Restaurant>> create(Ref ref) {
    return adminRestaurants(ref);
  }
}

String _$adminRestaurantsHash() => r'f5803170cdb1999822d9987d589027ca70fe08a1';

@ProviderFor(restaurantMembers)
final restaurantMembersProvider = RestaurantMembersFamily._();

final class RestaurantMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RestaurantMember>>,
          List<RestaurantMember>,
          FutureOr<List<RestaurantMember>>
        >
    with
        $FutureModifier<List<RestaurantMember>>,
        $FutureProvider<List<RestaurantMember>> {
  RestaurantMembersProvider._({
    required RestaurantMembersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'restaurantMembersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$restaurantMembersHash();

  @override
  String toString() {
    return r'restaurantMembersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<RestaurantMember>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RestaurantMember>> create(Ref ref) {
    final argument = this.argument as String;
    return restaurantMembers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RestaurantMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$restaurantMembersHash() => r'da927398f841483d7170a139803565b495ef3324';

final class RestaurantMembersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<RestaurantMember>>, String> {
  RestaurantMembersFamily._()
    : super(
        retry: null,
        name: r'restaurantMembersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RestaurantMembersProvider call(String id) =>
      RestaurantMembersProvider._(argument: id, from: this);

  @override
  String toString() => r'restaurantMembersProvider';
}
