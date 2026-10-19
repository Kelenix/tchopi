import 'package:core/core.dart';
import 'package:latlong2/latlong.dart';

/// TRK-01 : minutes avant l'arrivée chez le client, à vol d'oiseau majoré du détour, à la vitesse moyenne du moyen
/// de transport en ville ; avant la récupération, le trajet passe par le retrait. `null` si la position est
/// ancienne (TRK-02) : l'estimation est alors indisponible plutôt que fausse.
int? arrivalMinutes(
  Order order,
  VehicleType vehicle,
  CourierLocation position,
  DateTime now,
) {
  if (position.isStale(now)) return null;
  const distance = Distance();
  final courier = LatLng(position.latitude, position.longitude);
  final pickup = LatLng(order.pickupLat, order.pickupLng);
  final dropoff = LatLng(order.dropoffLat, order.dropoffLng);
  final pickedUp =
      order.status == OrderStatus.pickedUp ||
      order.status == OrderStatus.inTransit;
  final meters = pickedUp
      ? distance(courier, dropoff)
      : distance(courier, pickup) + distance(pickup, dropoff);
  final kmPerHour = switch (vehicle) {
    VehicleType.motorbike => 25,
    VehicleType.car => 20,
    VehicleType.bicycle => 12,
    VehicleType.onFoot => 5,
  };
  const detour = 1.3;
  final minutes = (meters * detour / 1000 / kmPerHour * 60).ceil();
  return minutes < 1 ? 1 : minutes;
}
