// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'missions_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(missionRepository)
final missionRepositoryProvider = MissionRepositoryProvider._();

final class MissionRepositoryProvider
    extends
        $FunctionalProvider<
          MissionRepository,
          MissionRepository,
          MissionRepository
        >
    with $Provider<MissionRepository> {
  MissionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'missionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$missionRepositoryHash();

  @$internal
  @override
  $ProviderElement<MissionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MissionRepository create(Ref ref) {
    return missionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MissionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MissionRepository>(value),
    );
  }
}

String _$missionRepositoryHash() => r'bbd25421883acff56b884080c13aaf8a77f4e080';

@ProviderFor(pendingOffer)
final pendingOfferProvider = PendingOfferProvider._();

final class PendingOfferProvider
    extends
        $FunctionalProvider<
          AsyncValue<DeliveryOffer?>,
          DeliveryOffer?,
          Stream<DeliveryOffer?>
        >
    with $FutureModifier<DeliveryOffer?>, $StreamProvider<DeliveryOffer?> {
  PendingOfferProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingOfferProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingOfferHash();

  @$internal
  @override
  $StreamProviderElement<DeliveryOffer?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<DeliveryOffer?> create(Ref ref) {
    return pendingOffer(ref);
  }
}

String _$pendingOfferHash() => r'862f2f250f601149c6a7c42a5c0d9708ba238c83';

@ProviderFor(currentMission)
final currentMissionProvider = CurrentMissionProvider._();

final class CurrentMissionProvider
    extends $FunctionalProvider<AsyncValue<Order?>, Order?, Stream<Order?>>
    with $FutureModifier<Order?>, $StreamProvider<Order?> {
  CurrentMissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentMissionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentMissionHash();

  @$internal
  @override
  $StreamProviderElement<Order?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Order?> create(Ref ref) {
    return currentMission(ref);
  }
}

String _$currentMissionHash() => r'a76bdd4289746cdba30352d9541311941c9aa6f7';

/// En ligne / hors ligne (COU-05). En ligne, la position part tout de suite, à chaque déplacement de 25 m
/// (au plus toutes les 10 s) et toutes les 30 s à l'arrêt : le serveur ne sollicite que les livreurs dont la
/// position a moins de 2 min. Sur Android, une notification permanente « Vous êtes en ligne » l'accompagne.

@ProviderFor(CourierPresence)
final courierPresenceProvider = CourierPresenceProvider._();

/// En ligne / hors ligne (COU-05). En ligne, la position part tout de suite, à chaque déplacement de 25 m
/// (au plus toutes les 10 s) et toutes les 30 s à l'arrêt : le serveur ne sollicite que les livreurs dont la
/// position a moins de 2 min. Sur Android, une notification permanente « Vous êtes en ligne » l'accompagne.
final class CourierPresenceProvider
    extends $AsyncNotifierProvider<CourierPresence, bool> {
  /// En ligne / hors ligne (COU-05). En ligne, la position part tout de suite, à chaque déplacement de 25 m
  /// (au plus toutes les 10 s) et toutes les 30 s à l'arrêt : le serveur ne sollicite que les livreurs dont la
  /// position a moins de 2 min. Sur Android, une notification permanente « Vous êtes en ligne » l'accompagne.
  CourierPresenceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'courierPresenceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$courierPresenceHash();

  @$internal
  @override
  CourierPresence create() => CourierPresence();
}

String _$courierPresenceHash() => r'bcfe377ec502628ecbb43e106da122acd4e9fc83';

/// En ligne / hors ligne (COU-05). En ligne, la position part tout de suite, à chaque déplacement de 25 m
/// (au plus toutes les 10 s) et toutes les 30 s à l'arrêt : le serveur ne sollicite que les livreurs dont la
/// position a moins de 2 min. Sur Android, une notification permanente « Vous êtes en ligne » l'accompagne.

abstract class _$CourierPresence extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
