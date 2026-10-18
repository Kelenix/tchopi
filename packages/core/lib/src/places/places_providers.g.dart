// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'places_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Zones actives (lecture autorisée à tout compte connecté).

@ProviderFor(activeZones)
final activeZonesProvider = ActiveZonesProvider._();

/// Zones actives (lecture autorisée à tout compte connecté).

final class ActiveZonesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Zone>>,
          List<Zone>,
          FutureOr<List<Zone>>
        >
    with $FutureModifier<List<Zone>>, $FutureProvider<List<Zone>> {
  /// Zones actives (lecture autorisée à tout compte connecté).
  ActiveZonesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeZonesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeZonesHash();

  @$internal
  @override
  $FutureProviderElement<List<Zone>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Zone>> create(Ref ref) {
    return activeZones(ref);
  }
}

String _$activeZonesHash() => r'81172348fb954d398d547a8d489aadc10dd6d0fb';

/// Villes desservies, proposées dans le profil (AUTH-03).

@ProviderFor(servedCities)
final servedCitiesProvider = ServedCitiesProvider._();

/// Villes desservies, proposées dans le profil (AUTH-03).

final class ServedCitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Villes desservies, proposées dans le profil (AUTH-03).
  ServedCitiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'servedCitiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$servedCitiesHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return servedCities(ref);
  }
}

String _$servedCitiesHash() => r'b5858a3ff8fe6b4e5558078887ad490542f48d11';
