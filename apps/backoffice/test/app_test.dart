import 'package:core/core.dart';
import 'package:backoffice/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("sans session, démarre sur l'écran de bienvenue en français", (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionProvider.overrideWith((ref) => Stream.value(null))],
        child: const BackofficeApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text("L'espace des restaurants partenaires et de l'équipe."),
      findsOneWidget,
    );
  });
}
