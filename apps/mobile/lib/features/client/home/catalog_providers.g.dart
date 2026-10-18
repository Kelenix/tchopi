// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(catalogRestaurants)
final catalogRestaurantsProvider = CatalogRestaurantsProvider._();

final class CatalogRestaurantsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Restaurant>>,
          List<Restaurant>,
          FutureOr<List<Restaurant>>
        >
    with $FutureModifier<List<Restaurant>>, $FutureProvider<List<Restaurant>> {
  CatalogRestaurantsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogRestaurantsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogRestaurantsHash();

  @$internal
  @override
  $FutureProviderElement<List<Restaurant>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Restaurant>> create(Ref ref) {
    return catalogRestaurants(ref);
  }
}

String _$catalogRestaurantsHash() =>
    r'ff4a6f852cee9ec57214b215ce64407f3d178155';

@ProviderFor(catalogRestaurant)
final catalogRestaurantProvider = CatalogRestaurantFamily._();

final class CatalogRestaurantProvider
    extends
        $FunctionalProvider<
          AsyncValue<Restaurant>,
          Restaurant,
          FutureOr<Restaurant>
        >
    with $FutureModifier<Restaurant>, $FutureProvider<Restaurant> {
  CatalogRestaurantProvider._({
    required CatalogRestaurantFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'catalogRestaurantProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$catalogRestaurantHash();

  @override
  String toString() {
    return r'catalogRestaurantProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Restaurant> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Restaurant> create(Ref ref) {
    final argument = this.argument as String;
    return catalogRestaurant(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CatalogRestaurantProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$catalogRestaurantHash() => r'ca97d77db90777f843580bb7f8cd2151eb976efe';

final class CatalogRestaurantFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Restaurant>, String> {
  CatalogRestaurantFamily._()
    : super(
        retry: null,
        name: r'catalogRestaurantProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CatalogRestaurantProvider call(String id) =>
      CatalogRestaurantProvider._(argument: id, from: this);

  @override
  String toString() => r'catalogRestaurantProvider';
}
