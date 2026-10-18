import 'package:geocoding/geocoding.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:geolocator/geolocator.dart';

sealed class LocationResult {
  const LocationResult();
}

class LocationFound extends LocationResult {
  const LocationFound(this.latitude, this.longitude, {required this.isPrecise});

  final double latitude;
  final double longitude;

  /// Faux si la précision dépasse 50 m : l'utilisateur est invité à ajuster l'épingle.
  final bool isPrecise;
}

enum LocationProblem { serviceOff, denied, deniedForever }

class LocationUnavailable extends LocationResult {
  const LocationUnavailable(this.problem);

  final LocationProblem problem;
}

/// Position du téléphone et quartier suggéré. L'autorisation n'est demandée qu'à l'appel (ADR-01).
class LocationService {
  static const _preciseMeters = 50;

  Future<bool> needsPermissionRequest() async =>
      await Geolocator.checkPermission() == LocationPermission.denied;

  Future<LocationResult> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocationUnavailable(LocationProblem.serviceOff);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    switch (permission) {
      case LocationPermission.denied:
        return const LocationUnavailable(LocationProblem.denied);
      case LocationPermission.deniedForever:
        return const LocationUnavailable(LocationProblem.deniedForever);
      case LocationPermission.whileInUse ||
          LocationPermission.always ||
          LocationPermission.unableToDetermine:
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 15),
          ),
        );
        return LocationFound(
          position.latitude,
          position.longitude,
          isPrecise: position.accuracy <= _preciseMeters,
        );
    }
  }

  Future<void> openSettings() => Geolocator.openAppSettings();

  /// Quartier proposé par le géocodeur du téléphone (gratuit, sans réseau tiers) ; `null` s'il n'en sait rien.
  Future<String?> suggestDistrict(double latitude, double longitude) async {
    try {
      final places = await Geocoding(
        locale: const Locale('fr'),
      ).placemarkFromCoordinates(latitude, longitude);
      final place = places.firstOrNull;
      final district = place?.subLocality?.trim();
      return (district?.isNotEmpty ?? false) ? district : place?.locality;
    } on Exception {
      return null;
    }
  }
}
