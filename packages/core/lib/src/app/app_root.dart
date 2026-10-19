import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../design/app_theme.dart';
import 'theme_preference.dart';

/// Racine commune : thèmes clair et sombre (choix mémorisé), français, navigation fournie par l'app.
class AppRoot extends ConsumerWidget {
  const AppRoot({super.key, required this.router});

  final RouterConfig<Object> router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appBrand,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themePreferenceProvider),
      locale: const Locale('fr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
