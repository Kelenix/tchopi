import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Carte OpenStreetMap (ADR-019) avec une épingle fixe au centre : on déplace la carte sous l'épingle,
/// qui se soulève pendant le geste. `onMoved` reçoit la position désignée par la pointe.
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
        TileLayer(
          urlTemplate: Env.mapTilesUrl,
          userAgentPackageName: 'com.tchopi.mobile',
        ),
        IgnorePointer(
          child: Center(child: _Pin(lifted: _moving)),
        ),
        // Mention exigée par OpenStreetMap ; en haut, car le bas de la carte peut être recouvert.
        Align(
          alignment: Alignment.topRight,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Space.sm),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(Radii.chip),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Space.sm,
                    vertical: 2,
                  ),
                  child: Text(
                    '© OpenStreetMap',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: tokens.muted),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
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
                      color: tokens.primary,
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
                  Container(width: 3, height: _stem, color: tokens.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
