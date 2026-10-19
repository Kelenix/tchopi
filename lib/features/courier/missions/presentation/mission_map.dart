import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/delivery_map.dart';
import '../../profile/courier_providers.dart';
import '../missions_providers.dart';

/// L-06 : trajet de la mission, prochaine étape et position du livreur ; itinéraire dans Google Maps ou Waze
/// (MIS-03).
class MissionMap extends ConsumerWidget {
  const MissionMap({super.key, required this.order});

  final Order order;

  Future<void> _open(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final o = order;
    final pickedUp =
        o.status == OrderStatus.pickedUp || o.status == OrderStatus.inTransit;
    final target = pickedUp
        ? LatLng(o.dropoffLat, o.dropoffLng)
        : LatLng(o.pickupLat, o.pickupLng);
    final destination = '${target.latitude},${target.longitude}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Radii.card),
          child: DeliveryMap(
            pickup: LatLng(o.pickupLat, o.pickupLng),
            dropoff: LatLng(o.dropoffLat, o.dropoffLng),
            courier: ref.watch(courierPositionProvider),
            vehicle: ref.watch(myCourierProvider).value?.vehicleType,
            parcel: o.type == OrderType.parcel,
            showPickup: !pickedUp,
          ),
        ),
        const SizedBox(height: Space.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _open(
                  Uri.https('www.google.com', '/maps/dir/', {
                    'api': '1',
                    'destination': destination,
                  }),
                ),
                icon: const Icon(Icons.map_outlined),
                label: Text(l10n.missionGoogleMaps, maxLines: 1),
              ),
            ),
            const SizedBox(width: Space.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _open(
                  Uri.https('waze.com', '/ul', {
                    'll': destination,
                    'navigate': 'yes',
                  }),
                ),
                icon: const Icon(Icons.navigation_outlined),
                label: Text(l10n.missionWaze, maxLines: 1),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
