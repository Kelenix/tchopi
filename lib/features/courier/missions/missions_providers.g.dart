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

@ProviderFor(mission)
final missionProvider = MissionFamily._();

final class MissionProvider
    extends $FunctionalProvider<AsyncValue<Order?>, Order?, Stream<Order?>>
    with $FutureModifier<Order?>, $StreamProvider<Order?> {
  MissionProvider._({
    required MissionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'missionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$missionHash();

  @override
  String toString() {
    return r'missionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Order?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Order?> create(Ref ref) {
    final argument = this.argument as String;
    return mission(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MissionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$missionHash() => r'68292842f2708e92f0f23ce968b629abc9184aa9';

final class MissionFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Order?>, String> {
  MissionFamily._()
    : super(
        retry: null,
        name: r'missionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MissionProvider call(String orderId) =>
      MissionProvider._(argument: orderId, from: this);

  @override
  String toString() => r'missionProvider';
}

/// Gains, livraisons du jour et espèces à reverser, recalculés à chaque changement de mission.

@ProviderFor(courierSummary)
final courierSummaryProvider = CourierSummaryProvider._();

/// Gains, livraisons du jour et espèces à reverser, recalculés à chaque changement de mission.

final class CourierSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<CourierSummary>,
          CourierSummary,
          FutureOr<CourierSummary>
        >
    with $FutureModifier<CourierSummary>, $FutureProvider<CourierSummary> {
  /// Gains, livraisons du jour et espèces à reverser, recalculés à chaque changement de mission.
  CourierSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'courierSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$courierSummaryHash();

  @$internal
  @override
  $FutureProviderElement<CourierSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CourierSummary> create(Ref ref) {
    return courierSummary(ref);
  }
}

String _$courierSummaryHash() => r'6b54442a7329387170b141c4fe2667eb3cc83881';

@ProviderFor(missionHistory)
final missionHistoryProvider = MissionHistoryProvider._();

final class MissionHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MissionRecord>>,
          List<MissionRecord>,
          FutureOr<List<MissionRecord>>
        >
    with
        $FutureModifier<List<MissionRecord>>,
        $FutureProvider<List<MissionRecord>> {
  MissionHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'missionHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$missionHistoryHash();

  @$internal
  @override
  $FutureProviderElement<List<MissionRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MissionRecord>> create(Ref ref) {
    return missionHistory(ref);
  }
}

String _$missionHistoryHash() => r'3dcad7616bc67d15ca13886268d28077018d7962';

@ProviderFor(supportPhone)
final supportPhoneProvider = SupportPhoneProvider._();

final class SupportPhoneProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  SupportPhoneProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supportPhoneProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supportPhoneHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return supportPhone(ref);
  }
}

String _$supportPhoneHash() => r'9385b9a9eb7dff33e4c38038b43d22dfde7a16da';

/// Dernière position connue du téléphone en ligne, pour la carte de la mission (MIS-03).

@ProviderFor(CourierPosition)
final courierPositionProvider = CourierPositionProvider._();

/// Dernière position connue du téléphone en ligne, pour la carte de la mission (MIS-03).
final class CourierPositionProvider
    extends $NotifierProvider<CourierPosition, LatLng?> {
  /// Dernière position connue du téléphone en ligne, pour la carte de la mission (MIS-03).
  CourierPositionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'courierPositionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$courierPositionHash();

  @$internal
  @override
  CourierPosition create() => CourierPosition();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LatLng? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LatLng?>(value),
    );
  }
}

String _$courierPositionHash() => r'72709b46805b4903902eb27f373a9d44144e7320';

/// Dernière position connue du téléphone en ligne, pour la carte de la mission (MIS-03).

abstract class _$CourierPosition extends $Notifier<LatLng?> {
  LatLng? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LatLng?, LatLng?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LatLng?, LatLng?>,
              LatLng?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

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

String _$courierPresenceHash() => r'3011e8d07a0cd8cb12c8c37b8b51d56dcef36a69';

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
