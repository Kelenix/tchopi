# MVP Livraison — repas et colis (Abidjan)

Trois applications Flutter et un back-end Supabase :

| Dossier | Application | Plateformes |
|---------|-------------|-------------|
| `apps/client` | Client : commander un repas, envoyer un colis, payer, suivre | Android (iOS prêt) |
| `apps/courier` | Livreur : missions, navigation, code de livraison, espèces | Android (iOS prêt) |
| `apps/backoffice` | Restaurants partenaires et administration | Android, navigateur |
| `packages/core` | Code partagé : design system, textes, Supabase, écrans communs | — |
| `supabase/` | Base de données : migrations, règles d'accès (RLS), tests pgTAP | — |

Nom de l'app provisoire : « Tchopi ». Documentation : `docs/` (plan, produit, architecture, données, design).
État d'avancement : `PROJECT_STATE.md`.

## Prérequis

- Flutter **3.41.9** (Dart 3.11) — `flutter --version`
- Android SDK (Android Studio) et un téléphone ou un émulateur Android
- Docker Desktop **démarré** (pile Supabase locale)
- Supabase CLI ≥ 2.116 — `supabase --version`

## Installation

```bash
flutter pub get
```

Activer les contrôles Git (format avant commit, analyse avant envoi) :

```bash
git config core.hooksPath .githooks
```

Le code généré (Riverpod, textes français) est versionné : l'app se lance directement après `pub get`.
Après une modification d'un fichier `@riverpod` ou de `packages/core/lib/l10n/app_fr.arb` :

```bash
cd packages/core && flutter gen-l10n && dart run build_runner build -d
```

(et `dart run build_runner build -d` dans l'app concernée).

## Lancer en local

1. Démarrer Supabase (première fois : quelques minutes de téléchargement) :
   ```bash
   supabase start
   ```
2. Créer `env/local.json` à partir de `env/example.json` et y coller la clé `anon` affichée par `supabase status`.
3. Rendre Supabase local accessible depuis le téléphone ou l'émulateur Android :
   ```bash
   adb reverse tcp:54321 tcp:54321
   ```
4. Lancer une app :
   ```bash
   cd apps/client && flutter run --dart-define-from-file=../../env/local.json
   ```
   Back-office dans le navigateur : `cd apps/backoffice && flutter run -d chrome --dart-define-from-file=../../env/local.json`.

Sans `--dart-define-from-file`, l'app s'arrête au démarrage avec le message « Configuration manquante ».

## Vérifier (mêmes contrôles que la CI)

```bash
flutter analyze
```

```bash
cd packages/core && flutter test
```

(idem dans `apps/client`, `apps/courier`, `apps/backoffice`)

```bash
supabase db reset && supabase test db
```

Tests d'intégration réels (Supabase local démarré, `env/local.json` présent) :

```bash
cd packages/core && flutter test -t integration --run-skipped
```

Comptes de test locaux : numéros `+2250700000001` et `+2250700000002`, code SMS `123456`.
Les emails envoyés en local (codes de vérification) sont visibles sur http://127.0.0.1:54324.

## Structure du code Flutter

```
packages/core/lib/
├── core.dart            # API publique du package
├── l10n/                # textes français (app_fr.arb) + code généré
└── src/
    ├── app/             # racine commune (thèmes, langue), démarrage
    ├── auth/            # écrans communs d'accès (bienvenue…)
    ├── config/          # configuration injectée au build
    ├── design/          # jetons, thèmes clair / sombre, illustrations provisoires
    └── supabase/        # initialisation, session dans le stockage sécurisé
apps/<app>/lib/
├── main.dart            # démarrage de l'app
└── router.dart          # navigation (go_router)
```

## Sécurité

- Les apps ne contiennent que l'URL et la clé publique Supabase ; toute règle d'accès est appliquée par la base (RLS).
- La session est stockée dans le Keystore Android / Keychain iOS.
- HTTP en clair autorisé uniquement dans les builds de débogage (Supabase local) ; production en HTTPS.
