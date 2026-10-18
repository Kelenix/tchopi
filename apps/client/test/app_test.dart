import 'package:core/core.dart';
import 'package:client/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("sans session, démarre sur l'écran de bienvenue en français", (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionProvider.overrideWith((ref) => Stream.value(null))],
        child: const ClientApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Vos plats et vos colis, livrés dans tout Abidjan.'),
      findsOneWidget,
    );
  });
}
