import 'package:core/core.dart';
import 'package:core/src/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? AppTheme.light,
  locale: const Locale('fr'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: Scaffold(body: Form(child: child)),
);

void main() {
  group('Référentiel des lieux', () {
    test('villes sans doublon, accents compris', () {
      final folded = ivoryCoastCities.map(foldAccents).toList();
      expect(folded.toSet(), hasLength(folded.length));
      expect(ivoryCoastCities, containsAll(['Abidjan', 'Bouaké', 'San-Pédro']));
    });

    test('quartiers rattachés à des villes connues, sans doublon', () {
      for (final MapEntry(key: city, value: districts)
          in districtsByCity.entries) {
        expect(ivoryCoastCities, contains(city));
        expect(districts.toSet(), hasLength(districts.length), reason: city);
      }
    });

    test('recherche sans accents ni casse', () {
      expect(foldAccents("Séguéla M'Bahiakro"), "seguela m'bahiakro");
      expect(searchPlaces(ivoryCoastCities, 'bouake'), ['Bouaké']);
      expect(searchPlaces(['Cocody', 'Adjamé'], '  ADJAME '), ['Adjamé']);
      expect(searchPlaces(ivoryCoastCities, 'mbahia'), ["M'Bahiakro"]);
      expect(searchPlaces(['A', 'B'], ''), ['A', 'B']);
    });

    test('ville de la zone la plus proche contenant le point', () {
      const abidjan = Zone(
        id: 'a',
        name: 'Abidjan',
        city: 'Abidjan',
        centerLat: 5.345,
        centerLng: -4.024,
        radiusM: 25000,
      );
      const bouake = Zone(
        id: 'b',
        name: 'Bouaké',
        city: 'Bouaké',
        centerLat: 7.69,
        centerLng: -5.03,
        radiusM: 15000,
      );
      expect(cityAt([abidjan, bouake], 5.36, -3.99), 'Abidjan');
      expect(cityAt([abidjan, bouake], 7.7, -5.02), 'Bouaké');
      expect(cityAt([abidjan, bouake], 6.8, -5.3), isNull);
    });
  });

  testWidgets('choix de ville : recherche puis sélection', (tester) async {
    String? chosen;
    await tester.pumpWidget(
      app(
        CityField(
          served: const ['Abidjan'],
          onChanged: (city) => chosen = city,
        ),
      ),
    );
    await tester.tap(find.text('Ville'));
    await tester.pumpAndSettle();
    expect(find.text('Livraisons disponibles'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'san ped');
    await tester.pumpAndSettle();
    await tester.tap(find.text('San-Pédro'));
    await tester.pumpAndSettle();
    expect(chosen, 'San-Pédro');
    expect(find.text('San-Pédro'), findsOneWidget);
  });

  testWidgets('quartier : suggestions de la ville, saisie libre conservée', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      app(
        DistrictField(controller: controller, city: () => 'Abidjan'),
        theme: AppTheme.dark,
      ),
    );
    await tester.enterText(find.byType(TextFormField), 'riviera');
    await tester.pumpAndSettle();
    expect(find.text('Cocody Riviera 2'), findsOneWidget);
    await tester.tap(find.text('Cocody Riviera 2'));
    await tester.pumpAndSettle();
    expect(controller.text, 'Cocody Riviera 2');

    await tester.enterText(find.byType(TextFormField), 'Chez Tantie');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNothing);
    expect(controller.text, 'Chez Tantie');
  });
}
