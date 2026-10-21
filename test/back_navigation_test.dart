import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tchopi/features/courier/courier_nav_bar.dart';

void main() {
  testWidgets(
    'retour Android : écran poussé, puis onglet secondaire, puis accueil',
    (tester) async {
      Widget tab(int i) => Scaffold(
        body: Text('tab $i'),
        bottomNavigationBar: CourierNavBar(current: i),
      );
      final router = GoRouter(
        initialLocation: CourierNavBar.paths.first,
        routes: [
          for (final (i, p) in CourierNavBar.paths.indexed)
            GoRoute(path: p, builder: (_, _) => tab(i)),
          GoRoute(
            path: '/detail',
            builder: (_, _) => const Scaffold(body: Text('détail')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light,
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();

      // Onglet « Historique » puis un détail poussé par-dessus.
      router.go(CourierNavBar.paths[1]);
      await tester.pumpAndSettle();
      unawaited(router.push('/detail'));
      await tester.pumpAndSettle();
      expect(find.text('détail'), findsOneWidget);

      // Retour : l'écran précédent, puis l'accueil de l'espace (pas de fermeture).
      expect(await tester.binding.handlePopRoute(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('tab 1'), findsOneWidget);
      expect(await tester.binding.handlePopRoute(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('tab 0'), findsOneWidget);
    },
  );
}
