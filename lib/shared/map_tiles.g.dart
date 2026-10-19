// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_tiles.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Style du fond de carte, clair ou sombre selon le thème, lu une fois pour toutes les cartes. Chaque style reçoit
/// son propre identifiant : sans « id », la bibliothèque les confond dans son cache (tuiles sombres en clair).

@ProviderFor(mapStyle)
final mapStyleProvider = MapStyleFamily._();

/// Style du fond de carte, clair ou sombre selon le thème, lu une fois pour toutes les cartes. Chaque style reçoit
/// son propre identifiant : sans « id », la bibliothèque les confond dans son cache (tuiles sombres en clair).

final class MapStyleProvider
    extends
        $FunctionalProvider<
          AsyncValue<vector.Style>,
          vector.Style,
          FutureOr<vector.Style>
        >
    with $FutureModifier<vector.Style>, $FutureProvider<vector.Style> {
  /// Style du fond de carte, clair ou sombre selon le thème, lu une fois pour toutes les cartes. Chaque style reçoit
  /// son propre identifiant : sans « id », la bibliothèque les confond dans son cache (tuiles sombres en clair).
  MapStyleProvider._({
    required MapStyleFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'mapStyleProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mapStyleHash();

  @override
  String toString() {
    return r'mapStyleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<vector.Style> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<vector.Style> create(Ref ref) {
    final argument = this.argument as bool;
    return mapStyle(ref, dark: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MapStyleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mapStyleHash() => r'd29e7d5784c88d00ba0789e39df72f985606c3d6';

/// Style du fond de carte, clair ou sombre selon le thème, lu une fois pour toutes les cartes. Chaque style reçoit
/// son propre identifiant : sans « id », la bibliothèque les confond dans son cache (tuiles sombres en clair).

final class MapStyleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<vector.Style>, bool> {
  MapStyleFamily._()
    : super(
        retry: null,
        name: r'mapStyleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Style du fond de carte, clair ou sombre selon le thème, lu une fois pour toutes les cartes. Chaque style reçoit
  /// son propre identifiant : sans « id », la bibliothèque les confond dans son cache (tuiles sombres en clair).

  MapStyleProvider call({required bool dark}) =>
      MapStyleProvider._(argument: dark, from: this);

  @override
  String toString() => r'mapStyleProvider';
}
