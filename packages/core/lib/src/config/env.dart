/// Configuration injectée au build : `--dart-define-from-file=../../env/<env>.json`.
///
/// Ces valeurs sont publiques par conception (URL et clé `anon` de Supabase) :
/// la sécurité des données repose sur la RLS, jamais sur leur confidentialité.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Fond de carte. Par défaut les tuiles d'OpenStreetMap, réservées au développement (faible trafic) ;
  /// en production, l'URL du fournisseur retenu (ADR-019, docs/manual-tasks.md).
  static const mapTilesUrl = String.fromEnvironment(
    'MAP_TILES_URL',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  /// Notifications push (ADR-025) : configuration Firebase de l'app, publique par conception. Vide tant que le
  /// projet Firebase n'est pas créé (docs/manual-tasks.md §8) : les notifications sont alors désactivées.
  static const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
  static const firebaseSenderId = String.fromEnvironment('FIREBASE_SENDER_ID');
  static const firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
  );

  static bool get pushConfigured =>
      firebaseApiKey.isNotEmpty &&
      firebaseAppId.isNotEmpty &&
      firebaseSenderId.isNotEmpty &&
      firebaseProjectId.isNotEmpty;

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
