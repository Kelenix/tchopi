// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_preference.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Apparence choisie par l'utilisateur (ADR-038) : automatique (réglage du téléphone), clair ou sombre ;
/// mémorisée sur l'appareil.

@ProviderFor(ThemePreference)
final themePreferenceProvider = ThemePreferenceProvider._();

/// Apparence choisie par l'utilisateur (ADR-038) : automatique (réglage du téléphone), clair ou sombre ;
/// mémorisée sur l'appareil.
final class ThemePreferenceProvider
    extends $NotifierProvider<ThemePreference, ThemeMode> {
  /// Apparence choisie par l'utilisateur (ADR-038) : automatique (réglage du téléphone), clair ou sombre ;
  /// mémorisée sur l'appareil.
  ThemePreferenceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themePreferenceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themePreferenceHash();

  @$internal
  @override
  ThemePreference create() => ThemePreference();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themePreferenceHash() => r'a30dc888464433322d1629bb598b0d9e6c7193dd';

/// Apparence choisie par l'utilisateur (ADR-038) : automatique (réglage du téléphone), clair ou sombre ;
/// mémorisée sur l'appareil.

abstract class _$ThemePreference extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
