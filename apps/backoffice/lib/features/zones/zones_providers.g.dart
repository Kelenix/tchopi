// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zones_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminZoneRepository)
final adminZoneRepositoryProvider = AdminZoneRepositoryProvider._();

final class AdminZoneRepositoryProvider
    extends
        $FunctionalProvider<
          AdminZoneRepository,
          AdminZoneRepository,
          AdminZoneRepository
        >
    with $Provider<AdminZoneRepository> {
  AdminZoneRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminZoneRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminZoneRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminZoneRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdminZoneRepository create(Ref ref) {
    return adminZoneRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminZoneRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminZoneRepository>(value),
    );
  }
}

String _$adminZoneRepositoryHash() =>
    r'137916f7816e5814bff99f08b72cdb9bc0261fae';

@ProviderFor(adminZones)
final adminZonesProvider = AdminZonesProvider._();

final class AdminZonesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Zone>>,
          List<Zone>,
          FutureOr<List<Zone>>
        >
    with $FutureModifier<List<Zone>>, $FutureProvider<List<Zone>> {
  AdminZonesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminZonesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminZonesHash();

  @$internal
  @override
  $FutureProviderElement<List<Zone>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Zone>> create(Ref ref) {
    return adminZones(ref);
  }
}

String _$adminZonesHash() => r'd9c382f47383347f4f56163e531ae8768bbf0c47';

@ProviderFor(zonePricing)
final zonePricingProvider = ZonePricingFamily._();

final class ZonePricingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PricingRule>>,
          List<PricingRule>,
          FutureOr<List<PricingRule>>
        >
    with
        $FutureModifier<List<PricingRule>>,
        $FutureProvider<List<PricingRule>> {
  ZonePricingProvider._({
    required ZonePricingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'zonePricingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$zonePricingHash();

  @override
  String toString() {
    return r'zonePricingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PricingRule>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PricingRule>> create(Ref ref) {
    final argument = this.argument as String;
    return zonePricing(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ZonePricingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$zonePricingHash() => r'17cdb50e1d783242cecf5108fdcaa06740849bab';

final class ZonePricingFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PricingRule>>, String> {
  ZonePricingFamily._()
    : super(
        retry: null,
        name: r'zonePricingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ZonePricingProvider call(String zoneId) =>
      ZonePricingProvider._(argument: zoneId, from: this);

  @override
  String toString() => r'zonePricingProvider';
}
