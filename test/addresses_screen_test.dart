import 'package:tchopi/features/client/addresses/application/addresses_providers.dart';
import 'package:tchopi/features/client/addresses/presentation/addresses_screen.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAddresses extends Addresses {
  _FakeAddresses(this.items);

  final List<Address> items;

  @override
  Future<List<Address>> build() async => items;
}

Widget app(List<Address> items) => ProviderScope(
  overrides: [addressesProvider.overrideWith(() => _FakeAddresses(items))],
  child: MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: const AddressesScreen(),
  ),
);

void main() {
  testWidgets('aucune adresse : invitation à ajouter la première', (
    tester,
  ) async {
    await tester.pumpWidget(app(const []));
    await tester.pumpAndSettle();

    expect(find.text('Ajoutez votre première adresse'), findsOneWidget);
    expect(find.text('Ajouter une adresse'), findsOneWidget);
  });

  testWidgets('adresses : quartier, repère et adresse par défaut visibles', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(const [
        Address(
          id: '1',
          district: 'Cocody',
          landmark: 'Derrière la pharmacie centrale',
          instructions: 'Portail bleu',
          latitude: 5.35,
          longitude: -3.99,
          city: 'Abidjan',
          isDefault: true,
        ),
        Address(
          id: '2',
          label: 'Bureau',
          district: 'Plateau',
          landmark: 'Tour A',
          latitude: 5.32,
          longitude: -4.02,
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Maison · Cocody'), findsOneWidget);
    expect(
      find.textContaining('Derrière la pharmacie centrale'),
      findsOneWidget,
    );
    expect(find.text('Par défaut'), findsOneWidget);
    expect(find.text('Bureau · Plateau'), findsOneWidget);
  });
}
