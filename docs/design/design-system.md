# Design system

> Phase 3 (rôle : UI/UX Designer). Valeurs actuelles de la palette Tchopi, ajustées pour garder un contraste lisible dans les deux thèmes.
> Implémentation : `packages/core/lib/src/design/` — `ThemeData` Material 3 **clair et sombre** au choix de l’utilisateur (ADR-038) + extension de thème `AppTokens`.
> Aucune couleur, taille ou durée en dur dans les écrans. Maquette : `docs/design/maquette.html`.

## 1. Couleurs

| Jeton | Clair | Sombre | Usage |
|-------|-------|--------|-------|
| `background` | `#FAF8F5` | `#101418` | Fond des écrans |
| `surface` | `#FFFFFF` | `#1A222B` | Cartes, feuilles, barres |
| `surfaceAlt` | `#F2EEE8` | `#232C36` | Champs, pastilles, tuiles d'icône |
| `border` | `#E5DED7` | `#37424D` | Séparateurs, contours |
| `ink` | `#16202A` | `#F6F7F8` | Texte principal ; bouton secondaire |
| `onInk` | `#FFFFFF` | `#101418` | Texte sur `ink` |
| `muted` | `#59636E` | `#A7B0BA` | Texte secondaire |
| `primary` | `#B94A12` | `#FF9F5C` | Icônes et texte de marque, contrastés sur les surfaces |
| `onPrimary` | `#FFFFFF` | `#201109` | Contenu sur `primary` |
| `primaryAction` | `#F47B20` | `#FF8A3D` | Boutons principaux, accents et illustrations |
| `onPrimaryAction` | `#16202A` | `#201109` | Libellé et icône sur bouton orange |
| `primarySoft` | `#FFF0E4` | `#3A2518` | Fonds d'éléments actifs et pastilles de marque |
| `success` | `#15803D` | `#4ADE80` | Réussite et montants encaissés |
| `successSoft` | `#EAF6EE` | `#163123` | Fond des indicateurs de réussite |
| `progress` | `#22C55E` | `#22C55E` | Remplissage des barres (jamais de texte dessus) |
| `warning` | `#9A4A07` | `#FBBF24` | En attente, alertes |
| `warningSoft` | `#FCEFD9` | `#33270F` | Fond des pastilles « en attente » |
| `danger` | `#B42318` | `#F87171` | Annulation, erreurs, montants remboursés |
| `dangerSoft` | `#FDE7E7` | `#3A1717` | Fond des pastilles et feuilles d'annulation |

Les contrastes du texte et des boutons sur leurs fonds sont vérifiés automatiquement (`packages/core/test/design/tokens_test.dart`). Les boutons orange utilisent un texte bleu nuit foncé afin de rester lisibles avec les oranges de marque.

Règles : une seule action `primaryAction` par écran ; les états (réussi, attente, erreur) combinent toujours couleur **et**
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
| `AppButton` | plein `primaryAction` · pilule `ink` · contour · texte · danger | normal, appuyé, désactivé, chargement (indicateur, libellé conservé) |
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
