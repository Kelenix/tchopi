// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_map.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Trajet routier entre deux points (OSRM, ADR-038), calculé une fois par trajet ; ligne droite si le service ne
/// répond pas, pour que la carte reste utile.

@ProviderFor(roadRoute)
final roadRouteProvider = RoadRouteFamily._();

/// Trajet routier entre deux points (OSRM, ADR-038), calculé une fois par trajet ; ligne droite si le service ne
/// répond pas, pour que la carte reste utile.

final class RoadRouteProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LatLng>>,
          List<LatLng>,
          FutureOr<List<LatLng>>
        >
    with $FutureModifier<List<LatLng>>, $FutureProvider<List<LatLng>> {
  /// Trajet routier entre deux points (OSRM, ADR-038), calculé une fois par trajet ; ligne droite si le service ne
  /// répond pas, pour que la carte reste utile.
  RoadRouteProvider._({
    required RoadRouteFamily super.from,
    required (LatLng, LatLng) super.argument,
  }) : super(
         retry: null,
         name: r'roadRouteProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$roadRouteHash();

  @override
  String toString() {
    return r'roadRouteProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<LatLng>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LatLng>> create(Ref ref) {
    final argument = this.argument as (LatLng, LatLng);
    return roadRoute(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is RoadRouteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$roadRouteHash() => r'90c43099976f3a70c2db9b92433ee07b3b6afe78';

/// Trajet routier entre deux points (OSRM, ADR-038), calculé une fois par trajet ; ligne droite si le service ne
/// répond pas, pour que la carte reste utile.

final class RoadRouteFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<LatLng>>, (LatLng, LatLng)> {
  RoadRouteFamily._()
    : super(
        retry: null,
        name: r'roadRouteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Trajet routier entre deux points (OSRM, ADR-038), calculé une fois par trajet ; ligne droite si le service ne
  /// répond pas, pour que la carte reste utile.

  RoadRouteProvider call(LatLng from, LatLng to) =>
      RoadRouteProvider._(argument: (from, to), from: this);

  @override
  String toString() => r'roadRouteProvider';
}
