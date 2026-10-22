import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design/app_theme.dart';
import '../supabase/supabase_setup.dart';

/// Démarrage commun : licence de la police embarquée, Supabase, puis l'app.
Future<void> bootstrap(Widget app) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Plein écran, bord à bord : pas de bande grise sous l'app derrière la barre de gestes.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(systemBars(darkIcons: true));
  LicenseRegistry.addLicense(() async* {
    final ofl = await rootBundle.loadString(
      'packages/core/assets/fonts/OFL.txt',
    );
    yield LicenseEntryWithLineBreaks(const ['Plus Jakarta Sans'], ofl);
  });
  await initSupabase();
  runApp(ProviderScope(child: app));
}
