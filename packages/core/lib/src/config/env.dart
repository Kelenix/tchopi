/// Configuration de l'app. Par défaut le serveur en ligne : `flutter run` suffit. Pour le Supabase du PC :
/// `flutter run --dart-define-from-file=env/local.json`.
///
/// Ces valeurs sont publiques par conception (URL et clé `anon` de Supabase, présentes dans toute app publiée) :
/// la sécurité des données repose sur la RLS, jamais sur leur confidentialité.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://api.tchopi.com',
  );

  /// Clé `anon` du serveur en ligne (à mettre à jour si le serveur est réinstallé : docs/deployer-sur-vps.md).
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzkyNDE0NjA1LCJleHAiOjE5NTAwOTQ2MDV9.nclb8EOOkSElPrTlwOQXuefHArkqmaumSSDKPpDUg9k',
  );

  /// Fond de carte (ADR-033) : style OpenFreeMap (données OpenStreetMap), gratuit, sans clé ni compte. « Positron »,
  /// sobre, met en valeur le trajet et les repères ; même famille que le style sombre (ADR-038).
  static const mapStyleUrl = String.fromEnvironment(
    'MAP_STYLE_URL',
    defaultValue: 'https://tiles.openfreemap.org/styles/positron',
  );

  /// Même fond en thème sombre (ADR-038).
  static const mapStyleDarkUrl = String.fromEnvironment(
    'MAP_STYLE_DARK_URL',
    defaultValue: 'https://tiles.openfreemap.org/styles/dark',
  );

  /// Calcul des trajets routiers affichés sur les cartes (OSRM, ADR-038), hébergé sur le serveur en ligne (Côte
  /// d'Ivoire seulement).
  static const routingUrl = String.fromEnvironment(
    'ROUTING_URL',
    defaultValue: 'https://api.tchopi.com',
  );

  /// Mention exigée par les fournisseurs du fond de carte.
  static const mapAttribution = String.fromEnvironment(
    'MAP_ATTRIBUTION',
    defaultValue: '© OpenFreeMap © OpenMapTiles © OpenStreetMap',
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
}
