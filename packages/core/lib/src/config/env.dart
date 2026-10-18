/// Configuration injectée au build : `--dart-define-from-file=../../env/<env>.json`.
///
/// Ces valeurs sont publiques par conception (URL et clé `anon` de Supabase) :
/// la sécurité des données repose sur la RLS, jamais sur leur confidentialité.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

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
