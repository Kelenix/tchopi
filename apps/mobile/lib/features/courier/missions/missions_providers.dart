import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../profile/courier_providers.dart';
import 'data/mission_repository.dart';

part 'missions_providers.g.dart';

@riverpod
MissionRepository missionRepository(Ref ref) =>
    MissionRepository(ref.watch(supabaseClientProvider));

@riverpod
Stream<DeliveryOffer?> pendingOffer(Ref ref) {
  final userId = ref.watch(currentUserIdProvider);
  return userId == null
      ? Stream.value(null)
      : ref.watch(missionRepositoryProvider).watchPendingOffer(userId);
}

@riverpod
Stream<Order?> currentMission(Ref ref) {
  final userId = ref.watch(currentUserIdProvider);
  return userId == null
      ? Stream.value(null)
      : ref.watch(missionRepositoryProvider).watchMission(userId);
}

enum PresenceProblem { serviceOff, denied, deniedForever }

/// Passage en ligne impossible côté téléphone (GPS coupé, autorisation refusée).
class PresenceException implements Exception {
  const PresenceException(this.problem);

  final PresenceProblem problem;
}

/// En ligne / hors ligne (COU-05). En ligne, la position part tout de suite, à chaque déplacement de 25 m
/// (au plus toutes les 10 s) et toutes les 30 s à l'arrêt : le serveur ne sollicite que les livreurs dont la
/// position a moins de 2 min. Sur Android, une notification permanente « Vous êtes en ligne » l'accompagne.
@Riverpod(keepAlive: true)
class CourierPresence extends _$CourierPresence {
  static const _heartbeatEvery = Duration(seconds: 30);
  static const _minGap = Duration(seconds: 10);

  StreamSubscription<Position>? _positions;
  Timer? _heartbeat;
  Position? _last;
  DateTime _sentAt = DateTime(2000);

  MissionRepository get _repo => ref.read(missionRepositoryProvider);

  @override
  Future<bool> build() async {
    ref.onDispose(_stopTracking);
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return false;
    final courier = await ref.read(courierRepositoryProvider).fetchMine(userId);
    if (courier?.isOnline != true) return false;
    // Reprise après un redémarrage : sans GPS ni autorisation, le livreur repasse hors ligne.
    if (await _problem(request: false) == null) {
      if (await _currentPosition() case final position?) {
        await _startTracking(position);
        return true;
      }
    }
    try {
      await _repo.setOnline(false);
      return false;
    } on AppFailure {
      return true;
    }
  }

  /// Lève [PresenceException] ou [AppFailure] (non approuvé, mission en cours) ; l'état ne change qu'en cas de succès.
  Future<void> setOnline(bool online) async {
    if (online) {
      if (await _problem(request: true) case final problem?) {
        throw PresenceException(problem);
      }
      final position = await _currentPosition();
      if (position == null) {
        throw const PresenceException(PresenceProblem.serviceOff);
      }
      await _repo.setOnline(true);
      await _startTracking(position);
    } else {
      await _repo.setOnline(false);
      _stopTracking();
    }
    state = AsyncData(online);
  }

  /// Autorisation jamais demandée : l'écran explique d'abord pourquoi (COU-05).
  Future<bool> needsPermission() async =>
      await Geolocator.checkPermission() == LocationPermission.denied;

  Future<void> openSettings() => Geolocator.openAppSettings();

  Future<PresenceProblem?> _problem({required bool request}) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return PresenceProblem.serviceOff;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && request) {
      permission = await Geolocator.requestPermission();
    }
    return switch (permission) {
      LocationPermission.denied => PresenceProblem.denied,
      LocationPermission.deniedForever => PresenceProblem.deniedForever,
      _ => null,
    };
  }

  /// Position actuelle, ou `null` si le téléphone n'en donne pas à temps (GPS coupé, intérieur).
  Future<Position?> _currentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } on Exception {
      return null;
    }
  }

  Future<void> _startTracking(Position initial) async {
    _stopTracking();
    _last = initial;
    await _send();
    _positions = Geolocator.getPositionStream(locationSettings: _settings())
        .listen((position) {
          _last = position;
          if (DateTime.now().difference(_sentAt) >= _minGap) _send();
        }, onError: (Object _) {});
    _heartbeat = Timer.periodic(_heartbeatEvery, (_) => _send());
  }

  void _stopTracking() {
    _positions?.cancel();
    _heartbeat?.cancel();
    _positions = null;
    _heartbeat = null;
  }

  Future<void> _send() async {
    final position = _last;
    if (position == null) return;
    _sentAt = DateTime.now();
    try {
      await _repo.reportLocation(
        position.latitude,
        position.longitude,
        position.accuracy,
      );
    } on AppFailure {
      // Réseau coupé : la position repart au prochain déplacement ou battement.
    }
  }

  LocationSettings _settings() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25,
      );
    }
    final l10n = lookupAppLocalizations(const Locale('fr'));
    return AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 25,
      foregroundNotificationConfig: ForegroundNotificationConfig(
        notificationTitle: l10n.courierNotificationTitle,
        notificationText: l10n.courierNotificationText,
        notificationChannelName: l10n.courierNotificationTitle,
        setOngoing: true,
      ),
    );
  }
}
