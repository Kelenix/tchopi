# Direction design et performance

> Base du design system (phase 3). Construite à partir de vos références (`docs/design/references/`).
> Objectif : une app **très moderne, belle, fluide et rapide**, y compris sur un Android modeste.
> Les valeurs ci-dessous sont un point de départ ; elles seront figées dans `docs/design/design-system.md`
> et dans le thème Flutter (aucune valeur visuelle en dur dans les écrans).

## 1. Intention

Épuré, **photo d'abord**, grands titres affirmés, cartes arrondies, une seule action principale par écran,
retours visuels immédiats. La beauté vient de la typographie, des photos et de l'espace — pas d'effets coûteux.

## 2. Ce que l'on reprend de chaque référence

| Référence | Éléments repris | Usage dans l'app |
|-----------|-----------------|------------------|
| `ref-1-accueil-cartes-activite` | Carte héro photo + dégradé + chiffre clé et barre de progression ; tuiles arrondies ; liste d'activité groupée par date avec montants colorés ; barre de navigation avec action centrale ronde | Carte « commande en cours » (statut + ETA) sur l'accueil ; historique des transactions ; navigation |
| `ref-2-carte-restaurant` | Carte restaurant : photo, nom en gras, catégorie, rangée d'indicateurs séparés, bouton pilule pleine largeur | Liste des restaurants (indicateurs : temps estimé, frais, distance, ouvert/fermé — **pas de notes ni d'avis**, hors périmètre) |
| `ref-3-formulaire-etapes` | Formulaire par étapes (points + « 1/4 »), grands titres, champs avec icône + chevron, bouton pleine largeur | Demande de colis en 3–4 étapes courtes ; inscription |
| `ref-4-suivi-annulation` | Pastille de statut, frise d'étapes avec icônes, lignes adresse / paiement, **feuille de confirmation** expliquant la conséquence | Suivi de commande ; annulation (« Vous ne serez pas débité » / « Remboursement en cours ») |
| `ref-5-onboarding-liste-detail` | Accueil plein écran photo + titre fort + 2 boutons ; filtres en pastilles ; grandes cartes image ; barre basse fixe prix + action | Écran de bienvenue ; filtres restaurants ; panier fixe « Total · Commander » |

## 3. Jetons de design (proposition initiale — valeurs définitives : `docs/design/design-system.md`)

**Couleurs — thème clair** (contrastes AA vérifiés pour le texte)

| Jeton | Valeur | Usage |
|-------|--------|-------|
| `primary` | `#0B5D3B` vert forêt | Actions principales, éléments actifs (texte blanc 7,9:1) |
| `success` | `#16A34A` vert vif | Succès, montants positifs, action centrale |
| `progress` | `#22C55E` | Remplissage des barres de progression (pas de texte dessus) |
| `ink` | `#0F1412` | Texte principal, bouton pilule noir secondaire |
| `muted` | `#6B7280` | Texte secondaire (4,8:1 sur blanc) |
| `background` | `#F5F6F3` | Fond des écrans |
| `surface` | `#FFFFFF` | Cartes, feuilles |
| `surfaceAlt` | `#EEF1EC` | Champs, pastilles, tuiles d'icône |
| `border` | `#E4E7E2` | Séparateurs |
| `danger` | `#DC2626` | Annulation, montants négatifs, erreurs |
| `warning` | `#D97706` | En attente, alertes |

**Thème sombre** : dérivé des mêmes jetons (fond `#0B0F0D`, surfaces `#151A17`, vert éclairci), suit le réglage du téléphone.

**Typographie** : **Plus Jakarta Sans**, embarquée dans l'app (aucun téléchargement de police au démarrage).
Titres 800 serrés (32 / 26 / 20), corps 15, légendes 13, chiffres et prix en chiffres tabulaires.
Tailles dynamiques respectées (accessibilité).

**Formes** : rayon 12 (pastilles) · 16 (champs) · 24 (cartes) · 28 (feuilles) · pilule (boutons).
Espacements : 4 / 8 / 12 / 16 / 20 / 24 / 32. Une seule ombre douce (y 8, flou 24, noir 6 %).

**Mouvement** : 150–250 ms, décélération douce ; transition partagée de l'image restaurant vers son détail ;
frise de statut animée ; squelettes de chargement ; retour haptique léger sur ajout au panier et confirmations ;
animations réduites si le téléphone le demande.

## 4. Composants signature

Carte héro de commande en cours · tuiles des 2 services (Repas / Colis) · carte restaurant · carte produit avec
bouton « + » et compteur · barre basse fixe (total + action) · frise de statut · feuille de confirmation ·
champ adresse (icône + quartier + repère) · pastilles de filtre · liste d'activité groupée · interrupteur
« En ligne » géant (livreur) · carte d'offre de mission avec compte à rebours (livreur) · squelettes, états vide / erreur / hors ligne.

## 5. Rapidité et fluidité — budgets mesurés (phase 5, appareil Android modeste en mode profile)

| Mesure | Budget |
|--------|--------|
| Démarrage à froid → premier écran utile | < 2 s (milieu de gamme), < 3 s (entrée de gamme 2 Go) |
| Fluidité | 60 i/s sur les parcours critiques, aucune image > 16 ms |
| Réaction au toucher | Retour visuel < 100 ms (actions optimistes : panier, quantités) |
| Données affichées au lancement | Instantanées depuis le cache local, puis rafraîchies |
| Taille de l'APK (par architecture) | < 25 Mo |

**Moyens** : moteur de rendu Impeller ; listes paresseuses et widgets `const` ; reconstructions ciblées (Riverpod `select`) ;
images redimensionnées côté serveur (vignettes WebP via le service d'images de Supabase auto-hébergé) et mises en cache ;
pagination et colonnes utiles uniquement ; cache local des données clés (accueil, menus, historique) ;
préchargement du menu au toucher d'un restaurant ; aucun flou d'arrière-plan ni effet lourd ;
travail coûteux hors du fil d'affichage ; mesures DevTools avant / après chaque optimisation (`docs/performance.md`).

## 6. Prochaine étape

En phase 3 : **maquette interactive des écrans clés** (client, livreur, restaurant) aux couleurs ci-dessus,
publiée pour votre validation **avant** le code des écrans. Nom, logo et photos de marque à fournir
(sinon nom de travail et photos libres de droits de plats locaux).
