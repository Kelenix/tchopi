// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supervision_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(supervisionRepository)
final supervisionRepositoryProvider = SupervisionRepositoryProvider._();

final class SupervisionRepositoryProvider
    extends
        $FunctionalProvider<
          SupervisionRepository,
          SupervisionRepository,
          SupervisionRepository
        >
    with $Provider<SupervisionRepository> {
  SupervisionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supervisionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supervisionRepositoryHash();

  @$internal
  @override
  $ProviderElement<SupervisionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SupervisionRepository create(Ref ref) {
    return supervisionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupervisionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupervisionRepository>(value),
    );
  }
}

String _$supervisionRepositoryHash() =>
    r'537f97e884d78dbe8a511678925265d6704a5947';

@ProviderFor(activeOrders)
final activeOrdersProvider = ActiveOrdersProvider._();

final class ActiveOrdersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Order>>,
          List<Order>,
          Stream<List<Order>>
        >
    with $FutureModifier<List<Order>>, $StreamProvider<List<Order>> {
  ActiveOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeOrdersHash();

  @$internal
  @override
  $StreamProviderElement<List<Order>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Order>> create(Ref ref) {
    return activeOrders(ref);
  }
}

String _$activeOrdersHash() => r'3a4f1866bb300692bb769505e18592244124aad4';

@ProviderFor(dispatchCandidates)
final dispatchCandidatesProvider = DispatchCandidatesFamily._();

final class DispatchCandidatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DispatchCandidate>>,
          List<DispatchCandidate>,
          FutureOr<List<DispatchCandidate>>
        >
    with
        $FutureModifier<List<DispatchCandidate>>,
        $FutureProvider<List<DispatchCandidate>> {
  DispatchCandidatesProvider._({
    required DispatchCandidatesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'dispatchCandidatesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dispatchCandidatesHash();

  @override
  String toString() {
    return r'dispatchCandidatesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DispatchCandidate>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DispatchCandidate>> create(Ref ref) {
    final argument = this.argument as String;
    return dispatchCandidates(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DispatchCandidatesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dispatchCandidatesHash() =>
    r'a3abf12992744f95b6cb9cda64b3205ce674f479';

final class DispatchCandidatesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<DispatchCandidate>>, String> {
  DispatchCandidatesFamily._()
    : super(
        retry: null,
        name: r'dispatchCandidatesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DispatchCandidatesProvider call(String orderId) =>
      DispatchCandidatesProvider._(argument: orderId, from: this);

  @override
  String toString() => r'dispatchCandidatesProvider';
}

@ProviderFor(platformSettings)
final platformSettingsProvider = PlatformSettingsProvider._();

final class PlatformSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlatformSettings>,
          PlatformSettings,
          FutureOr<PlatformSettings>
        >
    with $FutureModifier<PlatformSettings>, $FutureProvider<PlatformSettings> {
  PlatformSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'platformSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$platformSettingsHash();

  @$internal
  @override
  $FutureProviderElement<PlatformSettings> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PlatformSettings> create(Ref ref) {
    return platformSettings(ref);
  }
}

String _$platformSettingsHash() => r'480a589d5769b3c997d6f225904c644e2830fe6d';
