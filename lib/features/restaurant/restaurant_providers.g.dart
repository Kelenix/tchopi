// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(restaurantRepository)
final restaurantRepositoryProvider = RestaurantRepositoryProvider._();

final class RestaurantRepositoryProvider
    extends
        $FunctionalProvider<
          RestaurantRepository,
          RestaurantRepository,
          RestaurantRepository
        >
    with $Provider<RestaurantRepository> {
  RestaurantRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restaurantRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restaurantRepositoryHash();

  @$internal
  @override
  $ProviderElement<RestaurantRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RestaurantRepository create(Ref ref) {
    return restaurantRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RestaurantRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RestaurantRepository>(value),
    );
  }
}

String _$restaurantRepositoryHash() =>
    r'6b56a3798f74e3459f3747e7394148403c8895d0';

@ProviderFor(mediaRepository)
final mediaRepositoryProvider = MediaRepositoryProvider._();

final class MediaRepositoryProvider
    extends
        $FunctionalProvider<MediaRepository, MediaRepository, MediaRepository>
    with $Provider<MediaRepository> {
  MediaRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaRepositoryHash();

  @$internal
  @override
  $ProviderElement<MediaRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MediaRepository create(Ref ref) {
    return mediaRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaRepository>(value),
    );
  }
}

String _$mediaRepositoryHash() => r'cbdc907a0230d8853bb54640ebc04e244efec386';

/// Restaurant géré : le premier du compte (un gérant gère un restaurant au MVP).

@ProviderFor(managedRestaurantId)
final managedRestaurantIdProvider = ManagedRestaurantIdProvider._();

/// Restaurant géré : le premier du compte (un gérant gère un restaurant au MVP).

final class ManagedRestaurantIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Restaurant géré : le premier du compte (un gérant gère un restaurant au MVP).
  ManagedRestaurantIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'managedRestaurantIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$managedRestaurantIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return managedRestaurantId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$managedRestaurantIdHash() =>
    r'274a8979cc2344cbd964db0d3ca382fb7be12ec6';

@ProviderFor(managedRestaurant)
final managedRestaurantProvider = ManagedRestaurantFamily._();

final class ManagedRestaurantProvider
    extends
        $FunctionalProvider<
          AsyncValue<Restaurant>,
          Restaurant,
          FutureOr<Restaurant>
        >
    with $FutureModifier<Restaurant>, $FutureProvider<Restaurant> {
  ManagedRestaurantProvider._({
    required ManagedRestaurantFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'managedRestaurantProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$managedRestaurantHash();

  @override
  String toString() {
    return r'managedRestaurantProvider'
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
    return managedRestaurant(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ManagedRestaurantProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$managedRestaurantHash() => r'48c17380723da2558a4994c1c84f76580a1dca40';

final class ManagedRestaurantFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Restaurant>, String> {
  ManagedRestaurantFamily._()
    : super(
        retry: null,
        name: r'managedRestaurantProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ManagedRestaurantProvider call(String id) =>
      ManagedRestaurantProvider._(argument: id, from: this);

  @override
  String toString() => r'managedRestaurantProvider';
}

@ProviderFor(openingHours)
final openingHoursProvider = OpeningHoursFamily._();

final class OpeningHoursProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<OpeningHour>>,
          List<OpeningHour>,
          FutureOr<List<OpeningHour>>
        >
    with
        $FutureModifier<List<OpeningHour>>,
        $FutureProvider<List<OpeningHour>> {
  OpeningHoursProvider._({
    required OpeningHoursFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'openingHoursProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$openingHoursHash();

  @override
  String toString() {
    return r'openingHoursProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<OpeningHour>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<OpeningHour>> create(Ref ref) {
    final argument = this.argument as String;
    return openingHours(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OpeningHoursProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$openingHoursHash() => r'35bedfcebf889a586a648d75ce7bb268ba533252';

final class OpeningHoursFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<OpeningHour>>, String> {
  OpeningHoursFamily._()
    : super(
        retry: null,
        name: r'openingHoursProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OpeningHoursProvider call(String id) =>
      OpeningHoursProvider._(argument: id, from: this);

  @override
  String toString() => r'openingHoursProvider';
}

@ProviderFor(restaurantMenu)
final restaurantMenuProvider = RestaurantMenuFamily._();

final class RestaurantMenuProvider
    extends $FunctionalProvider<AsyncValue<Menu>, Menu, FutureOr<Menu>>
    with $FutureModifier<Menu>, $FutureProvider<Menu> {
  RestaurantMenuProvider._({
    required RestaurantMenuFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'restaurantMenuProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$restaurantMenuHash();

  @override
  String toString() {
    return r'restaurantMenuProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Menu> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Menu> create(Ref ref) {
    final argument = this.argument as String;
    return restaurantMenu(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RestaurantMenuProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$restaurantMenuHash() => r'532429860eed4f1dfbfe20a6680972998a6b9d48';

final class RestaurantMenuFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Menu>, String> {
  RestaurantMenuFamily._()
    : super(
        retry: null,
        name: r'restaurantMenuProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RestaurantMenuProvider call(String id) =>
      RestaurantMenuProvider._(argument: id, from: this);

  @override
  String toString() => r'restaurantMenuProvider';
}
