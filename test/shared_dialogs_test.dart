import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tchopi/shared/dialogs.dart';

void main() {
  testWidgets('text input uses the shared sheet and returns its value', (
    tester,
  ) async {
    Future<String?>? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => result = askText(
                  context,
                  title: 'Motif',
                  label: 'Votre réponse',
                ),
                child: const Text('Ouvrir'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.enterText(find.byType(TextField), 'Adresse introuvable');
    await tester.pump();
    final submit = find.widgetWithText(FilledButton, 'Continuer');
    expect(tester.widget<FilledButton>(submit).onPressed, isNotNull);
    await tester.tap(find.text('Continuer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(await result!, 'Adresse introuvable');
  });
}
