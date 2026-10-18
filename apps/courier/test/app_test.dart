import 'package:core/core.dart';
import 'package:courier/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("sans session, démarre sur l'écran de bienvenue en français", (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionProvider.overrideWith((ref) => Stream.value(null))],
        child: const CourierApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Livrez à Abidjan, à votre rythme.'), findsOneWidget);
  });
}
