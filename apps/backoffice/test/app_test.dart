import 'package:backoffice/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("démarre sur l'écran de bienvenue, en français", (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BackofficeApp()));
    await tester.pumpAndSettle();

    expect(
      find.text("L'espace des restaurants partenaires et de l'équipe."),
      findsOneWidget,
    );
  });
}
