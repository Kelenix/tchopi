import 'dart:convert';
import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'map_tiles.dart';

part 'delivery_map.g.dart';

/// Trajet routier entre deux points (OSRM, ADR-038), calculé une fois par trajet ; ligne droite si le service ne
/// répond pas, pour que la carte reste utile.
@Riverpod(keepAlive: true)
Future<List<LatLng>> roadRoute(Ref ref, LatLng from, LatLng to) async {
  try {
    final uri = Uri.parse(
      '${Env.routingUrl}/route/v1/driving/'
      '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
      '?overview=full&geometries=geojson',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    final routes =
        (jsonDecode(response.body) as Map<String, dynamic>)['routes']
            as List<dynamic>;
    final coordinates =
        ((routes.first as Map<String, dynamic>)['geometry']
                as Map<String, dynamic>)['coordinates']
            as List<dynamic>;
    return [
      for (final point in coordinates.cast<List<dynamic>>())
        LatLng((point[1] as num).toDouble(), (point[0] as num).toDouble()),
    ];
  } on Object {
    return [from, to];
  }
}

/// Carte de livraison (ADR-038, maquette « suivi ») : trajet coloré du retrait à la destination, point de retrait
/// (restaurant ou expéditeur), destination, livreur avec son moyen de transport orienté dans le sens du
/// déplacement. Ses déplacements sont animés ; le fond de carte n'est jamais rechargé.
class DeliveryMap extends ConsumerStatefulWidget {
  const DeliveryMap({
    super.key,
    required this.pickup,
    required this.dropoff,
    this.courier,
    this.vehicle,
    this.stale = false,
    this.parcel = false,
    this.showPickup = true,
    this.height = 220,
  });

  final LatLng pickup;
  final LatLng dropoff;
  final LatLng? courier;
  final VehicleType? vehicle;

  /// Position ancienne : livreur grisé, sans pulsation.
  final bool stale;
  final bool parcel;

  /// Après la récupération, le point de retrait n'est plus utile.
  final bool showPickup;
  final double height;

  @override
  ConsumerState<DeliveryMap> createState() => _DeliveryMapState();
}

class _DeliveryMapState extends ConsumerState<DeliveryMap> {
  final _map = MapController();

  List<LatLng> get _points => [
    if (widget.showPickup) widget.pickup,
    widget.dropoff,
    ?widget.courier,
  ];

  @override
  void didUpdateWidget(DeliveryMap old) {
    super.didUpdateWidget(old);
    // Nouvelle étape (retrait masqué) : recadrage, sans reconstruire la carte.
    if (old.showPickup != widget.showPickup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _map.fitCamera(_fit(_points));
      });
    }
  }

  CameraFit _fit(List<LatLng> points) => points.length < 2
      ? CameraFit.coordinates(coordinates: [...points, ...points], maxZoom: 16)
      : CameraFit.coordinates(
          coordinates: points,
          padding: const EdgeInsets.fromLTRB(48, 48, 48, 56),
          maxZoom: 16,
        );

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final route =
        ref.watch(roadRouteProvider(widget.pickup, widget.dropoff)).value ??
        const <LatLng>[];
    return SizedBox(
      height: widget.height,
      child: FlutterMap(
        mapController: _map,
        options: MapOptions(
          initialCameraFit: _fit(_points),
          backgroundColor: tokens.surfaceAlt,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
        ),
        children: [
          const MapTiles(),
          if (route.length > 1)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: route,
                  strokeWidth: 5,
                  color: tokens.primaryAction,
                  borderStrokeWidth: 2,
                  borderColor: tokens.surface,
                  strokeCap: StrokeCap.round,
                  strokeJoin: StrokeJoin.round,
                ),
              ],
            ),
          MarkerLayer(
            markers: [
              if (widget.showPickup)
                Marker(
                  point: widget.pickup,
                  width: 34,
                  height: 34,
                  child: _PickupMarker(parcel: widget.parcel),
                ),
              Marker(
                point: widget.dropoff,
                width: 34,
                height: 34,
                child: const _DropoffMarker(),
              ),
            ],
          ),
          if (widget.courier case final courier?)
            _CourierLayer(
              position: courier,
              vehicle: widget.vehicle ?? VehicleType.motorbike,
              stale: widget.stale,
            ),
          // En bas : le haut de la carte reste libre pour les repères.
          const MapAttribution(alignment: Alignment.bottomRight),
        ],
      ),
    );
  }
}

/// Retrait : carré foncé à coins arrondis (restaurant ou colis).
class _PickupMarker extends StatelessWidget {
  const _PickupMarker({required this.parcel});

  final bool parcel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.ink,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tokens.surface, width: 2),
      ),
      child: Icon(
        parcel ? Icons.inventory_2_outlined : Icons.storefront_rounded,
        size: 17,
        color: tokens.onInk,
      ),
    );
  }
}

/// Destination : rond vert cerclé.
class _DropoffMarker extends StatelessWidget {
  const _DropoffMarker();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.primaryAction,
        shape: BoxShape.circle,
        border: Border.all(color: tokens.surface, width: 3),
      ),
      child: Icon(Icons.home_rounded, size: 16, color: tokens.onPrimaryAction),
    );
  }
}

/// Livreur : glisse vers chaque nouvelle position (pas de saut) ; flèche tournée vers sa direction, véhicule
/// retourné quand il roule vers l'ouest. Seule cette couche se redessine pendant l'animation.
class _CourierLayer extends StatefulWidget {
  const _CourierLayer({
    required this.position,
    required this.vehicle,
    required this.stale,
  });

  final LatLng position;
  final VehicleType vehicle;
  final bool stale;

  @override
  State<_CourierLayer> createState() => _CourierLayerState();
}

class _CourierLayerState extends State<_CourierLayer>
    with TickerProviderStateMixin {
  late final _move = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();
  late LatLng _from = widget.position;
  late LatLng _to = widget.position;
  double? _bearing;

  @override
  void didUpdateWidget(_CourierLayer old) {
    super.didUpdateWidget(old);
    if (widget.position == _to) return;
    _from = _current;
    _to = widget.position;
    // Direction seulement sur un vrai déplacement (le bruit du GPS ne fait pas tourner le livreur).
    if (const Distance().as(LengthUnit.Meter, _from, _to) > 5) {
      _bearing = _bearingBetween(_from, _to);
    }
    _move.forward(from: 0);
  }

  LatLng get _current {
    final t = Curves.easeInOut.transform(_move.value);
    return LatLng(
      _from.latitude + (_to.latitude - _from.latitude) * t,
      _from.longitude + (_to.longitude - _from.longitude) * t,
    );
  }

  static double _bearingBetween(LatLng a, LatLng b) {
    double rad(double d) => d * math.pi / 180;
    final y =
        math.sin(rad(b.longitude - a.longitude)) * math.cos(rad(b.latitude));
    final x =
        math.cos(rad(a.latitude)) * math.sin(rad(b.latitude)) -
        math.sin(rad(a.latitude)) *
            math.cos(rad(b.latitude)) *
            math.cos(rad(b.longitude - a.longitude));
    return math.atan2(y, x);
  }

  @override
  void dispose() {
    _move.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = widget.stale ? tokens.muted : tokens.success;
    final icon = switch (widget.vehicle) {
      VehicleType.motorbike => Icons.two_wheeler_rounded,
      VehicleType.bicycle => Icons.pedal_bike_rounded,
      VehicleType.car => Icons.directions_car_rounded,
      VehicleType.onFoot => Icons.directions_walk_rounded,
    };
    final westward = _bearing != null && math.sin(_bearing!) < 0;
    return AnimatedBuilder(
      animation: Listenable.merge([_move, _pulse]),
      builder: (context, _) => MarkerLayer(
        markers: [
          Marker(
            point: _current,
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (!widget.stale)
                  Container(
                    width: 38 + 26 * _pulse.value,
                    height: 38 + 26 * _pulse.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.28 * (1 - _pulse.value)),
                    ),
                  ),
                if (_bearing != null)
                  Transform.rotate(
                    angle: _bearing!,
                    child: Align(
                      alignment: const Alignment(0, -0.82),
                      child: Icon(
                        Icons.navigation_rounded,
                        size: 14,
                        color: color,
                      ),
                    ),
                  ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: tokens.surface, width: 3),
                  ),
                  child: Transform.flip(
                    flipX: westward,
                    child: Icon(icon, size: 19, color: tokens.surface),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
