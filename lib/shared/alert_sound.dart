import 'alert_sound_io.dart'
    if (dart.library.js_interop) 'alert_sound_web.dart'
    as impl;

/// Son d'alerte court (nouvelle commande, nouvelle offre) : deux bips dans le navigateur (NOT-03), son du système
/// sur téléphone. Les notifications push prennent le relais quand l'app est fermée (ADR-025).
void playAlertSound() => impl.playAlertSound();
