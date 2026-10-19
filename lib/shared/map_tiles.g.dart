// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_tiles.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Style du fond de carte (Env.mapStyleUrl), lu une fois pour toutes les cartes.

@ProviderFor(mapStyle)
final mapStyleProvider = MapStyleProvider._();

/// Style du fond de carte (Env.mapStyleUrl), lu une fois pour toutes les cartes.

final class MapStyleProvider
    extends
        $FunctionalProvider<
          AsyncValue<vector.Style>,
          vector.Style,
          FutureOr<vector.Style>
        >
    with $FutureModifier<vector.Style>, $FutureProvider<vector.Style> {
  /// Style du fond de carte (Env.mapStyleUrl), lu une fois pour toutes les cartes.
  MapStyleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapStyleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapStyleHash();

  @$internal
  @override
  $FutureProviderElement<vector.Style> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<vector.Style> create(Ref ref) {
    return mapStyle(ref);
  }
}

String _$mapStyleHash() => r'c2a929a809be2a20c64e4da8b20e92464d371b6b';
