import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../design/app_theme.dart';

/// Racine commune aux 3 apps : thèmes clair / sombre, français, navigation fournie par l'app.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key, required this.router});

  final RouterConfig<Object> router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appBrand,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: const Locale('fr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
