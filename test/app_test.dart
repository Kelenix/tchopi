import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tchopi/main.dart';

void main() {
  testWidgets(
    "sans session : animation, puis écran d'accès (connexion obligatoire)",
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MobileApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1500));
      expect(find.text('Vos plats préférés, livrés chez vous'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('Vos plats préférés, livrés chez vous'), findsNothing);
      expect(find.text('Bienvenue !'), findsOneWidget);
      expect(find.text('Continuer avec Google'), findsOneWidget);
      expect(find.text('🇨🇮 +225'), findsOneWidget);
    },
  );
}
