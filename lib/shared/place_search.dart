import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Lieu trouvé par la recherche (quartier, carrefour, commerce, monument…).
typedef Place = ({String name, String detail, LatLng point});

/// Recherche de lieux en Côte d'Ivoire (ADR-039) : Photon, sur les données OpenStreetMap, sans clé ; résultats
/// proches de [near] d'abord. Liste vide si le service ne répond pas : l'épingle reste utilisable.
Future<List<Place>> searchPlacesOnline(
  String query,
  LatLng near, {
  http.Client? client,
}) async {
  final uri = Uri.parse('${Env.placesSearchUrl}/api/').replace(
    queryParameters: {
      'q': query,
      'lat': '${near.latitude}',
      'lon': '${near.longitude}',
      // Côte d'Ivoire seulement.
      'bbox': '-8.61,4.34,-2.49,10.74',
      'limit': '8',
    },
  );
  final response = await (client?.get(uri) ?? http.get(uri)).timeout(
    const Duration(seconds: 6),
  );
  final features =
      (jsonDecode(utf8.decode(response.bodyBytes))
              as Map<String, dynamic>)['features']
          as List<dynamic>;
  return [
    for (final feature in features.cast<Map<String, dynamic>>())
      if (feature['properties'] case {'name': final String name} && final p)
        (
          name: name,
          detail: [p['district'] ?? p['locality'], p['city'] ?? p['county']]
              .whereType<String>()
              .where((part) => part != name)
              .toSet()
              .join(', '),
          point: switch ((feature['geometry']
              as Map<String, dynamic>)['coordinates']) {
            [final num lng, final num lat] => LatLng(
              lat.toDouble(),
              lng.toDouble(),
            ),
            _ => throw const FormatException('coordonnées'),
          },
        ),
  ];
}

/// Feuille de recherche d'un lieu ; rend le lieu choisi, `null` si abandon.
Future<Place?> showPlaceSearch(BuildContext context, LatLng near) =>
    showModalBottomSheet<Place>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _PlaceSearch(near: near),
    );

class _PlaceSearch extends StatefulWidget {
  const _PlaceSearch({required this.near});

  final LatLng near;

  @override
  State<_PlaceSearch> createState() => _PlaceSearchState();
}

class _PlaceSearchState extends State<_PlaceSearch> {
  Timer? _debounce;
  List<Place> _results = const [];
  bool _loading = false;
  bool _failed = false;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Une requête par pause de saisie ; une réponse arrivée après une nouvelle saisie est ignorée.
  void _onChanged(String value) {
    _debounce?.cancel();
    _query = value.trim();
    if (_query.length < 3) {
      setState(() => _results = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final query = _query;
      setState(() => _loading = true);
      void show(List<Place> results, {bool failed = false}) {
        if (!mounted || query != _query) return;
        setState(() {
          _results = results;
          _failed = failed;
          _loading = false;
        });
      }

      try {
        show(await searchPlacesOnline(query, widget.near));
      } on Object {
        show(const [], failed: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final media = MediaQuery.of(context);
    final message = _failed
        ? l10n.placeSearchError
        : _query.length >= 3 && !_loading && _results.isEmpty
        ? l10n.placeSearchEmpty
        : null;
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SizedBox(
        // Hauteur fixe : la feuille ne saute pas pendant la recherche.
        height: media.size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                0,
                Space.screen,
                Space.md,
              ),
              child: TextField(
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: _onChanged,
                decoration: InputDecoration(
                  hintText: l10n.placeSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _loading
                      ? const Padding(
                          padding: EdgeInsets.all(Space.md),
                          child: SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                  isDense: true,
                ),
              ),
            ),
            if (message != null)
              Padding(
                padding: const EdgeInsets.all(Space.xxl),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: tokens.muted),
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: Space.lg),
                itemCount: _results.length,
                itemBuilder: (context, i) {
                  final place = _results[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: Space.screen,
                    ),
                    leading: Icon(Icons.place_outlined, color: tokens.muted),
                    title: Text(place.name),
                    subtitle: place.detail.isEmpty ? null : Text(place.detail),
                    onTap: () => Navigator.of(context).pop(place),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
