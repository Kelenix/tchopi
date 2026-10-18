import 'package:client/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("démarre sur l'écran de bienvenue, en français", (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ClientApp()));
    await tester.pumpAndSettle();

    expect(
      find.text('Vos plats et vos colis, livrés dans tout Abidjan.'),
      findsOneWidget,
    );
  });
}
