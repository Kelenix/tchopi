// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spaces.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Dernier espace choisi, mémorisé sur l'appareil.

@ProviderFor(ActiveSpace)
final activeSpaceProvider = ActiveSpaceProvider._();

/// Dernier espace choisi, mémorisé sur l'appareil.
final class ActiveSpaceProvider
    extends $AsyncNotifierProvider<ActiveSpace, AppSpace?> {
  /// Dernier espace choisi, mémorisé sur l'appareil.
  ActiveSpaceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeSpaceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeSpaceHash();

  @$internal
  @override
  ActiveSpace create() => ActiveSpace();
}

String _$activeSpaceHash() => r'9d4c57fb492577652aefc9cf07e9cbfe0388b987';

/// Dernier espace choisi, mémorisé sur l'appareil.

abstract class _$ActiveSpace extends $AsyncNotifier<AppSpace?> {
  FutureOr<AppSpace?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppSpace?>, AppSpace?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppSpace?>, AppSpace?>,
              AsyncValue<AppSpace?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
