# Design system

> Phase 3 (rôle : UI/UX Designer). **Valeurs définitives** (elles remplacent la proposition de `direction.md` §3).
> Implémentation : `packages/core/lib/src/design/` — `ThemeData` Material 3 **clair uniquement** (ADR-019) + extension de thème `AppTokens`.
> Aucune couleur, taille ou durée en dur dans les écrans. Maquette : `docs/design/maquette.html`.

## 1. Couleurs

| Jeton | Valeur | Usage |
|-------|--------|-------|
| `background` | `#F5F6F3` | Fond des écrans |
| `surface` | `#FFFFFF` | Cartes, feuilles, barres |
| `surfaceAlt` | `#EEF1EC` | Champs, pastilles, tuiles d'icône |
| `border` | `#E4E7E2` | Séparateurs, contours |
| `ink` | `#0F1412` | Texte principal ; bouton pilule secondaire |
| `onInk` | `#FFFFFF` | Texte sur `ink` |
| `muted` | `#646B78` | Texte secondaire (AA sur `surface` et `background`) |
| `primary` | `#0B5D3B` | Action principale, éléments actifs |
| `onPrimary` | `#FFFFFF` | Texte sur `primary` (≥ 7:1) |
| `primarySoft` | `#E3F1E9` | Fond d'élément actif, pastilles de statut |
| `success` | `#16A34A` | Réussite, montants encaissés, action centrale |
| `progress` | `#22C55E` | Remplissage des barres (jamais de texte dessus) |
| `warning` | `#9A4A07` | En attente, alertes |
| `warningSoft` | `#FCEFD9` | Fond des pastilles « en attente » |
| `danger` | `#C81E1E` | Annulation, erreurs, montants remboursés |
| `dangerSoft` | `#FDE7E7` | Fond des pastilles et feuilles d'annulation |

Les contrastes texte / fond de ce tableau sont vérifiés automatiquement (`packages/core/test/design/tokens_test.dart`).

Règles : une seule action `primary` par écran ; les états (réussi, attente, erreur) combinent toujours couleur **et**
icône ou texte (jamais la couleur seule) ; les photos ne portent jamais de texte sans dégradé de lisibilité.

## 2. Typographie — Plus Jakarta Sans (embarquée)

| Style | Taille / interligne | Graisse | Usage |
|-------|---------------------|---------|-------|
| `display` | 32 / 38 | 800, espacement −2 % | Bienvenue, montants héros |
| `headline` | 26 / 32 | 800, −1 % | Titres d'écran |
| `title` | 20 / 26 | 700 | Titres de section, noms de restaurant |
| `subtitle` | 17 / 22 | 700 | Cartes, lignes importantes |
| `body` | 15 / 22 | 500 | Texte courant |
| `label` | 13 / 18 | 600 | Boutons secondaires, pastilles, champs |
| `caption` | 12 / 16 | 500 | Mentions, horodatages |

Prix, codes et compteurs en chiffres tabulaires. La taille de police du téléphone est respectée (jusqu'à 130 % sans
casse de mise en page ; au-delà, défilement).

## 3. Espacement, formes, élévation

- Espacements : `4 · 8 · 12 · 16 · 20 · 24 · 32 · 40`. Marge latérale d'écran : 20.
- Rayons : `chip 12` · `field 16` · `card 24` · `sheet 28` · `pill 999`.
- Élévation : une ombre douce unique pour les cartes flottantes (y 8, flou 24, noir 6 %). Pas de flou d'arrière-plan.
- Zones tactiles ≥ 48 dp ; boutons principaux hauteur 56, pleine largeur en bas d'écran.

## 4. Mouvement

| Jeton | Durée | Courbe | Usage |
|-------|-------|--------|-------|
| `fast` | 150 ms | décélération | Appui, bascule, compteur |
| `normal` | 250 ms | décélération | Apparition de feuille, changement d'étape |
| `emphasis` | 400 ms | décélération forte | Transition partagée image → détail, réussite |

Retour haptique léger : ajout au panier, acceptation d'une offre, code juste ; vibration d'erreur : code faux.
« Réduire les animations » du téléphone → transitions remplacées par des fondus de 100 ms.

## 5. Composants

| Composant | Variantes | États |
|-----------|-----------|-------|
| `AppButton` | plein `primary` · pilule `ink` · contour · texte · danger | normal, appuyé, désactivé, chargement (indicateur, libellé conservé) |
| `AppTextField` | texte · téléphone (indicatif) · mot de passe · montant | vide, focus, rempli, erreur (message sous le champ), désactivé |
| `CodeInput` | 4 cases (livraison) · 6 cases (OTP) | saisie, erreur (secousse), succès, verrouillé |
| `HeroOrderCard` | repas · colis | en attente, en cours (barre de progression), alerte (recherche longue) |
| `ServiceTile` | Repas · Colis | normal, appuyé |
| `RestaurantCard` | liste · compacte | ouvert, fermé (grisé + heure d'ouverture), chargement (squelette) |
| `ProductRow` | avec photo · sans photo | disponible (bouton +), dans le panier (compteur), indisponible (grisé) |
| `CartBar` | barre basse flottante | cachée, visible (articles · total), envoi |
| `StatusPill` | info · attente · succès · danger | — |
| `StatusStepper` | repas (6 étapes) · colis (6 étapes) | étape faite, courante (animée), à venir, interrompue |
| `ConfirmSheet` | neutre · destructive | explique la conséquence avant l'action |
| `AddressField` | icône + quartier + repère + chevron | vide, rempli, hors zone |
| `OnlineSwitch` (livreur) | — | hors ligne, passage en cours, en ligne |
| `OfferCard` (livreur) | — | compte à rebours, acceptation, expirée, plus disponible |
| `MapView` | suivi · sélection d'adresse · mission | position fraîche, position ancienne (grisée), sans position |
| `ConnectionBanner` | — | hors ligne, reconnexion, rétablie (disparaît) |
| `EmptyState` / `ErrorState` / `Skeleton` | — | — |
| `BottomNav` | 4 onglets + action centrale ronde | onglet actif (pastille `primarySoft`) |

## 6. Accessibilité et contenus

Contrastes AA vérifiés dans les deux thèmes · libellés `Semantics` sur toutes les icônes actives · ordre de lecture
logique · aucun texte dans les images · messages au ton direct, sans jargon (voir plan §3.4) · montants « 8 800 F » ·
heures « 18:00 » · dates « 5 oct. ».
