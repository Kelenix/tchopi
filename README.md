# MVP Livraison — repas et colis (Abidjan)

Une application Flutter (un espace par rôle) et un back-end Supabase :

| Dossier | Application | Plateformes |
|---------|-------------|-------------|
| `apps/mobile` | App unique : espaces Client, Livreur, Restaurant (Inc-4), Admin — menu « Changer d'espace » | Android (iOS prêt), navigateur pour l'admin |
| `packages/core` | Code partagé : design system, textes, Supabase, écrans communs | — |
| `supabase/` | Base de données : migrations, règles d'accès (RLS), tests pgTAP | — |

Nom de l'app provisoire : « Tchopi ». Documentation : `docs/` (plan, produit, architecture, données, design).
État d'avancement : `PROJECT_STATE.md`.

## Prérequis

- Flutter **3.41.9** (Dart 3.11) — `flutter --version`
- Chrome (le plus simple pour tester), ou Android SDK avec un téléphone / émulateur
- Docker Desktop **démarré** (pile Supabase locale)
- Supabase CLI ≥ 2.116 — `supabase --version`

## Installation

```powershell
flutter pub get
```

Activer les contrôles Git (format avant commit, analyse avant envoi) :

```powershell
git config core.hooksPath .githooks
```

Le code généré (Riverpod, textes français) est versionné : l'app se lance directement après `pub get`.
Après une modification d'un fichier `@riverpod`, d'un modèle ou de `packages/core/lib/l10n/app_fr.arb`, `.\check.ps1` régénère tout.

## Lancer en local (PowerShell, depuis la racine du projet)

Toutes les commandes se tapent dans PowerShell, dans le dossier du projet (`C:\PROJECT PERSO\food-delive`).
Windows PowerShell n'accepte pas `&&` : une commande par ligne, ou les scripts ci-dessous.

1. Démarrer Supabase (Docker Desktop ouvert ; la première fois, quelques minutes) :
   ```powershell
   supabase start
   ```
2. Créer `env/local.json` à partir de `env/example.json` et y coller la clé `anon` (ou `Publishable`) affichée par `supabase status`.
3. Lancer l'app **dans Chrome** (aucun téléphone nécessaire) :
   ```powershell
   .\run.ps1 -d chrome
   ```
   Sur un téléphone Android branché en USB (débogage USB activé) ou un émulateur ouvert :
   ```powershell
   adb reverse tcp:54321 tcp:54321
   .\run.ps1
   ```
   `adb devices` doit lister l'appareil ; sinon « no devices/emulators found ».
4. Créer un compte (aucun compte n'existe au départ) : « Créer un compte », numéro `07 00 00 00 01`
   (ou `07 00 00 00 02`), un mot de passe de ton choix (8 caractères, lettres et chiffres), puis le code SMS
   `123456`. Ensuite, se connecter avec ce numéro et ce mot de passe. Les emails locaux
   (codes de vérification) sont visibles sur http://127.0.0.1:54324, la base sur http://127.0.0.1:54323.
5. Devenir admin (espace Admin : zones, livreurs, utilisateurs, restaurants) :
   ```powershell
   .\dev-admin.ps1 +2250700000001
   ```
   puis se déconnecter / reconnecter. L'espace Restaurant apparaît pour un compte invité comme gérant par l'admin.

En local, trois restaurants de démonstration et leurs menus sont créés par `supabase/seed.sql` (à chaque
`supabase db reset`). La carte utilise les tuiles OpenStreetMap, sans clé (voir `docs/manual-tasks.md` §7 pour la production).

Si PowerShell refuse d'exécuter les scripts (« l'exécution de scripts est désactivée ») :
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

Sans `env/local.json`, l'app s'arrête au démarrage avec le message « Configuration manquante ».

## Vérifier (mêmes contrôles que la CI)

```powershell
.\check.ps1
```

Enchaîne code généré, `flutter analyze`, tests Flutter et tests de la base (pgTAP), et s'arrête à la première erreur.
Attention : les tests de la base **vident la base locale** (refaire l'étape 5 ensuite).
Options : `-SkipDb` (sans Docker), `-Integration` (ajoute les tests réels contre Supabase local).

## Structure du code Flutter

```
packages/core/lib/
├── core.dart            # API publique du package
├── l10n/                # textes français (app_fr.arb) + code généré
└── src/
    ├── app/             # racine commune (thèmes, langue), démarrage
    ├── auth/            # écrans communs d'accès (bienvenue…)
    ├── config/          # configuration injectée au build
    ├── design/          # jetons, thème clair, composants partagés
    └── supabase/        # initialisation, session dans le stockage sécurisé
apps/<app>/lib/
├── main.dart            # démarrage de l'app
└── router.dart          # navigation (go_router)
```

## Sécurité

- Les apps ne contiennent que l'URL et la clé publique Supabase ; toute règle d'accès est appliquée par la base (RLS).
- La session est stockée dans le Keystore Android / Keychain iOS.
- HTTP en clair autorisé uniquement dans les builds de débogage (Supabase local) ; production en HTTPS.
