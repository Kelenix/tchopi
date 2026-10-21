import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'map_tiles.dart';
import 'place_search.dart';

/// Carte (ADR-019, ADR-033) avec une épingle fixe au centre : on déplace la carte sous l'épingle,
/// qui se soulève pendant le geste. `onMoved` reçoit la position désignée par la pointe. Un lieu peut aussi être
/// cherché par son nom (ADR-039) : la carte s'y place.
class PinMap extends StatefulWidget {
  const PinMap({
    super.key,
    required this.controller,
    required this.initialCenter,
    required this.onMoved,
  });

  static const zoom = 17.0;

  final MapController controller;
  final LatLng initialCenter;
  final ValueChanged<LatLng> onMoved;

  @override
  State<PinMap> createState() => _PinMapState();
}

class _PinMapState extends State<PinMap> {
  bool _moving = false;

  void _setMoving(bool moving) {
    if (moving != _moving) setState(() => _moving = moving);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return FlutterMap(
      mapController: widget.controller,
      options: MapOptions(
        initialCenter: widget.initialCenter,
        initialZoom: PinMap.zoom,
        minZoom: 6,
        maxZoom: 19,
        backgroundColor: tokens.surfaceAlt,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onPositionChanged: (camera, hasGesture) {
          widget.onMoved(camera.center);
          if (hasGesture) _setMoving(true);
        },
        onMapEvent: (event) {
          if (event is MapEventMoveEnd ||
              event is MapEventFlingAnimationEnd ||
              event is MapEventFlingAnimationNotStarted) {
            _setMoving(false);
          }
        },
      ),
      children: [
        const MapTiles(),
        IgnorePointer(
          child: Center(child: _Pin(lifted: _moving)),
        ),
        const MapAttribution(),
        Align(
          alignment: Alignment.topRight,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 36, Space.sm, 0),
              child: IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: tokens.surface,
                  foregroundColor: tokens.ink,
                  side: BorderSide(color: tokens.border),
                ),
                tooltip: AppLocalizations.of(context).placeSearchTooltip,
                icon: const Icon(Icons.search_rounded),
                onPressed: _search,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _search() async {
    final place = await showPlaceSearch(
      context,
      widget.controller.camera.center,
    );
    if (place != null) widget.controller.move(place.point, PinMap.zoom);
  }
}

/// Épingle dont la pointe (bas du widget) est au centre de la carte ; ombre au sol sous la pointe.
class _Pin extends StatelessWidget {
  const _Pin({required this.lifted});

  static const _head = 46.0;
  static const _stem = 16.0;

  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      // Remonte l'épingle de sa hauteur : sa pointe tombe au centre.
      padding: const EdgeInsets.only(bottom: _head + _stem),
      child: SizedBox(
        height: _head + _stem,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: -3,
              child: AnimatedContainer(
                duration: Motion.normal,
                curve: Motion.curve,
                width: lifted ? 18 : 12,
                height: 6,
                decoration: BoxDecoration(
                  color: tokens.ink.withValues(alpha: lifted ? 0.18 : 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            AnimatedSlide(
              duration: Motion.normal,
              curve: Motion.curve,
              offset: Offset(0, lifted ? -0.18 : 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: _head,
                    height: _head,
                    decoration: BoxDecoration(
                      color: tokens.primaryAction,
                      shape: BoxShape.circle,
                      border: Border.all(color: tokens.surface, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: tokens.ink.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: tokens.surface,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 3,
                    height: _stem,
                    color: tokens.primaryAction,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
