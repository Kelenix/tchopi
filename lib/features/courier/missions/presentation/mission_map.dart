import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/map_tiles.dart';
import '../missions_providers.dart';

/// L-06 : prochaine étape et position du livreur ; itinéraire dans Google Maps ou Waze (MIS-03).
class MissionMap extends ConsumerWidget {
  const MissionMap({super.key, required this.target});

  final LatLng target;

  Future<void> _open(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final me = ref.watch(courierPositionProvider);
    final destination = '${target.latitude},${target.longitude}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Radii.card),
          child: SizedBox(
            height: 200,
            // Nouvelle étape, nouvelle cible : la carte repart cadrée sur elle.
            child: FlutterMap(
              key: ValueKey(target),
              options: MapOptions(
                initialCenter: target,
                initialZoom: 16,
                initialCameraFit: me == null
                    ? null
                    : CameraFit.coordinates(
                        coordinates: [me, target],
                        padding: const EdgeInsets.all(48),
                        maxZoom: 17,
                      ),
                backgroundColor: tokens.surfaceAlt,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                const MapTiles(),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: target,
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: Icon(
                        Icons.location_on,
                        color: tokens.primary,
                        size: 44,
                      ),
                    ),
                    if (me != null)
                      Marker(
                        point: me,
                        width: 18,
                        height: 18,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: tokens.ink,
                            shape: BoxShape.circle,
                            border: Border.all(color: tokens.surface, width: 3),
                          ),
                        ),
                      ),
                  ],
                ),
                const MapAttribution(),
              ],
            ),
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
