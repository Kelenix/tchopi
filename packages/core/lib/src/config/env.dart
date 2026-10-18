/// Configuration injectée au build : `--dart-define-from-file=../../env/<env>.json`.
///
/// Ces valeurs sont publiques par conception (URL et clé `anon` de Supabase) :
/// la sécurité des données repose sur la RLS, jamais sur leur confidentialité.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Vrai quand une clé Google Maps est fournie au build Android (`MAPS_API_KEY`, voir README) ;
  /// sinon les écrans affichent un emplacement à la place de la carte.
  static const mapsEnabled = bool.fromEnvironment('GOOGLE_MAPS_ENABLED');

  /// Échoue au démarrage plutôt qu'au premier appel réseau si la configuration manque.
  static void ensureConfigured() {
    final missing = [
      if (supabaseUrl.isEmpty) 'SUPABASE_URL',
      if (supabaseAnonKey.isEmpty) 'SUPABASE_ANON_KEY',
    ];
    if (missing.isEmpty) return;
    throw StateError(
      'Configuration manquante : ${missing.join(', ')}. '
      'Lancez l\'app avec --dart-define-from-file=../../env/local.json (voir README).',
    );
  }
}
