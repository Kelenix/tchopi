import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';
import 'package:tchopi/shared/place_search.dart';

void main() {
  test(
    'recherche de lieux : Côte d\'Ivoire seulement, près de la carte, résultats lisibles',
    () async {
      late Uri asked;
      final client = MockClient((request) async {
        asked = request.url;
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'features': [
                {
                  'geometry': {
                    'coordinates': [-4.0035, 5.3372],
                  },
                  'properties': {
                    'name': 'Pharmacie Saint-Jean de Cocody',
                    'district': 'Cocody',
                    'city': 'Abidjan',
                  },
                },
                {
                  'geometry': {
                    'coordinates': [-5, 7],
                  },
                  'properties': {'name': 'Koko', 'city': 'Bouaké'},
                },
                // Sans nom : ignoré.
                {
                  'geometry': {
                    'coordinates': [-4, 5],
                  },
                  'properties': {'city': 'Abidjan'},
                },
              ],
            }),
          ),
          200,
        );
      });

      final places = await searchPlacesOnline(
        'pharmacie saint jean',
        const LatLng(5.35, -4.0),
        client: client,
      );

      expect(asked.queryParameters['q'], 'pharmacie saint jean');
      expect(asked.queryParameters['lat'], '5.35');
      expect(asked.queryParameters['bbox'], '-8.61,4.34,-2.49,10.74');
      expect(places, hasLength(2));
      expect(places.first.name, 'Pharmacie Saint-Jean de Cocody');
      expect(places.first.detail, 'Cocody, Abidjan');
      expect(places.first.point, const LatLng(5.3372, -4.0035));
      expect(places.last.point, const LatLng(7, -5));
      expect(places.last.detail, 'Bouaké');
    },
  );
}
