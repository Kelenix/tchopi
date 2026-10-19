# Performance — budgets, mesures, optimisations

> Phase 5 (2026-10-19). Budgets : `docs/design/direction.md` §5. Rôle : `11-performance-engineer`.

## Mesures

| Mesure | Budget | Résultat | État |
|--------|--------|----------|------|
| Taille de l'APK arm64 (release) | < 25 Mo | **22,5 Mo** (moteur Flutter 10,8 · code Dart 9,4 · Java 0,75 · images et polices 0,67) | ✅ |
| Démarrage : attente réseau avant le premier écran | aucune | session lue sur l'appareil ; rafraîchissement du jeton en arrière-plan (supabase_flutter 2.18) | ✅ |
| Backend, 50 utilisateurs simultanés | p95 < 500 ms, < 1 % d'échecs | p95 ≤ 240 ms, 0 échec (`docs/qa/load-report.md`) | ✅ |
| Écrans clés sur petit téléphone (320 × 568 dp), police + 30 % | aucun débordement | aucun (tests de widgets) | ✅ |
| Démarrage à froid, fluidité (60 i/s) sur téléphone réel | < 3 s, aucune image > 16 ms | **à mesurer sur votre téléphone** (commande ci-dessous) | ⏳ |

Le Play Store distribue un « app bundle » : le téléchargement réel est plus léger que l'APK (compression).

## Optimisations appliquées

| Sujet | Avant | Après |
|-------|-------|-------|
| Photos (couvertures, produits) | décodées en pleine résolution (1600 px pour une vignette de 96 px), téléchargées à chaque ouverture | décodées à la taille affichée, gardées sur l'appareil (`cached_network_image`, `MediaImage`) : moins de mémoire et de données mobiles |
| Photo de produit dans le menu du restaurant | `Image.network` sans cache | même widget `MediaImage` (48 px) |
| Clés étrangères sans index (9) | suppression d'un produit, d'une catégorie ou d'une zone = parcours complet des tables liées | index ajoutés (migration `20261019140000_fk_indexes.sql`) |

## Contrôles sans changement

- Requêtes : colonnes utiles ou modèles complets, listes bornées (`limit` 5 à 200), aucune requête par ligne (N+1) ;
  index présents pour les requêtes fréquentes (commandes du client, du restaurant, offres en attente, positions).
- Listes : les listes de données restent courtes (≤ 200 éléments) ; Flutter ne construit que les éléments visibles.
- Images envoyées par les restaurants et livreurs : réduites à 800 px, qualité 80, avant l'envoi.
- Base : `supabase db lint` sans alerte sur `public` et `private` ; RLS active avec politiques sur les 25 tables.

## Mesurer sur votre téléphone (démarrage et fluidité)

Téléphone branché en USB, débogage autorisé, depuis `apps\mobile` :

```powershell
flutter run --profile --dart-define-from-file=..\..\env\phone.json
```

Puis, dans le terminal, touche `v` : DevTools s'ouvre (onglet Performance : images en rouge = > 16 ms).
Parcours à faire : accueil → fiche restaurant → panier → validation ; suivi d'une commande ; mission livreur.
Temps de démarrage à froid (app fermée) :

```powershell
adb shell am start -W -n com.tchopi.mobile/.MainActivity
```

`TotalTime` doit rester sous 3000 ms.
