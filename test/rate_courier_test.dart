import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tchopi/features/orders/presentation/rate_courier_card.dart';

import 'courier_mission_screens_test.dart' show mission;

Widget app(Order order, int? stars) => ProviderScope(
  overrides: [orderRatingProvider.overrideWith((ref, id) async => stars)],
  child: MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: RateCourierCard(order: order)),
  ),
);

void main() {
  testWidgets(
    'livraison à noter : une étoile ouvre l\'évaluation, mots adaptés à la note',
    (tester) async {
      await tester.pumpWidget(app(mission(OrderStatus.delivered), null));
      await tester.pumpAndSettle();
      expect(
        find.text('Touchez une étoile pour noter la livraison.'),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('5 étoile(s)').first);
      await tester.pumpAndSettle();
      expect(find.text('Envoyer ma note'), findsOneWidget);
      expect(find.text('Rapide'), findsOneWidget);

      await tester.tap(find.byTooltip('2 étoile(s)').last);
      await tester.pumpAndSettle();
      expect(find.text('En retard'), findsOneWidget);
      expect(find.text('Rapide'), findsNothing);
    },
  );

  testWidgets('déjà notée : remerciement, étoiles figées', (tester) async {
    await tester.pumpWidget(app(mission(OrderStatus.delivered), 4));
    await tester.pumpAndSettle();
    expect(find.text('Merci pour votre note !'), findsOneWidget);
  });
}
