import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tchopi/main.dart';

void main() {
  testWidgets("sans session, démarre sur l'écran de bienvenue en français", (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionProvider.overrideWith((ref) => Stream.value(null))],
        child: const MobileApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Vos plats et vos colis, livrés partout dans votre ville.'),
      findsOneWidget,
    );
  });
}
