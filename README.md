# Tchopi — livraison de repas et de colis (Abidjan)

Une application Flutter (un espace par rôle) et un back-end Supabase en ligne :

| Dossier | Contenu | Plateformes |
|---------|---------|-------------|
| `lib/`, `android/`, `ios/`, `web/` | L'app : espaces Client, Livreur, Restaurant, Admin — menu « Changer d'espace » | Android (iOS prêt), navigateur |
| `packages/core` | Code partagé : design system, textes, Supabase, écrans communs | — |
| `supabase/` | Base de données : migrations, règles d'accès (RLS), fonctions serveur, tests pgTAP | — |
| `infra/`, `vps.ps1` | Serveur en ligne https://api.tchopi.com (VPS) — `docs/deployer-sur-vps.md` | — |

Documentation : `docs/` (plan, produit, architecture, données, design). État d'avancement : `PROJECT_STATE.md`.

## Lancer l'application

Prérequis : Flutter **3.41** (`flutter --version`), puis une fois `flutter pub get`. L'app utilise directement le
serveur en ligne (https://api.tchopi.com) : aucune configuration.

| Pour… | Commande |
|-------|----------|
| Lancer sur le téléphone branché en USB (ou un émulateur) | `flutter run` |
| Lancer dans le navigateur | `flutter run -d chrome` |
| Créer l'APK à envoyer sur un téléphone | `flutter build apk --release` |

- **Téléphone, la première fois** : Paramètres → À propos du téléphone → appuyer 7 fois sur « Numéro de build » ;
  Options pour les développeurs → activer **Débogage USB** ; brancher, accepter « Autoriser le débogage USB ».
  `flutter devices` doit afficher le téléphone.
- **APK** : `build\app\outputs\flutter-apk\app-release.apk`, à envoyer (WhatsApp, Google Drive…) ; sur le téléphone,
  autoriser « Installer des applis inconnues ».
- **Comptes** : pas encore de SMS réel ; un numéro doit être autorisé avant l'inscription :
  `.\vps.ps1 testeur +225XXXXXXXXXX <code à 6 chiffres>` (`docs/deployer-sur-vps.md`).

## Développer avec le Supabase du PC (facultatif)

Pour tester des changements de la base sans toucher au serveur en ligne. Docker Desktop **démarré** et Supabase CLI
≥ 2.116 (`supabase --version`).

1. Démarrer Supabase (la première fois, quelques minutes) : `supabase start`
2. Créer `env/local.json` à partir de `env/example.json` et y coller la clé `anon` (ou `Publishable`) affichée par
   `supabase status`. Copier `supabase/functions/.env.example` vers `supabase/functions/.env` (paiement Mobile Money
   simulé), puis relancer `supabase stop` et `supabase start`.
3. Lancer l'app reliée à ce Supabase :
   ```powershell
   flutter run -d chrome --dart-define-from-file=env/local.json
   ```
   Sur un téléphone branché : `adb reverse tcp:54321 tcp:54321`, puis la même commande sans `-d chrome`.
4. Comptes : `.\dev-accounts.ps1` (identifiants : `docs/donnees-de-test.md`), ou « Créer un compte » avec un numéro
   `07 00 00 00 01` à `09` et le code SMS `123456`. Admin : `.\dev-admin.ps1 +2250700000001`, puis se reconnecter.
   Emails locaux : http://127.0.0.1:54324 ; base : http://127.0.0.1:54323.
5. Commander exige **un livreur en ligne** dans la zone : un second compte, espace Livreur → « Devenir livreur »,
   validation par l'admin (Admin → Livreurs), puis interrupteur « En ligne ».

Trois restaurants de démonstration sont créés par `supabase/seed.sql` (à chaque `supabase db reset`).

Activer les contrôles Git (format avant commit) : `git config core.hooksPath .githooks`. Si PowerShell refuse les
scripts : `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.

Le code généré (Riverpod, textes français) est versionné. Après une modification d'un fichier `@riverpod`, d'un modèle
ou de `packages/core/lib/l10n/app_fr.arb`, `.\check.ps1` régénère tout.

## Vérifier (mêmes contrôles que la CI)

```powershell
.\check.ps1
```

Enchaîne code généré, `flutter analyze`, tests Flutter et tests de la base (pgTAP), et s'arrête à la première erreur.
Attention : les tests de la base **vident la base locale** du PC (refaire l'étape 4 ensuite).
Options : `-SkipDb` (sans Docker), `-Integration` (ajoute les tests réels contre Supabase local).

## Structure du code Flutter

```
lib/
├── main.dart            # démarrage de l'app
├── router.dart          # navigation (go_router)
├── spaces/              # espaces par rôle et « Changer d'espace »
├── features/            # client, livreur, restaurant, admin, commandes, colis
└── shared/              # cartes, médias, notifications, dialogues
packages/core/lib/
├── core.dart            # API publique du package
├── l10n/                # textes français (app_fr.arb) + code généré
└── src/
    ├── app/             # racine commune (thèmes, langue), démarrage
    ├── auth/            # écrans communs d'accès
    ├── config/          # adresse du serveur et clés publiques (env.dart)
    ├── design/          # jetons, thème, composants partagés
    └── supabase/        # initialisation, session dans le stockage sécurisé
```

## Sécurité

- L'app ne contient que l'URL et la clé publique `anon` de Supabase ; toute règle d'accès est appliquée par la base (RLS).
- La session est stockée dans le Keystore Android / Keychain iOS.
- HTTP en clair autorisé uniquement dans les builds de débogage (Supabase local) ; serveur en ligne en HTTPS.
