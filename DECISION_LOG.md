# Journal de décisions (DECISION_LOG)

> ADR léger. Chaque décision structurante prise par Claude **en autonomie** y est consignée :
> contexte → décision → alternatives écartées → conséquences. Permet de tracer et de contester.
> Format inspiré des Architecture Decision Records. Le plus récent en haut.

---

## ADR-054 — Onboarding après l'inscription (web)

- **Date** : 2026-10-21 · **Statut** : Accepté (demande utilisateur) · **Décideur** : Claude (product-owner)
- **Décision** : un nouveau compte (ni admin, ni établissement, ni livreur) choisit son parcours avant d'entrer dans
  son espace : commander (client), inscrire son restaurant (assistant existant), devenir livreur (candidature sur le
  web, même dossier que le mobile, validée par l'admin). `profiles.onboarded_at` (comptes existants : déjà orientés),
  `complete_onboarding()`, champ `onboarded` dans `my_roles`.
- **Impact** : métier (moyen), technique (faible).

## ADR-053 — Démarrage mobile : animation, connexion obligatoire, accès par téléphone

- **Date** : 2026-10-21 · **Statut** : Accepté (demande utilisateur, remplace la navigation mobile sans compte) ·
  **Décideur** : Claude (mobile, security)
- **Décision** : animation du livreur à moto puis du nom Tchopi à chaque lancement (2,4 s, fondu court si les
  animations sont réduites) pendant que la session est relue ; ensuite accueil (session valide) ou écran d'accès.
  L'écran d'accès s'inspire de Glovo aux couleurs Tchopi : photo et marque en haut, bannière administrable
  (`settings.auth_banner_*`, lue sans compte par `public_auth_config`), « Bienvenue ! », indicatif (+225 par défaut) et
  numéro, code par SMS ou WhatsApp (si `whatsapp_otp_enabled`), Google, puis « Autres méthodes » (e-mail et mot de
  passe). Un seul parcours téléphone (`signInWithOtp`) : connexion si le numéro existe, sinon création puis profil à
  compléter — jamais de doublon (numéro et e-mail uniques côté Auth). Session conservée dans le stockage sécurisé et
  renouvelée automatiquement ; renouvellement impossible ou déconnexion → écran d'accès. Le site web est inchangé.
- **Limite** : le logo officiel n'a toujours pas été fourni en fichier : l'animation utilise un livreur vectoriel et
  le nom Tchopi, à remplacer par le logo dès réception (`assets/brand/`).
- **Impact** : métier (fort : connexion obligatoire), sécurité (moyen).

## ADR-052 — Espace client : photo, sécurité du compte, candidature livreur notifiée

- **Date** : 2026-10-25 · **Statut** : Accepté (demande utilisateur) · **Décideur** : Claude (security, product-owner)
- **Décision** : existant conservé (création, modification, changement d'identifiant, adresses, suppression,
  « Devenir livreur » sur le même compte, statuts pending / approved / rejected, bascule d'espace). Ajouts : photo de
  profil (`profiles.avatar_path`, dossier du titulaire dans `media`) ; « Devenir livreur » aussi dans Mon compte ;
  chaque décision de l'admin sur la candidature est notifiée (déclencheur sur `couriers.status`, motif compris) ; sur
  le web, mot de passe actuel exigé avant de changer d'e-mail ou de mot de passe, suppression du compte ; suppression
  refusée tant qu'une commande du compte est en cours (`anonymize_account`).
- **Impact** : sécurité (moyen), technique (faible).

## ADR-051 — Espace livreur : pièce d'identité ou plaque vérifiée, historique filtré, suppression du profil

- **Date** : 2026-10-24 · **Statut** : Accepté (demande utilisateur) · **Décideur** : Claude (security, backend)
- **Décision** : à pied ou à vélo (sans plaque), pièce d'identité obligatoire ; sinon immatriculation. Vérification
  **automatique de forme** contre le référentiel `identity_formats` (CNI biométrique `CI` + 9-10 chiffres, ancienne
  CNI `C` + 10 chiffres, passeport `00AA00000`, carte de résident, plaque `1234 AB 01`, provisoire `WW`), dans l'app
  et par le serveur (`submit_courier_profile`). Les formats sont des données modifiables par un admin, sans
  déploiement. Changer de zone, véhicule, plaque ou pièce repasse le dossier en validation. Historique des livraisons
  par `courier_deliveries` (période à l'heure d'Abidjan, statut, numéro, pages). Le livreur supprime son profil
  (`delete_courier_profile`) sans mission en cours ni espèces dues ; son compte client et l'historique restent.
- **Limite** : aucun service public ivoirien de vérification en ligne n'est utilisé : la forme est contrôlée
  automatiquement, l'authenticité (pièce, photo) reste vérifiée par l'admin à la validation du dossier.
- **Impact** : sécurité (moyen), métier (moyen).

## ADR-050 — Affiliation des livreurs gérée par l'établissement

- **Date** : 2026-10-23 · **Statut** : Accepté (demande utilisateur) · **Décideur** : Claude (product-owner, backend)
- **Décision** : `restaurant_couriers` porte un statut (`pending`, `approved`, `rejected`, `suspended`, `ended`), une
  ligne par couple (pas de doublon, historique dans le journal d'audit). Le livreur **validé par l'admin** postule
  (`courier_request_affiliation`), le restaurant accepte, refuse, suspend ou met fin (`restaurant_set_affiliation`,
  transitions contrôlées, livreur prévenu). Seules les affiliations approuvées comptent pour l'attribution ; un
  livreur peut être affilié à plusieurs restaurants. L'écran admin mobile existant reste compatible.
- **Impact** : métier (moyen), sécurité (un restaurant ne voit et ne modifie que ses affiliations).

## ADR-049 — Espace Établissement : profil complet, périodes, dialogues communs

- **Date** : 2026-10-23 · **Statut** : Accepté (demande utilisateur) · **Décideur** : Claude (product-owner, frontend)
- **Décision** : un compte établissement n'a plus l'espace Client (web et mobile). Les gérants modifient nom,
  adresse et position dans le rayon de leur zone (`restaurant_update_profile`), logo et couverture ; ils peuvent
  désactiver l'établissement s'il n'a pas de commande en cours (`restaurant_request_deactivation`, admins prévenus,
  suppression définitive réservée à l'admin et seulement sans commande). Indicateurs, graphiques et tableaux viennent
  d'une seule fonction serveur (`restaurant_stats`) pour la période choisie ; l'historique des commandes est filtré et
  paginé par le serveur. Toutes les boîtes natives (`confirm`, `prompt`) du site sont remplacées par un composant
  unique (`components/dialog.tsx` : `<dialog>` modal, Échap, focus, chargement, erreur dans la boîte).
- **Impact** : métier (moyen), technique (faible).

## ADR-048 — Séparation stricte des rôles, actions d'administration complètes

- **Date** : 2026-10-22 · **Statut** : Accepté (demande utilisateur) · **Décideur** : Claude (product-owner, security)
- **Décision** : sur le web, un compte admin ne voit que l'administration et son profil (plus d'« Activité client » ni
  d'« Activité livreur » ; les autres pages le renvoient vers l'administration), comme l'app mobile. Ajouts : modifier
  le nom d'un compte, le supprimer (`admin_delete_account` : ni soi-même, ni un admin, ni un compte avec une commande
  en cours ; profil anonymisé, historique conservé, connexion supprimée par `admin-users`), supprimer un restaurant
  sans commande (`admin_delete_restaurant`, sinon le désactiver), gérer la carte de n'importe quel restaurant.
- **Alternatives écartées** : suppression physique des comptes (casserait l'historique des commandes et la compta).
- **Impact** : sécurité (moyen), métier (faible).

## ADR-047 — Statistiques sur données réelles ; « Espèces à reverser » conservé

- **Date** : 2026-10-22 · **Statut** : Accepté · **Décideur** : Claude (data, backend)
- **Contexte** : « Espèces à reverser » = espèces encaissées par les livreurs à la livraison (`cash_ledger`) moins
  leurs versements : argent réellement dû à la plateforme, qui paie ensuite restaurants et livreurs.
- **Décision** : conservé comme suivi financier, déplacé de « Livreurs » vers « Paiements ». Tableau de bord
  (`admin_dashboard`) et paiements (`admin_payment_stats`) calculés par le serveur, période libre (jour, 7 j, 30 j,
  12 mois, dates choisies), série complétée de zéros, répartitions par ville et par moyen de paiement. Statut d'un
  paiement lu sur la commande (espèces comprises) : réussi, en attente, échoué (jamais payé puis annulé), remboursé.
- **Impact** : métier (moyen), technique (faible).

## ADR-046 — Frais de livraison sur la distance routière

- **Date** : 2026-10-22 · **Statut** : Accepté (demande utilisateur) · **Décideur** : Claude (backend)
- **Décision** : frais = 500 F + 100 F × km par la route (grille modifiable par zone dans l'admin), arrondis à 5 F,
  entre minimum et maximum. La base interroge le serveur d'itinéraires OSRM du VPS (`private.road_distance_m`, extension
  `http`, délai 2,5 s) à chaque devis et à la commande ; distance et frais enregistrés avec la commande. Si le serveur ne
  répond pas : vol d'oiseau × détour, signalé « distance estimée » au client.
- **Alternatives écartées** : calcul côté app (falsifiable) ; service de cartographie payant.
- **Impact** : financier (moyen : nouveaux tarifs pour toutes les zones), technique (réversible).

## ADR-045 — Emails par Resend, connexion avec Google

- **Date** : 2026-10-21 · **Statut** : Accepté (demande utilisateur) · **Décideur** : Claude (backend, security)
- **Décision** : Supabase garde la génération et la vérification des codes à 6 chiffres ; Resend envoie les emails en
  SMTP (`smtp.resend.com:465`, clé API saisie par `vps.ps1 email`, jamais dans le code). Modèles en français servis par
  le site de l'API (`/email-templates/`). Connexion Google (OAuth Supabase, `vps.ps1 google`), retour vers
  `https://tchopi.com` (`SITE_URL`, `ADDITIONAL_REDIRECT_URLS`).
- **Alternatives écartées** : API Resend appelée par une fonction (« hook » d'envoi) : plus de code pour le même
  résultat ; SMTP de la messagerie Hostinger (délivrabilité moindre, pas de suivi).
- **Conséquences** : domaine `tchopi.com` à vérifier chez Resend (DNS) ; Google dans l'app mobile plus tard.
- **Impact** : sécurité (moyen), technique (réversible).

## ADR-044 — Inscription des restaurants en libre-service

- **Date** : 2026-10-21 · **Statut** : Accepté (demande utilisateur) · **Décideur** : Claude (product-owner, backend)
- **Décision** : un compte crée son restaurant (`register_restaurant`) : invisible des clients
  (`review_status = pending`, inactif) jusqu'à la validation de l'admin (`admin_review_restaurant`, commission
  fixée), qui prévient le gérant. Le gérant accède tout de suite à son espace pour préparer sa carte. Une demande en
  attente à la fois par compte.
- **Alternatives écartées** : formulaire de candidature traité à la main (création par l'admin) : plus lent, conservé
  pour les demandes déjà reçues.
- **Impact** : fonctionnel (moyen), sécurité (validation obligatoire avant toute vente).

## ADR-043 — Plateforme spécialisée dans la restauration

- **Date** : 2026-10-21 · **Statut** : Accepté (demande utilisateur) · **Décideur** : utilisateur
- **Décision** : service colis mis en pause (`settings.parcels_enabled = false`, refus côté serveur ; option `PARCELS`
  des applications) et magasins retirés des interfaces. Rien n'est supprimé : réactivable sans migration.
- **Impact** : fonctionnel (fort, choisi), technique (réversible).

---

## ADR-042 — Backend commun étendu pour la plateforme web

- **Date** : 2026-10-20
- **Statut** : Accepté (mode AUTONOME ; plan `../tchopi-web/docs/plan-de-realisation.md`)
- **Décideur** : Claude (rôles : database-architect, security-engineer)
- **Contexte** : le site `tchopi-web` partage ce backend ; il lui faut un catalogue lisible sans compte, des magasins,
  des options de produits et les candidatures « devenir partenaire ».
- **Décision** (migration `20261020120000_web_platform`) :
  - **Magasins** : `restaurants.kind` (`restaurant` / `shop`), même circuit de commande ; `admin_save_restaurant`
    accepte `p_kind` (absent depuis le mobile : type inchangé).
  - **Options** : groupes (`min_choices`, `max_choices`) et choix (`price_delta`) ; le devis recalcule le prix et
    signale `options_required` / `option_unavailable` ; la ligne de commande garde les choix (`options`) et les ajoute
    à son libellé, donc l'app mobile actuelle les affiche déjà. Le mobile ne sait pas encore choisir d'options : il
    invite à commander ces produits sur le site.
  - **Catalogue public** : fonctions en lecture seule pour les visiteurs (`public_zones`, `public_establishments`,
    `public_featured_products`, `public_establishment`, `public_search`), colonnes sûres seulement ; les tables restent
    fermées à `anon`.
  - **Candidatures** : `partner_applications`, envoi sans compte (une en attente par numéro, 30 par heure),
    examen par l'admin.
  - **Retour de paiement sur le site** : `payments-create` accepte `return_to`, limité aux pages de `WEB_ORIGIN`
    (`https://tchopi.com` par défaut) ; sans lui, la page de retour de l'app reste utilisée.
- **Alternatives écartées** : ouvrir les tables aux visiteurs (exposerait commission et téléphones) ; API propre au
  web (deux logiques métier).
- **Impact** : sécurité (moyen, couvert par `web_platform.test.sql`), technique (réversible).

---

## ADR-041 — Autorisation des notifications demandée à l'ouverture

- **Date** : 2026-10-20
- **Statut** : Accepté (demande utilisateur ; remplace la demande « au premier moment utile » de NOT-04)
- **Décideur** : Claude (rôles : flutter-engineer, product-owner)
- **Contexte** : l'autorisation n'était demandée qu'après une commande, au passage en ligne du livreur ou sur l'écran
  des commandes du restaurant, précédée d'une explication ; à l'ouverture de l'app, rien n'était demandé.
- **Décision** : dès l'ouverture, une fois connecté, si l'autorisation n'a jamais été demandée, la fenêtre du système
  s'affiche (Android 13 et plus, iPhone) ; l'appareil est enregistré dès qu'elle est accordée. Les explications
  propres à chaque écran sont retirées ; le rappel « Notifications désactivées » du suivi reste.
- **Alternatives écartées** : explication de l'app avant la fenêtre du système (étape de plus, refusée à l'usage).
- **Conséquences** : Android 12 et moins n'affichent pas de fenêtre (notifications permises d'office).
- **Impact** : fonctionnel (faible), technique (réversible).

---

## ADR-040 — Admin sur alerte seulement ; restaurant prévenu de la livraison

- **Date** : 2026-10-20
- **Statut** : Accepté (demande utilisateur, option « Alertes seulement » choisie)
- **Décideur** : Claude (rôles : product-owner, backend-engineer, flutter-engineer)
- **Contexte** : l'admin n'a pas besoin de suivre toutes les commandes ; le restaurant ne savait pas quand sa
  commande était remise au client.
- **Décision** :
  - **Commandes à traiter** (ex-« Commandes en cours ») : l'admin ne voit que les commandes en alerte (sans livreur
    après le délai, restaurant sans réponse, code bloqué, problème signalé ou échec). Il garde l'attribution
    manuelle, l'annulation et la confirmation sans code (cahier des charges § D.4-5). Les remboursements restent
    dans Transactions.
  - **Restaurant** : notification « Commande livrée » (type `order_delivered`) à chaque membre quand le livreur saisit
    le code ou que l'admin confirme la livraison ; message à l'écran des commandes s'il est ouvert.
- **Alternatives écartées** : retirer toute supervision (plus d'attribution manuelle ni de déblocage) ; garder la
  liste sans le détail des commandes.
- **Conséquences** : la notification sur le téléphone attend le projet Firebase (`docs/manual-tasks.md` § 8) ; d'ici
  là, le restaurant la voit si l'écran des commandes est ouvert.
- **Impact** : fonctionnel (faible), technique (réversible).

---

## ADR-039 — Paiements prêts pour les comptes marchands ; cartographie par besoin

- **Date** : 2026-10-20
- **Statut** : Accepté (demande utilisateur)
- **Décideur** : Claude (rôles : backend-engineer, security-engineer, mobile-architect)
- **Contexte** : préparer Stripe et le Mobile Money pour qu'il ne reste qu'à saisir les identifiants marchands ;
  évaluer la carte en Côte d'Ivoire ; bouton « Ouvrir la navigation » pour le livreur. Le prestataire « ONGAL »
  cité n'existe pas sous ce nom : le lien fourni est celui de **nyole** (ADR-028), qui est conservé.
- **Décision** :
  - **Remboursements signalés par le prestataire** : statut nyole « REFUNDED » (webhook `payment.updated`, remboursement
    fait par leur support) appliqué à la transaction et à la commande ; s'il n'avait pas été demandé, admin alerté
    (journal d'audit). Remboursement Stripe refusé après coup (`refund.failed`, `refund.updated`, objet relu chez
    Stripe) : commande de nouveau « à rembourser », admin alerté. Événements sans effet s'ils sont rejoués.
  - **Saisie des clés** : `.\vps.ps1 cle-paiement <NOM>` (saisie masquée sur le PC, format vérifié, valeur lue
    sur l'entrée standard du serveur, jamais en argument) ; les fonctions de paiement sont relancées.
  - **Cartographie** (évaluation : `docs/cartographie.md`) : affichage OpenFreeMap, **recherche de lieux Photon**
    (OpenStreetMap, limitée à la Côte d'Ivoire, loupe sur les cartes de sélection), itinéraires OSRM hébergés,
    **navigation dans l'application du téléphone** (Android : choix parmi les applis installées via `geo:` ; iPhone :
    Plans ; sinon Google Maps). Couverture OSM mesurée suffisante (quartiers, carrefours, commerces à Abidjan).
- **Alternatives écartées** : Google Maps Platform (compte de facturation, recherche 2,83 $/1000 et itinéraires
  5 $/1000 au-delà de 10 000/mois, navigation intégrée 25 $/1000) tant que la couverture OSM suffit ; navigation
  intégrée dans l'app ; recherche Nominatim (moins tolérante que Photon : 7/9 contre 8/9 lieux trouvés).
- **Conséquences** : paiements **non opérationnels** tant que les tests réels de `docs/mise-en-service.md` § 5 ne sont pas
  faits ; Photon public à usage modéré (à héberger ou remplacer selon le volume, `PLACES_SEARCH_URL`).
- **Impact** : financier (moyen), sécurité (moyen), technique (réversible).

---

## ADR-038 — Thème sombre, villes et quartiers, carte de livraison

- **Date** : 2026-10-20
- **Statut** : Accepté (demande utilisateur ; remplace ADR-019 « clair uniquement »)
- **Décideur** : Claude (rôles : mobile-ui-designer, mobile-architect)
- **Contexte** : refonte demandée : choix de ville compact couvrant toute la Côte d'Ivoire, quartiers suggérés,
  carte conforme à la maquette (trajet, retrait, destination, livreur orienté et animé), design harmonisé, thèmes
  clair et sombre mémorisés.
- **Décision** :
  - **Thèmes** : jetons `AppTokens.dark` repris de la maquette ; sélecteur « Apparence » (Auto / Clair / Sombre)
    dans Mon compte, mémorisé sur l'appareil (`shared_preferences`). Thème des menus, listes déroulantes, fenêtres,
    info-bulles, cases et sélection de texte dérivé des jetons ; contrastes AA testés dans les deux thèmes.
  - **Villes** : liste embarquée (`places_reference.dart`) des chefs-lieux de département et principales villes
    (Wikipédia, sans doublons), villes desservies en tête ; feuille de hauteur fixe (70 % de l'écran) avec recherche
    sans accents, casse ni séparateurs (« san ped » → San-Pédro).
  - **Quartiers** : suggestions par ville (Abidjan et 10 grandes villes), discrètes sous le champ ; la ville vient
    de la zone qui contient l'épingle ; saisie libre conservée.
  - **Carte** (`DeliveryMap`, suivi client et mission livreur) : trajet routier OSRM (`ROUTING_URL`, ligne droite
    si indisponible), calculé une fois par trajet ; retrait en carré foncé
    (restaurant ou colis), destination en rond vert, livreur avec l'icône de son véhicule, pulsation, flèche de
    direction (seulement au-delà de 5 m) et glissement animé de 0,9 s ; seule la couche du livreur se redessine,
    la carte n'est plus reconstruite à chaque étape (recadrage). Fond « positron » en clair, « dark » en sombre
    (OpenFreeMap), chacun avec son identifiant : sans lui, la bibliothèque mélangeait les deux styles en cache.
  - **Trajets hébergés** (2026-10-20, remplace le service public de démonstration, sans garantie ni usage
    commercial) : OSRM v6 (`tchopi-routing`, `infra/compose.yml`) sur le VPS, carte OpenStreetMap de Côte d'Ivoire
    (Geofabrik) préparée par `server.sh` (profil voiture, valable pour les motos ; algorithme MLD) au premier
    déploiement puis chaque dimanche (cron), dans un dossier neuf qui ne remplace l'ancien qu'une fois complet.
    Public par le nginx de l'API, sur le même domaine (pas de DNS ni de certificat en plus) : seul
    `/route/v1/driving/<2 points>` est ouvert (`infra/nginx-routing.conf`). `ROUTING_URL` vaut par défaut
    `https://api.tchopi.com` dans `Env`, comme `SUPABASE_URL` : la CI et les builds sans `--dart-define` l'utilisent.
- **Alternatives écartées** : API de lieux (Google Places : clé et coût, pas de quartiers fiables en CI) ; style
  « liberty » (chargé, peu lisible sous le trajet) ; sous-domaine pour les trajets (DNS et certificat en plus, sans
  gain) ; profil moto dédié (absent d'OSRM, écarts négligeables en ville) ; Valhalla ou GraphHopper (plus lourds
  pour un VPS partagé de 4 Go).
- **Conséquences** : préparation de la carte ≈ 1,2 Go de mémoire et 2 à 3 min sur le VPS (premier déploiement,
  puis chaque dimanche à 4 h), service ≈ 300 Mo ; trajets limités à la Côte d'Ivoire. La liste des quartiers s'enrichit
  dans `places_reference.dart`.
- **Impact** : technique et produit (réversible).

---

## ADR-037 — Prise en charge : commande sans livreur, offre à « Prête », livreurs affiliés

- **Date** : 2026-10-19
- **Statut** : Accepté (demande utilisateur ; remplace en partie ADR-023)
- **Décideur** : Utilisateur ; mise en œuvre Claude (rôles : backend-engineer, flutter-engineer)
- **Contexte** : Le client ne pouvait pas commander sans livreur en ligne ; la recherche démarrait dès « En
  préparation », par offres de 45 s au plus proche, et un repas était annulé après 30 min sans livreur. L'utilisateur
  veut le fonctionnement des grandes plateformes (Glovo) avec des livreurs affiliés aux restaurants.
- **Décision** :
  - Commande et envoi de colis possibles **sans livreur en ligne** (information seulement).
  - Un repas est proposé aux livreurs quand le restaurant le marque **« Prête »** (un colis dès sa confirmation),
    **à tous les livreurs éligibles à la fois**, sans limite de temps ; le **premier qui accepte** l'obtient
    (verrou de la commande), les autres offres sont retirées. Statut « Livreur en route vers le restaurant ».
  - Éligibles : validés, en ligne, position récente, sans mission en cours, moyen adapté au colis ; **affiliés au
    restaurant** s'il en a (choisis par l'admin, table `restaurant_couriers`), sinon livreurs de la zone.
  - **Attente** : la commande reste proposée ; tout livreur qui devient disponible la reçoit (tâche toutes les
    10 s) ; alerte au restaurant, au client et à l'admin après le délai réglé ; un repas prêt n'est jamais annulé
    automatiquement (seuls les colis le sont).
  - **Désistement** avant le retrait : le repas redevient « Prête » et est reproposé (pas à celui qui s'est désisté).
  - Retrait identifié par le **numéro de commande** ; remise confirmée par le restaurant ou le livreur ; « En route »
    seulement après le retrait ; livraison confirmée par le code du client.
- **Alternatives écartées** : offre au plus proche avec expiration (commande bloquée si personne ne répond) ;
  recherche dès la préparation (livreur immobilisé pendant la cuisson) ; code de retrait séparé (le numéro suffit).
- **Conséquences** : le réglage « délai d'une offre » n'est plus utilisé ; la notification push de nouvelle
  commande attend Firebase (tâche n° 8), l'app ouverte l'affiche en direct.
- **Impact** : métier (élevé), réversible.

---

## ADR-036 — Villes desservies : principales villes de Côte d'Ivoire

- **Date** : 2026-10-19
- **Statut** : Accepté (demande utilisateur)
- **Décideur** : Utilisateur ; mise en œuvre Claude (rôle : database-architect)
- **Contexte** : Seule Abidjan existait ; l'app doit couvrir le pays.
- **Décision** : 10 villes ajoutées en données de départ (migration `20261019170000_cities.sql`) : Bouaké,
  Yamoussoukro, San-Pédro, Daloa, Korhogo, Man, Gagnoa, Divo, Abengourou, Grand-Bassam ; chacune une zone (centre,
  rayon 6 à 12 km) avec les tarifs d'Abidjan plafonnés plus bas (2 000 F repas, 2 500 F colis). Tout reste modifiable
  ou désactivable dans l'Administration (Zones). Textes « Abidjan » de l'accueil et de « Devenir livreur » rendus
  généraux.
- **Conséquences** : une ville n'a de restaurants et de livreurs que si l'admin en crée ou en valide dans sa zone.
- **Impact** : métier (moyen), réversible.

---

## ADR-035 — Déploiement continu du serveur par GitHub Actions

- **Date** : 2026-10-19
- **Statut** : Accepté (demande utilisateur ; lève le report d'ADR-031)
- **Décideur** : Utilisateur ; mise en œuvre Claude (rôle : release-manager / security)
- **Contexte** : L'utilisateur attend que chaque push sur `main` mette le serveur à jour. ADR-031 avait reporté le
  déploiement continu après un premier déploiement manuel validé (fait) ; la CI ne faisait que tester et compiler.
- **Décision** :
  - Job « Déploiement du serveur » dans `ci.yml`, sur `main` uniquement (push ou relance manuelle), **après** les
    tests Flutter et pgTAP ; même envoi que `vps.ps1 deployer` (version commitée de `infra/` et `supabase/`, puis
    `server.sh deploy`) ; un seul déploiement à la fois, jamais interrompu par un nouveau push.
  - **Clé SSH réservée à GitHub** (différente de celle des PC), **empreinte du VPS vérifiée** (`VPS_KNOWN_HOSTS`,
    pas d'acceptation à l'aveugle) ; secrets posés par `vps.ps1 ci` depuis un PC qui a accès au VPS, sans passer par
    le chat ni le code.
  - Sans secrets, le job avertit « Serveur non mis à jour » au lieu d'échouer.
- **Alternatives écartées** : réutiliser la clé d'un PC (révocation impossible sans couper ce PC) ; webhook ou agent
  sur le VPS (service supplémentaire à exposer et maintenir).
- **Conséquences** : tout commit sur `main` touchant la base part en production après les tests ; les migrations
  doivent rester compatibles avec l'app déjà installée. La publication de l'app (APK, web) reste hors de ce job.
- **Impact** : exploitation / sécurité (moyen), réversible (retirer la clé `tchopi-github` du VPS).

---

## ADR-034 — Carte bancaire par Stripe Checkout, remboursements automatiques (Inc-12)

- **Date** : 2026-10-19
- **Statut** : Accepté
- **Décideur** : Claude (rôles : backend-engineer, flutter-engineer, security-engineer)
- **Contexte** : Story PAY-04 (D-5 : cartes via Stripe, société dans un pays compatible). Le plan prévoyait la feuille
  de paiement native ; ADR-027 avait reporté le remboursement automatique des cartes à cet incrément.
- **Décision** :
  - **Stripe Checkout (page hébergée)** plutôt que la feuille native (SDK `flutter_stripe`) : 3-D Secure, refus et
    nouvel essai gérés par Stripe sur sa page, aucun SDK dans l'app (APK sous 25 Mo), fonctionne aussi en web.
    Montant en francs CFA (devise sans décimales chez Stripe), carte uniquement.
  - **Même circuit que Mobile Money** : couche commune aux fournisseurs dans les Edge Functions (`payments.ts`,
    `signature.ts`) ; `begin_online_payment` remplace `begin_mobile_money` ; webhook `payments-webhook-stripe`
    (signature HMAC, 5 min) puis statut **relu chez Stripe** avant toute écriture ; panneau de paiement commun dans
    l'app.
  - **Expiration** : session Stripe de 30 min (minimum imposé), arrondie aux 10 min pour qu'un double envoi garde
    la même clé d'idempotence ; la commande, elle, s'annule après le délai réglé (15 min) : un paiement tardif est
    remboursé automatiquement.
  - **Remboursement automatique des cartes** : dès qu'une commande payée par carte est « à rembourser » (annulation,
    refus, décision de l'admin), la tâche planifiée appelle `payments-refund` (clé de service dans le coffre de la
    base) ; Stripe rembourse tout, une seule fois (idempotence) ; nouvel essai après 10 min en cas d'échec.
    Mobile Money reste remboursé à la main (nyole n'a pas d'API de remboursement).
  - Page `payments-return` affichée après le paiement : le client revient dans l'app, qui suit le statut en direct.
- **Alternatives écartées** : feuille native `flutter_stripe` (SDK lourd, configuration Android, pas de web) ;
  remboursement déclenché par l'admin seulement (délai pour le client) ; expiration de la session Stripe à
  l'annulation de la commande (appel serveur supplémentaire pour un cas couvert par le remboursement).
- **Conséquences** : clés `STRIPE_SECRET_KEY` et `STRIPE_WEBHOOK_SECRET` à saisir sur le serveur ; webhook Stripe à
  déclarer (tâche manuelle n° 1) ; frais Stripe supportés par la plateforme, comme ceux de nyole.
- **Impact** : financier (moyen), technique (moyen), réversible.

---

## ADR-033 — Données de départ et carte moderne gratuite

- **Date** : 2026-10-19
- **Statut** : Accepté (demande utilisateur ; complète ADR-019)
- **Décideur** : Utilisateur (restaurants de démonstration en ligne ; pas de service payant pour la carte « pour le
  moment ») ; mise en œuvre Claude (rôle : database-architect / flutter-engineer)
- **Contexte** : Le serveur en ligne était vide (aucune ville : profil et adresses impossibles) et la carte OpenStreetMap
  classique jugée « vide, vieille, pas moderne ». Google Maps exige un compte Google Cloud avec carte bancaire (web
  payant au-delà de 10 000 affichages par mois) ; CARTO exige désormais une clé.
- **Décision** :
  - Migration `20261019150000_default_zone` : zone « Abidjan — agglomération » et tarifs de départ sur tous les serveurs
    (modifiables dans l'Administration).
  - Restaurants de démonstration dans `supabase/demo.sql` (seed local, puis `vps.ps1 demo` sur le serveur, photos dans
    le bucket « media ») ; supprimables depuis l'Administration avant l'ouverture au public.
  - Carte : style vectoriel **OpenFreeMap « liberty »** (gratuit, sans clé ni compte, usage commercial permis) via
    `vector_map_tiles` 9 (bêta, la version stable ne gère pas `latlong2` 0.10) ; repli automatique sur les tuiles
    OpenStreetMap si le style ne se charge pas. Fond commun `lib/shared/map_tiles.dart` pour les trois cartes.
- **Alternatives écartées** : Google Maps maintenant (compte de facturation refusé pour l'instant, tâche 7) ; CARTO
  (clé obligatoire) ; MapLibre natif (refonte des trois cartes et des tests).
- **Conséquences** : rendu vectoriel calculé par l'app (à surveiller sur les téléphones d'entrée de gamme) ;
  dépendance bêta à revoir à la sortie de la version stable.
- **Impact** : produit / design (fort), technique (moyen).

---

## ADR-032 — App à la racine du dépôt, serveur en ligne par défaut

- **Date** : 2026-10-19
- **Statut** : Accepté (demande utilisateur ; remplace, dans ADR-031, `env/prod.json`, `vps.ps1 config`, `run.ps1`
  et `phone.ps1`)
- **Décideur** : Utilisateur ; mise en œuvre Claude (rôle : mobile-architect / flutter-engineer)
- **Contexte** : Le back-end est en ligne (https://api.tchopi.com). L'utilisateur veut un `flutter run` normal, à la
  racine, sans script ni fichier de configuration ; le dossier `apps/mobile` (hérité des 3 apps d'origine, ADR-016)
  n'a plus de raison d'être avec une seule app.
- **Décision** :
  - L'app est à la racine (`lib/`, `test/`, `android/`, `ios/`, `web/`, paquet `tchopi`), racine de l'espace de
    travail Dart avec `packages/core`.
  - `Env` (packages/core) a pour valeurs par défaut l'URL du serveur en ligne et sa clé `anon` (publique par
    conception : présente dans toute app publiée ; la sécurité repose sur la RLS). Supabase du PC :
    `--dart-define-from-file=env/local.json`.
  - Supprimés : `run.ps1`, `phone.ps1`, `docs/installer-sur-telephone.md` (mode Wi-Fi), `vps.ps1 config`.
- **Alternatives écartées** : garder `apps/mobile` avec des scripts de lancement (jugé incompréhensible par
  l'utilisateur) ; Supabase du PC par défaut (le développement courant se fait sur le serveur en ligne).
- **Conséquences** : une réinstallation complète du serveur impose de reporter la nouvelle clé `anon` dans `env.dart` ;
  les tests contre le serveur en ligne créent de vraies données (comptes de test à nettoyer avant la production).
- **Impact** : technique (moyen), expérience de développement (fort).

---

## ADR-031 — Déploiement sur le VPS : pilote fermé, piloté depuis le PC

- **Date** : 2026-10-19
- **Statut** : Accepté (met en œuvre ADR-009)
- **Décideur** : Claude (rôle : release / security), à la demande de l'utilisateur (utiliser l'APK partout)
- **Contexte** : L'utilisateur veut utiliser l'app hors de chez lui avant d'avoir un fournisseur SMS, un SMTP ou
  Firebase. Le VPS (Hostinger KVM 1 : 1 vCPU, 4 Go, swap 2 Go) est **partagé** avec d'autres sites : nginx de l'hôte
  sur 80/443 (certbot), ports 3000-3003, 3100-3101, 5432, 5433, 8000 pris, ufw déjà limité à 22/80/443, deux autres
  projets en Supabase allégé (sans Studio ni pooler).
- **Décision** :
  - Supabase installé par le script officiel (`setup.sh`), version figée `self-hosted/v0.8.3` (Postgres 17, passerelle
    Envoy) ; secrets générés sur le VPS, jamais copiés sur le PC (sauf la clé publique `anon` → `env/prod.json`).
  - **Pile allégée** (`infra/compose.yml`) : sans pooler ni imgproxy (inutiles ici) ; Studio et postgres-meta en profil,
    démarrés seulement par `vps.ps1 studio` (tunnel SSH). Projet `tchopi`, conteneurs `tchopi-*`, passerelle sur
    `127.0.0.1:8010`.
  - **nginx de l'hôte** (`infra/nginx.conf`, convention des autres sites) + certbot : seuls les chemins de l'API sont
    publics sur `api.tchopi.com` ; `tchopi.com` reste pour l'app web. Pare-feu et SSH du serveur non modifiés.
  - **Pilote fermé** : fournisseur SMS factice (comme en local) + `SMS_TEST_OTP` ; seuls les numéros autorisés
    (`vps.ps1 testeur`, un code par numéro) peuvent s'inscrire. Inscription email désactivée tant que le SMTP manque.
  - `vps.ps1` (PC) → `infra/server.sh` (VPS) : installation, sauvegardes quotidiennes 14 jours, déploiement de la
    version **commitée** (`git archive`), migrations appliquées une seule fois (table
    `supabase_migrations.schema_migrations`, comme la CLI), fonctions copiées avec une import map commune (le routeur
    officiel n'en lit qu'une), testeurs, admin, Studio. Une clé SSH par PC ; `vps.ps1 config` recrée `env/prod.json`.
    `run.ps1` et `phone.ps1` reliés par défaut au serveur en ligne (`-Local` : Supabase du PC).
- **Alternatives écartées** : Caddy (80/443 déjà tenus par nginx) ; pile officielle complète (mémoire du VPS
  partagé) ; confirmation automatique des inscriptions (n'importe qui pourrait prendre le numéro d'un autre) ; Studio
  public derrière un mot de passe (surface d'attaque) ; déploiement continu GitHub Actions tout de suite (secrets SSH
  dans GitHub ; à ajouter une fois le premier déploiement manuel validé).
- **Conséquences** : chaque testeur doit être autorisé ; copie des sauvegardes hors du VPS manuelle pour l'instant ;
  restent à faire : déploiement continu, supervision externe, SMTP / SMS / Firebase (tâches 5, 6, 8).
- **Impact** : exploitation / sécurité (élevé).

---

## ADR-030 — Phase 5 : cache des photos, index, charge sans k6

- **Date** : 2026-10-19
- **Statut** : Accepté
- **Décideur** : Claude (rôles : performance-engineer, qa-engineer)
- **Contexte** : Budgets de `docs/design/direction.md` §5 (APK < 25 Mo, fluidité sur Android modeste, données
  mobiles coûteuses) ; plan de test §9 ; le rôle QA prévoit un test de charge k6.
- **Décision** :
  - Photos via `cached_network_image` dans `MediaImage` : décodage à la taille affichée et cache disque.
  - Index sur les 9 clés étrangères qui n'en avaient pas.
  - Test de charge écrit en Node (`tests/load/backend.mjs`), déjà installé, au lieu de k6 : mêmes profils
    (smoke, charge, stress) et seuils (p95, taux d'échec), sans outil à télécharger.
  - Tests « petit écran, police + 30 % » sur les écrans clés, avec la vraie police chargée dans les tests de l'app.
  - Listes non converties en `ListView.builder` : elles restent sous 200 éléments et Flutter ne construit que les
    éléments visibles ; aucune mesure ne justifie la réécriture.
- **Alternatives écartées** : `Image.network` avec `cacheWidth` seul (pas de cache disque : photos retéléchargées à
  chaque ouverture) ; k6 (installation supplémentaire).
- **Conséquences** : une dépendance de plus (cache d'images) ; démarrage et fluidité restent à mesurer sur un vrai
  téléphone en mode profile (`docs/performance.md`).
- **Impact** : technique (faible), réversible.

---

## ADR-029 — L'Admin n'est plus un espace à choisir ; installation sur téléphone

- **Date** : 2026-10-19
- **Statut** : Accepté (demande utilisateur, complète ADR-016)
- **Décideur** : Utilisateur ; mise en œuvre Claude (rôle : mobile-architect / flutter-engineer)
- **Contexte** : Avec un compte de test cumulant les rôles, « Changer d'espace » proposait aussi l'Administration.
  L'utilisateur veut qu'on n'accède à l'Admin qu'avec des identifiants admin ; un utilisateur doit en revanche
  pouvoir rester Client et devenir Livreur ou gérant de Restaurant.
- **Décision** :
  - « Changer d'espace » ne propose que Client, Livreur et Restaurant (selon les droits).
  - Un compte admin arrive directement dans l'Administration et n'en sort pas : seuls les écrans Admin et
    « Mon compte » lui sont ouverts ; ni changement d'espace, ni commandes, ni adresses dans son compte.
  - Les entrées de « Mon compte » peuvent désormais dépendre des droits (`AccountLink.visible`).
  - Installation sur téléphone : script `phone.ps1` (APK release relié au Supabase du PC par le Wi-Fi) et guide
    `docs/installer-sur-telephone.md` ; tests en 4G et par des tiers : VPS + Google Play « Test interne ».
- **Alternatives écartées** : un espace par compte pour tous les rôles (refusé par l'utilisateur : un client doit
  pouvoir devenir livreur ou restaurateur) ; app d'administration séparée (deux apps à maintenir, ADR-016).
- **Conséquences** : l'administrateur a besoin d'un compte distinct pour commander ou livrer. Les droits restent
  vérifiés par le serveur (RLS) ; ce changement ne concerne que la navigation.
- **Impact** : fonctionnel (faible), réversible.

---

## ADR-028 — Mobile Money par nyole (Inc-11)

- **Date** : 2026-10-19
- **Statut** : Accepté
- **Décideur** : utilisateur (fournisseur nyole) ; Claude (rôle : backend-engineer / flutter-engineer) pour l'intégration
- **Contexte** : Stories PAY-03, PAY-05. nyole (https://nyole.com/docs/) encaisse Orange Money, MTN MoMo, Wave et
  Moov en Côte d'Ivoire par une **page de paiement hébergée** ; webhooks signés HMAC-SHA256 ; statut consultable par
  API ; mode test (clés `af_test_…`) ; remboursements uniquement via leur support ; 5 % par paiement réussi.
- **Décision** :
  - **Un seul moyen « Mobile Money »** dans l'app ; l'opérateur et le numéro se choisissent sur la page nyole
    (numéro du client prérempli). Écart assumé avec PAY-03 (choix de l'opérateur dans l'app) : nyole ne l'expose pas.
  - **Commande en `awaiting_payment`** à la création, transaction « en attente » ; rien n'est transmis au restaurant
    ni aux livreurs avant confirmation. Le délai de réponse du restaurant part de la transmission (`submitted_at`).
  - **Edge Functions** : `payments-create` ouvre la session (montant = total, clé d'idempotence = transaction +
    tentative : un double toucher rend la même session) ou rend celle en cours pour un nouvel essai ;
    `payments-webhook-nyole` vérifie la signature (5 min de tolérance) puis **relit le statut chez nyole** avant toute
    écriture ; le montant et la devise sont revérifiés en base. Clé secrète uniquement dans les secrets serveur.
  - **Refus de l'opérateur** : « Réessayer » sur la même page ; **« Changer de moyen de paiement »** annule la commande
    non payée et rend la demande (panier restauré, ou nouveau colis).
  - **Sans confirmation en 15 min** (réglable) : commande annulée ; un paiement confirmé ensuite est marqué « à
    rembourser » (circuit d'ADR-027, remboursement via le support nyole).
  - **Frais nyole (5 %)** supportés par la plateforme : même prix pour le client quel que soit le moyen. Réversible
    (frais de service par moyen) si vous le décidez.
- **Alternatives écartées** : un moyen par opérateur dans l'app (double choix, nyole redemande l'opérateur) ; webhook
  seul (sans relecture du statut, un faux appel signé avec une clé fuitée suffirait) ; changer le moyen d'une
  commande existante (risque de double paiement si le client paie après coup).
- **Risque** : la documentation nyole précise que les comptes ouverts après le 17 octobre 2026 encaissent via
  LinkAfr, Griotia ou Wapilot ; vérifier que votre compte dispose bien des clés API (tâche manuelle n° 1).
- **Impact** : financier (moyen : 5 % des paiements Mobile Money), technique (moyen).

---

## ADR-027 — Remboursements, reçus, statistiques (Inc-13)

- **Date** : 2026-10-19
- **Statut** : Accepté
- **Décideur** : Claude (rôle : backend-engineer / flutter-engineer)
- **Contexte** : Stories TRX-02, TRX-03, ADM-04, ADM-06. Les paiements en ligne ne sont pas encore intégrés
  (Inc-11 : fournisseur Mobile Money à choisir ; Inc-12 : clés Stripe).
- **Décision** :
  - **Circuit de remboursement commun**, indépendant du fournisseur : commande payée puis annulée ou refusée →
    « À rembourser » d'office (déclencheur) ; échec de livraison après encaissement → **l'admin décide** (motif
    obligatoire), le client pouvant être en cause (absent) ; l'admin marque « Remboursée » avec une référence
    (espèces rendues, transfert) → transaction « Remboursée ». Stripe et Mobile Money brancheront leur remboursement
    automatique sur ce même état. Une commande en espèces annulée avant encaissement n'a rien à rembourser
    (transaction annulée, ADR-026).
  - **Le client suit chaque étape** : état du paiement sur la commande (mis à jour en direct), chronologie,
    notification « Remboursement en cours » puis « Remboursement effectué », filtre « Remboursements ».
  - **Reçu simple** (TRX-02) composé dans l'app à partir de la commande et de la transaction, partagé en texte
    (WhatsApp, SMS, copie). Historique groupé par jour (Aujourd'hui, Hier, date).
  - **Admin** : filtres statut, moyen, période, zone sur les 200 dernières transactions ; le tableau de bord devient
    l'accueil admin : `admin_stats(from, to)` calculé en base en un appel (montants des commandes livrées de la
    période, commandes par statut et par type, espèces à rapprocher, remboursements en attente, livreurs en ligne avec
    position fraîche — mêmes critères que l'attribution).
- **Alternatives écartées** : reçu PDF (paquet et stockage en plus, inutile au MVP) ; remboursement automatique de
  tout échec (risque d'abus, décision laissée à l'admin) ; statistiques calculées dans l'app (volume, droits) ;
  export CSV (hors critères d'acceptation).
- **Conséquences** : au-delà de quelques centaines de transactions par jour, filtrer côté serveur (pagination).
- **Reporté** : remboursements automatiques Stripe (Inc-12) et Mobile Money (Inc-11).
- **Impact** : financier (moyen : traçabilité des remboursements), métier (faible).

---

## ADR-026 — Espèces, transactions, moyens de paiement (Inc-10)

- **Date** : 2026-10-19
- **Statut** : Accepté
- **Décideur** : Claude (rôle : backend-engineer / flutter-engineer)
- **Contexte** : Stories PAY-01, PAY-02, PAY-06, TRX-01, et la partie espèces d'ADM-04 ; Mobile Money et carte aux
  Inc-11 / 12 (fournisseur Mobile Money encore à choisir).
- **Décision** :
  - **Moyens par pays** (`payment_options`) : seuls les moyens activés sont proposés ; toute commande vérifie, en
    base, qu'un moyen activé existe pour son pays. Mobile Money et carte figurent « Bientôt » et ne peuvent pas être
    activés tant que leur fournisseur n'est pas intégré (refus serveur). Dernier moyen choisi mémorisé sur l'appareil.
  - **Transactions** : une par paiement, montant égal au total, au plus une en cours / réussie / remboursée par
    commande (index unique) ; espèces : en attente dès la commande, réussie à la confirmation d'encaissement (même
    transaction SQL que le registre des espèces), annulée si la commande est annulée, refusée ou en échec avant ;
    commandes existantes reconstituées. « Livrée · non encaissée » signalée côté admin et client.
  - **Espèces** : versements enregistrés par l'admin (montant ≤ dû, référence, journal d'audit) ; solde par
    livreur = encaissé − versé.
  - PAY-06 : montants séparés déjà figés depuis l'Inc-5 (vérifiés par contraintes) ; affichage complet côté admin.
- **Reporté** : filtres, export et marquage « remboursée » des transactions, reçus et historique groupé du client
  (Inc-13).
- **Impact** : financier (moyen : traçabilité des espèces), technique (faible).

---

## ADR-025 — Suivi en temps réel et notifications (Inc-9)

- **Date** : 2026-10-19
- **Statut** : Accepté
- **Décideur** : Claude (rôle : backend-engineer / flutter-engineer)
- **Contexte** : Stories TRK-01 à 03, NOT-01 à 04 ; projet Firebase pas encore créé (tâche manuelle n° 8).
- **Décision** :
  - **Suivi** : le client lit la position et la photo du livreur de sa commande en cours (RLS), en temps réel ;
    estimation d'arrivée calculée sur le téléphone (vol d'oiseau × 1,3, vitesse moyenne selon le moyen de
    transport, passage par le retrait avant récupération) ; au-delà de 60 s, marqueur grisé, âge de la position et
    estimation « indisponible » (jamais une position ancienne présentée comme actuelle) ; bandeau « Connexion perdue »
    tant que le temps réel est coupé, rechargement au retour.
  - **Notifications** : file `notifications` remplie par déclencheur dans la même transaction que l'événement
    (qui est prévenu de quoi : client à chaque étape utile, livreur de ses offres et missions, restaurant de ses
    commandes ; jamais l'auteur de l'action) ; la base appelle la fonction `push` (pg_net, adresse et clé dans le
    coffre) qui envoie par **FCM HTTP v1** (compte de service en secret), oublie les appareils désinscrits et
    retente les échecs (5 fois, tâche planifiée). Sans compte FCM : notifications marquées `not_configured`.
  - **App** : Firebase initialisé avec des options passées au build (`FIREBASE_*`, pas de fichier
    `google-services.json` dans le dépôt) ; autorisation demandée une fois, au premier moment utile, après une
    explication (suivi d'une commande, passage en ligne, écran des commandes du restaurant) ; rappel discret si
    refusée ; l'appareil suit le dernier compte connecté et son jeton est révoqué à la déconnexion ; le toucher
    ouvre l'écran fourni par le serveur. Jetons d'enregistrement FCM conservés (API marquée dépréciée au profit des
    identifiants d'installation, que l'envoi serveur n'utilise pas encore).
  - **Navigateur** (restaurant) : bip Web Audio tant que la page est ouverte (NOT-03) ; pas de push web.
- **Reporté** : notifications de paiement (Inc-11 / 12) ; canal Android dédié « haute importance » (bannière
  par-dessus les apps) si le canal par défaut ne suffit pas aux livreurs lors des essais réels.
- **Impact** : technique (moyen), dépendance Firebase (gratuite), RGPD : jetons d'appareil supprimés avec le compte.

---

## ADR-024 — Mission du livreur, code de livraison, espèces (Inc-8)

- **Date** : 2026-10-19
- **Statut** : Accepté
- **Décideur** : Claude (rôle : backend-engineer / flutter-engineer)
- **Contexte** : Stories MIS-01 à MIS-10, remise au livreur (ORD-10) ; paiements et rapprochement aux Inc-10 et 13.
- **Décision** :
  - Une fonction serveur par étape (`confirm_pickup`, `start_delivery`, `confirm_delivery`, `confirm_cash_collected`,
    `report_problem`, `declare_failure`, `release_mission`, `admin_confirm_delivery`), chacune limitée au livreur de
    la mission (ou à l'admin) ; le restaurant peut déclarer la remise (`transition_order` → « Récupérée »).
  - **Code** : comparé côté serveur, jamais lisible par le livreur ; un essai faux est **enregistré** (la fonction
    rend un résultat au lieu de lever une erreur, sinon l'essai serait annulé) ; blocage après 5 erreurs (paramètre),
    alerte admin, puis livraison confirmée par l'admin avec motif.
  - **Espèces** : registre `cash_ledger` (encaissé / versé) dès maintenant, une seule écriture par commande ; colis :
    l'expéditeur paie à la récupération (confirmation obligatoire) ; repas : encaissement après le code. Les
    transactions et versements arrivent à l'Inc-10.
  - **Confidentialité** : le livreur lit la commande pendant la mission et une heure après (règle RLS) ; ensuite,
    l'historique passe par `courier_missions()`, sans téléphones ni repères.
  - Abandon avant récupération : la recherche repart de zéro (délais d'alerte remis à zéro) sans reproposer ce livreur.
  - Itinéraire : carte OpenStreetMap + ouverture de Google Maps ou Waze (aucune API payante, ADR-005).
- **Reporté** : notifications (« votre livreur est en route »…) à l'Inc-9 ; décision de remboursement après échec
  à l'Inc-13.
- **Impact** : métier (fort : preuve de livraison, espèces), sécurité (moyen).

---

## ADR-023 — Mise en ligne et attribution des livreurs (Inc-7)

- **Date** : 2026-10-18
- **Statut** : Accepté
- **Décideur** : Claude (rôle : backend-engineer / flutter-engineer)
- **Contexte** : Stories COU-05, DIS-01 à 04, ADM-03, ADM-05, plus les points reportés des Inc-5 et 6.
- **Décision** :
  - **Tout dans Postgres** (ADR-003) : offres (`delivery_offers`), dernière position (`courier_locations`),
    paramètres (`settings`, ligne unique tracée dans l'audit). Recherche lancée par déclencheur quand un repas passe
    « En préparation » ou qu'un colis est confirmé, relancée quand un livreur est retiré ; tâche `pg_cron`
    **toutes les 10 s** (offres expirées, recherches en attente, alerte à 10 min, annulation à 30 min, refus
    restaurant). Verrouillage toujours **commande puis offre** (pas d'interblocage) et `SKIP LOCKED` sur les livreurs.
  - Livreur éligible : approuvé, en ligne, **position de moins de 2 min**, même zone, moyen adapté au colis, sans
    mission ni offre en attente, jamais sollicité pour cette commande ; le plus proche du retrait à vol d'oiseau.
  - **Aucune commande sans livreur en ligne** (déclencheur à l'insertion) ; les devis l'annoncent avant la
    confirmation ; les types de colis proposés dépendent des moyens des livreurs en ligne.
  - Position : envoi immédiat, à chaque déplacement de 25 m (au plus toutes les 10 s) et toutes les 30 s à l'arrêt ;
    effacée au passage hors ligne. Android : service de premier plan « location » avec notification permanente
    (pas de localisation en arrière-plan ; visible sans autorisation de notification jusqu'à Android 12, au-delà
    une fois l'autorisation demandée avec les notifications push, Inc-9).
  - Offre plein écran : vibration répétée, son système ; le son personnalisé et la notification arrivent à l'Inc-9.
  - DIS-03 : le client peut annuler un repas déjà en préparation une fois l'alerte déclenchée (sans livreur).
  - Supervision admin : commandes en cours en temps réel, filtres, alertes « sans livreur » et « restaurant sans
    réponse » (au-delà de la moitié du délai) ; attribution manuelle avec motif.
- **Reporté** : alertes « code bloqué » et « échec signalé », livraison sans code (Inc-8) ; « paiement à
  rembourser » (Inc-13) ; moyens de paiement par pays dans les paramètres (Inc-11) ; gains et espèces du livreur (Inc-8).
- **Alternatives écartées** : attribution dans une Edge Function (un aller-retour de plus, verrous moins sûrs) ;
  position en arrière-plan permanente (refus fréquent des stores et batterie).
- **Impact** : métier (fort : plus de commande sans livreur en ligne), technique (moyen), stores (déclaration du
  service de premier plan, `docs/manual-tasks.md` §11).

---

## ADR-022 — Livraison de colis : choix de mise en œuvre (Inc-6)

- **Date** : 2026-10-18
- **Statut** : Accepté
- **Décideur** : Claude (rôle : backend-engineer / flutter-engineer)
- **Contexte** : Stories PAR-01 à PAR-05 ; attribution des livreurs à l'Inc-7, paiements en ligne aux Inc-11 / 12.
- **Décision** :
  - Une demande de colis est une `orders` de type `parcel` (même suivi, même chronologie que les repas) ; types de
    colis en table (`parcel_types`, gérés par l'admin) ; devis et création côté serveur, comme les repas (ADR-020).
  - Départ et arrivée dans **la même zone** (`different_zones` sinon) et à **100 m au moins** l'un de l'autre
    (`same_location`) : la carte d'arrivée part du point de départ, l'oubli de la déplacer est le cas le plus probable.
  - Code de livraison à 4 chiffres créé pour **toute** commande (repas compris, MIS-06), lisible seulement par le
    client et l'admin ; partage par la feuille de partage du téléphone (WhatsApp, SMS…).
  - Espèces seulement, payées au livreur **à la récupération** ; annulation par le client jusqu'à la récupération.
- **Reporté à l'Inc-7** : types proposés selon les moyens de transport des livreurs disponibles (PAR-01), refus sans
  livreur en ligne (PAR-03), retrait de l'offre ou de la mission à l'annulation (PAR-05).
- **Impact** : métier (moyen).

---

## ADR-021 — Structure d'interface commune (retour utilisateur)

- **Date** : 2026-10-18
- **Statut** : Accepté
- **Décideur** : Claude (rôle : ui-ux-designer), d'après la maquette validée (C-01)
- **Contexte** : Barres du haut invisibles (même couleur que le fond), accueil sans barre, espaces vides.
- **Décision** : barre du haut blanche avec filet dans le thème (tous les écrans d'un coup) ; accueil client
  repris de la maquette ; navigation basse Client à 5 entrées avec bouton central « + » (repas ; colis à l'Inc-6) et écran
  Paiements (moyens disponibles, paiements des commandes) ; composants partagés `EmptyState`, `SectionHeader`,
  `BrandWordmark` dans `core`. La cloche ouvre les commandes en attendant les notifications (Inc-9).
- **Impact** : design (fort), technique (faible).

---

## ADR-020 — Commande de repas : choix de mise en œuvre (Inc-5)

- **Date** : 2026-10-18
- **Statut** : Accepté
- **Décideur** : Claude (rôle : backend-engineer / flutter-engineer)
- **Contexte** : Stories ORD-01 à ORD-13 ; paiements, livreurs et notifications arrivent aux Inc-7 à 13.
- **Décision** :
  - Tables `orders`, `order_items`, `order_events` complètes dès maintenant (statuts colis et livreur inclus) ;
    positions figées en latitude / longitude. Aucune écriture directe : devis, création, annulation et transitions par
    fonctions serveur ; chronologie écrite dans la même transaction.
  - Devis serveur (`quote_food_order`) : les écarts (fermé, indisponible) sont rendus au client, la création les refuse
    (`cart_changed`) ; total comparé à celui affiché (`price_changed`) ; clé d'idempotence par tentative.
  - **Espèces seulement** pour l'instant (`payment_unavailable` sinon) ; Mobile Money et carte aux Inc-11 / 12.
  - Le contrôle « aucun livreur en ligne » est **reporté à l'Inc-7** : sans mise en ligne des livreurs, il bloquerait toutes les commandes.
  - Refus automatique après 10 min sans réponse : tâche `pg_cron` chaque minute.
  - Restaurant : écran Commandes en temps réel (Realtime filtré par la RLS), alerte par vibration répétée et bandeau ;
    **le son arrive avec les notifications (Inc-9)**. La remise au livreur (`ready → picked_up`) arrive à l'Inc-8.
  - Panier sur le téléphone (un seul restaurant), conservé entre deux ouvertures ; prix recalculés par le serveur.
- **Reporté** : recherche de restaurants (ORD-03, « Should »), frais et distance sur chaque carte restaurant (ORD-02),
  bouton d'appel du support (numéro à fournir).
- **Impact** : métier / sécurité (moyen).

---

## ADR-019 — Thème clair imposé, cartes OpenStreetMap, accueil client (refonte visuelle)

- **Date** : 2026-10-18
- **Statut** : Accepté
- **Décideur** : Claude (rôle : ui-ux-designer / flutter-engineer), à la suite du retour de l'utilisateur
- **Contexte** : L'app suivait le thème sombre du téléphone (fond vert très foncé, jamais demandé) ; la carte Google
  restait vide sans clé (une bande grise) ; l'espace Client s'ouvrait sur la liste d'adresses. Jugé « ridicule ».
- **Décision** :
  - **Thème clair seul**, quel que soit le réglage du téléphone ; jetons sombres supprimés. Écran de bienvenue clair.
  - **Cartes `flutter_map` + tuiles OpenStreetMap** au lieu de Google Maps : la carte s'affiche partout (Android, web)
    sans clé ni compte de facturation. URL des tuiles configurable (`MAP_TILES_URL`) ; serveurs publics d'OpenStreetMap
    en développement seulement, fournisseur ou tuiles auto-hébergées en production (tâche manuelle §7).
  - Éditeur d'adresse : carte en haut, épingle fixe qui se soulève pendant le déplacement, formulaire en feuille arrondie.
  - **Accueil client** (C-01) : adresse de livraison, services Repas / Colis, restaurants (ouverts d'abord) ; fiche
    restaurant (C-03) : photo, indicateurs, menu par catégorie, produits indisponibles grisés. Le panier arrive à l'Inc-5.
  - Sans photo, couvertures et produits affichent un motif teinté (vert, ambre ou rose selon le restaurant).
  - Restaurants de démonstration dans `supabase/seed.sql` (local uniquement), photos générées par l'utilisateur
    (`supabase/seed-media/`, bucket déclaré dans `config.toml`). Bienvenue : grande photo de plats + fondu clair.
- **Alternatives écartées** : garder Google Maps (clé et facturation obligatoires, rien d'affiché sans elles) ; thème sombre
  corrigé (non demandé ; à reconsidérer plus tard sur demande) ; CARTO (demande désormais une clé).
- **Conséquences** : un fournisseur de tuiles est à choisir avant la publication ; les liens « Voir sur une carte » de
  l'admin (zones, restaurants) ouvrent encore Google Maps dans le navigateur, ce qui ne demande pas de clé.
- **Impact** : produit / design (fort), technique (moyen).

---

## ADR-018 — Restaurants et catalogue (Inc-4)

- **Date** : 2026-10-18
- **Statut** : Accepté
- **Décideur** : Claude (rôle : backend-engineer / security-engineer)
- **Contexte** : Stories RES-01 à RES-05 ; un restaurant est créé par l'équipe puis tenu par ses gérants.
- **Décision** :
  - Création et réglages sensibles (zone, position, commission, activation) par l'admin seulement, via
    `admin_save_restaurant` (journalisée) ; le gérant ne modifie que présentation, type de cuisine, photo,
    téléphone, temps de préparation et fermeture temporaire (droits par colonne).
  - Gérants invités par email ou numéro (`admin_invite_member`) : reliés tout de suite si le compte existe,
    sinon dès que l'identifiant est vérifié (déclencheur sur les comptes). Espace Restaurant ouvert aux gérants.
  - Ouverture calculée par le serveur (`is_open`) selon les horaires dans le fuseau de la zone et la fermeture
    temporaire.
  - Produits archivés au lieu d'être supprimés (les commandes y feront référence) ; prix entiers en XOF.
  - Photos (couverture, produits) dans un bucket public `media` : images de vitrine, non sensibles ;
    écriture réservée aux gérants du restaurant et aux admins.
  - Un gérant gère un restaurant au MVP (le premier de ses accès).
- **Alternatives écartées** : création libre par les restaurants (risque de faux restaurants) ; photos privées
  (liens signés inutiles pour des images de vitrine, et plus lents).
- **Conséquences** : la commission ne peut pas être modifiée par le restaurant ; l'historique reste intact.
- **Impact** : métier / sécurité (moyen).

---

## ADR-017 — Livreurs et administration des comptes (Inc-3)

- **Date** : 2026-10-18
- **Statut** : Accepté
- **Décideur** : Claude (rôle : backend-engineer / security-engineer)
- **Contexte** : Stories COU-01 à COU-04 et ADM-02 (la mise en ligne COU-05 arrive à l'Inc-7).
- **Décision** :
  - Profil livreur soumis par une fonction SQL (`submit_courier_profile`) ; statut modifiable seulement par l'admin
    (`admin_set_courier_status`, motif obligatoire pour refus et suspension) ; nouvelle validation si le moyen de
    transport, l'immatriculation ou la zone change.
  - Photos dans un bucket privé (2 Mo max, JPEG / PNG / WebP), chacun écrit dans son dossier, liens temporaires d'1 h.
  - Suspension d'un compte : indicateur dans le profil (bloque les écritures) **et** blocage de connexion par Auth,
    appliqués ensemble par la fonction serveur `admin-users` ; changement d'identifiant par l'admin dans la même fonction.
  - Journal d'audit des décisions admin (`audit_log`), conservé même si le compte de l'admin est supprimé.
  - Le livreur voit son statut en actualisant l'écran ; la notification push de la décision arrive avec l'Inc-9.
- **Alternatives écartées** : suspension par simple indicateur (le compte pourrait encore se connecter) ; photos publiques.
- **Conséquences** : décisions admin traçables ; une fonction serveur de plus à déployer sur le VPS.
- **Impact** : sécurité / métier (moyen).

---

## ADR-016 — Une seule app mobile, un espace par rôle (remplace ADR-002)

- **Date** : 2026-10-18
- **Statut** : Accepté (décision utilisateur)
- **Décideur** : Utilisateur ; mise en œuvre Claude (rôle : mobile-architect)
- **Contexte** : L'utilisateur préfère publier une seule app plutôt que trois (Client, Livreur, Back-office).
- **Décision** : `apps/mobile` (Android, iOS, web) : tout compte a l'espace Client ; les espaces Livreur, Restaurant et
  Admin s'ouvrent selon `my_roles` ; écran « Changer d'espace », dernier espace mémorisé ; « Devenir livreur » depuis cet
  écran. Les écrans existants ont été déplacés sans réécriture ; le back-end est inchangé.
- **Alternatives écartées** : trois apps séparées (ADR-002).
- **Conséquences** : une fiche store, une configuration Firebase ; la localisation en arrière-plan (livreurs, Inc-7) sera
  déclarée dans l'app unique et devra être justifiée auprès de Google Play ; l'admin peut utiliser la version navigateur.
- **Impact** : technique / métier (moyen).

---

## ADR-015 — Zones, tarifs et adresses : choix de mise en œuvre (Inc-2)

- **Date** : 2026-10-18
- **Statut** : Accepté
- **Décideur** : Claude (rôle : database-architect / flutter-engineer)
- **Contexte** : Mettre en œuvre ADR-005, H-02 à H-04 et les stories ADR-01 à ADR-07 sans service payant.
- **Décision** :
  - Positions stockées en latitude / longitude + colonne PostGIS générée (lecture et écriture simples depuis les apps).
  - Zone et ville d'une adresse calculées par un déclencheur ; adresse hors zone refusée (`address_out_of_zone`) ;
    une seule adresse par défaut garantie par la base.
  - Calcul des frais dans une seule fonction SQL (`private.price_delivery`), réutilisée par les devis des Inc-5/6.
  - Règles tarifaires invisibles des clients (ils ne voient que les devis).
  - Carte : Google Maps quand une clé est fournie (`GOOGLE_MAPS_ENABLED`) ; sinon l'éditeur fonctionne au GPS seul.
  - Back-office : centre de zone saisi en coordonnées + lien « Voir sur une carte » au lieu d'une carte intégrée
    (évite une clé Maps web pour un usage admin ponctuel) ; écart à la fiche A-08 assumé.
  - App Client : « Mes adresses » sert d'accueil provisoire jusqu'à l'accueil des commandes (Inc-5).
  - Nouvelles dépendances : `google_maps_flutter`, `geolocator`, `geocoding` (quartier suggéré par le téléphone,
    gratuit), `url_launcher` (back-office).
- **Alternatives écartées** : saisie libre de la ville (incohérences) ; géocodage payant ; carte web intégrée à l'admin.
- **Conséquences** : la carte reste à vérifier dès que la clé Google Maps existe (tâche manuelle 7).
- **Impact** : technique / métier (faible).

---

## ADR-014 — Authentification : choix de mise en œuvre (Inc-1)

- **Date** : 2026-10-18
- **Statut** : Accepté
- **Décideur** : Claude (rôle : security-engineer / backend-engineer)
- **Contexte** : Mettre en œuvre ADR-004 avec le minimum de code, en restant testable de bout en bout en local.
- **Décision** :
  - Codes à 6 chiffres par email (modèles FR, `{{ .Token }}`) plutôt que des liens ; validité 10 min.
  - Changement d'email sans double confirmation (`double_confirm_changes = false`) : seul le nouvel email reçoit un code.
  - Suppression de compte : anonymisation du profil (SQL) puis suppression « douce » du compte d'authentification
    (fonction serveur `account-delete`) ; le profil reste pour l'historique des commandes, sans donnée identifiante.
  - Inscription existante détectée (réponse sans identité) pour afficher « Un compte existe déjà » (AUTH-01), au prix
    d'une possible énumération des comptes, acceptée pour l'expérience utilisateur.
  - Local : fournisseur SMS déclaré factice pour activer le téléphone ; seuls les numéros de test (code 123456) marchent.
  - Ville saisie librement (préremplie « Abidjan ») jusqu'à l'arrivée des zones (Inc-2), qui la transformera en liste.
  - Back-office réservé aux admins en Inc-1 ; les membres de restaurants y accéderont à l'Inc-4.
  - Nouvelles dépendances : `freezed` / `json_serializable` (modèles), `phone_numbers_parser` (numéros), `http`
    (lecture des méthodes de connexion actives), `go_router` dans `core` (navigation commune).
- **Alternatives écartées** : liens magiques (gestion des liens profonds) ; suppression définitive du compte (casserait
  l'historique comptable) ; mock du serveur dans les tests d'intégration (tests contre le vrai Supabase local à la place).
- **Conséquences** : parcours complets testés automatiquement contre Supabase local ; SMTP et SMS réels restent à
  configurer sur le VPS (tâches manuelles 5 et 6).
- **Impact** : sécurité / métier (moyen).

---

## ADR-013 — Socle technique et dépendances (Inc-0)

- **Date** : 2026-10-18
- **Statut** : Accepté
- **Décideur** : Claude (rôle : flutter-engineer / backend-engineer)
- **Contexte** : Mettre en place le socle commun aux 3 apps avec le minimum de dépendances.
- **Décision** :
  - Espace de travail Dart (`workspace:`) : une résolution unique pour `packages/core` et les 3 apps.
  - Dépendances : `supabase_flutter` 2.18 (client), `flutter_secure_storage` 11 (session dans Keystore / Keychain),
    `flutter_riverpod` 3.3 + `riverpod_annotation` / `riverpod_generator` 4 (état, ADR-001), `go_router` 17 (navigation),
    `intl` + `flutter_localizations` (textes français). Aucune autre bibliothèque tant qu'un incrément n'en a pas besoin.
  - Code généré (Riverpod, textes) **versionné** : l'app se lance dès `pub get` ; la CI le régénère et échoue s'il diffère.
  - Police Plus Jakarta Sans embarquée (4 graisses, licence OFL déclarée dans l'app) : aucun téléchargement au démarrage.
  - Identifiants d'application provisoires `com.tchopi.client`, `com.tchopi.courier`, `com.tchopi.backoffice`
    (à confirmer avant la première publication : ils ne pourront plus changer ensuite).
  - Supabase : paramètre `publishableKey` (le paramètre `anonKey` est déprécié) alimenté par la clé « anon » de l'instance auto-hébergée.
  - HTTP en clair autorisé uniquement dans le manifeste Android de débogage (Supabase local).
  - Jetons clairs `muted`, `warning`, `danger` assombris (`#646B78`, `#9A4A07`, `#C81E1E`) : les tests de contraste
    ont montré qu'ils passaient sous le seuil AA sur leurs fonds.
- **Alternatives écartées** : Melos (inutile depuis les workspaces Dart) ; `google_fonts` (téléchargement réseau au
  lancement) ; code généré non versionné (outillage supplémentaire pour lancer l'app).
- **Conséquences** : un seul `flutter pub get` à la racine ; contrôle automatique du code généré en CI.
- **Impact** : technique (faible, réversible).

---

## ADR-012 — Modèle de données et API métier

- **Date** : 2026-10-18
- **Statut** : Accepté
- **Décideur** : Claude (rôle : database-architect / system-design)
- **Contexte** : Garantir les règles de cohérence (INTAKE §7.C) avec le minimum de code, pour le mobile et le futur web.
- **Décision** : Une table `orders` commune repas / colis avec statuts contraints par type ; une fonction unique
  `transition_order` porte la machine à états ; adresses, prix et infos livreur **figés** sur la commande ; code de livraison
  dans une table séparée lisible par le seul client ; une seule tâche planifiée `private.tick()` (10 s) pour tous les délais ;
  frais arrondis au pas supérieur de 25 F (payables en espèces) ; pas de base locale dans les apps (cache de lecture seulement).
  Détail : `docs/data-model.md`, `docs/system-design.md`.
- **Alternatives écartées** : tables séparées repas / colis (logique dupliquée) ; une fonction par transition (API plus
  large sans gain) ; synchronisation hors ligne des actions (risque d'incohérence sur les statuts et paiements).
- **Conséquences** : les règles sont testables en pgTAP en un seul endroit ; les noms des actions forment le contrat d'API.
- **Impact** : technique (structurant), métier (arrondi des frais : faible).

---

## ADR-011 — Direction design et budgets de performance

- **Date** : 2026-10-18
- **Statut** : Accepté (exigence utilisateur D-1)
- **Décideur** : Claude (rôle : ui-ux-designer / performance-engineer), sur demande de l'utilisateur
- **Contexte** : L'utilisateur exige une app « extrêmement moderne, fluide et rapide » et fournit 5 références visuelles.
- **Décision** : Direction décrite dans `docs/design/direction.md` (jetons, police embarquée Plus Jakarta Sans, composants
  signature, clair / sombre) ; budgets mesurés : démarrage < 2 s (milieu de gamme) / < 3 s (entrée de gamme), 60 i/s,
  APK < 25 Mo par architecture ; maquette interactive validée avant le code des écrans.
- **Alternatives écartées** : effets lourds (flou d'arrière-plan, animations complexes) qui dégradent la fluidité sur Android modeste ;
  notes et avis sur les cartes restaurant (fonctionnalité hors périmètre).
- **Conséquences** : point de validation design en phase 3 ; mesures de performance obligatoires en phase 5.
- **Impact** : métier (élevé pour l'utilisateur), technique (faible).

---

## ADR-010 — L'API Supabase est l'API du produit (mobile et future app web)

- **Date** : 2026-10-18
- **Statut** : Accepté (exigence utilisateur D-2)
- **Décideur** : Claude (rôle : system-design / backend)
- **Contexte** : Une application web sera développée plus tard sur les mêmes données et règles.
- **Décision** : Ne pas écrire de serveur d'API séparé. Les clients (mobile, web) utilisent l'API Supabase : REST et actions
  métier (`/rest/v1`, `/rest/v1/rpc`), authentification, temps réel, fichiers, Edge Functions. Écritures sensibles uniquement
  via les actions métier ; lectures filtrées par RLS. Contrat documenté (`docs/api/`), OpenAPI et types TypeScript générés,
  tests de contrat, CORS limité au domaine web, versionnement des actions (`_v2`) en cas de changement incompatible.
- **Alternatives écartées** : API REST maison (Node/NestJS) devant Supabase — duplication des règles, plus de code et de
  maintenance, aucune garantie de sécurité supplémentaire.
- **Conséquences** : le web hérite automatiquement des règles de cohérence et de sécurité ; les noms des actions deviennent un contrat public.
- **Impact** : technique (structurant).

---

## ADR-009 — Hébergement : Supabase auto-hébergé sur le VPS Hostinger

- **Date** : 2026-10-18
- **Statut** : Accepté (exigence utilisateur D-4)
- **Décideur** : Claude (rôle : system-design / security / release), sur demande de l'utilisateur
- **Contexte** : Tout doit être hébergé sur le VPS Hostinger de l'utilisateur (base de données, Supabase, API).
- **Décision** : Supabase auto-hébergé via Docker Compose (versions figées) ; seul HTTPS exposé via un proxy inverse à
  certificat automatique ; base et Studio non exposés (Studio par tunnel SSH) ; pare-feu, SSH par clé, mises à jour de
  sécurité automatiques ; sauvegardes quotidiennes base + fichiers copiées hors du VPS, restauration testée ; déploiement
  automatique par GitHub Actions (tests → sauvegarde → migrations → fonctions → vérification de santé) ; supervision externe.
- **Alternatives écartées** : Supabase Cloud (contraire à la demande).
- **Conséquences** : exploitation à notre charge (mises à jour, sauvegardes, sécurité) ; 8 Go de RAM recommandés ;
  le service d'images auto-hébergé permet de servir des vignettes légères sans surcoût ; configuration SMTP / SMS par variables d'environnement.
- **Impact** : sécurité / exploitation (élevé), financier (positif : pas d'abonnement).

---

## ADR-008 — Ajouts imposés par les stores et la cohérence

- **Date** : 2026-10-18
- **Statut** : Accepté
- **Décideur** : Claude (rôle : product-owner / store-engineer)
- **Contexte** : L'INTAKE interdit les fonctionnalités non justifiées ; certaines sont pourtant obligatoires.
- **Décision** : Ajouter uniquement : suppression de compte dans l'app (règles Google Play / App Store), URL de politique
  de confidentialité et CGU, refus automatique d'une commande sans réponse du restaurant (10 min) et expiration d'un
  paiement non confirmé (15 min), liste des objets autorisés pour les colis, numéro de support configurable,
  comptes de démonstration pour la revue des stores.
- **Alternatives écartées** : ne rien ajouter (rejet store, commandes bloquées indéfiniment).
- **Conséquences** : la suppression de compte anonymise les données personnelles et conserve les commandes et
  transactions nécessaires à la comptabilité.
- **Impact** : légal / métier (faible).

---

## ADR-007 — Notifications : FCM + temps réel

- **Date** : 2026-10-18
- **Statut** : Accepté
- **Décideur** : Claude (rôle : system-design)
- **Contexte** : Notifications client, livreur et restaurant (INTAKE §4.6) ; budget limité.
- **Décision** : Push via Firebase Cloud Messaging, envoyé par une Edge Function déclenchée par les changements de statut ;
  Supabase Realtime pour la mise à jour des écrans ouverts ; alerte sonore dans l'espace restaurant.
- **Alternatives écartées** : SMS transactionnels (coût par message), OneSignal (dépendance tierce supplémentaire).
- **Conséquences** : projet Firebase à créer (gratuit) ; clé de compte de service stockée dans les secrets Supabase.
- **Impact** : technique (réversible).

---

## ADR-006 — Paiements : Edge Functions multi-fournisseurs, confirmation serveur uniquement

- **Date** : 2026-10-18
- **Statut** : Accepté — cartes : **Stripe** (société de l'utilisateur dans un pays compatible, D-5) ; Mobile Money :
  **Paystack** ou **CinetPay** selon l'éligibilité de la société, à confirmer avant l'Inc-11
- **Décideur** : Claude (rôle : backend / security)
- **Contexte** : Mobile Money, carte, espèces ; « une transaction n'est jamais réussie parce que le client a quitté l'écran ».
- **Décision** : Initiation et webhooks dans des Edge Functions (secrets côté serveur) ; signature du webhook vérifiée,
  puis vérification du statut auprès du fournisseur ; traitement idempotent (référence fournisseur unique, un seul paiement
  réussi par commande). Moyens et opérateurs affichés selon une configuration par pays (seuls ceux réellement intégrés).
- **Alternatives écartées** : confirmation par l'app (non fiable), SDK de paiement embarquant des secrets.
- **Conséquences** : un adaptateur par fournisseur ; espèces gérées sans fournisseur (confirmation du livreur).
- **Impact** : sécurité / financier (élevé).

---

## ADR-005 — Cartes et distances sans API payante

- **Date** : 2026-10-18
- **Statut** : Accepté
- **Décideur** : Claude (rôle : mobile-architect)
- **Contexte** : Adresses sans nom de rue ; estimation des frais ; budget limité.
- **Décision** : Google Maps SDK (affichage, gratuit sur mobile) ; adresse = position sur carte + quartier + repère +
  instructions ; distance = vol d'oiseau × coefficient de détour (PostGIS) ; navigation par ouverture de Google Maps / Waze.
- **Alternatives écartées** : API Directions / Distance Matrix / Places (payantes), tuiles OpenStreetMap publiques
  (politique d'usage incompatible avec une app).
- **Conséquences** : estimation de distance et d'ETA approximative, présentée comme telle ; clés Maps restreintes à l'app.
- **Impact** : technique / financier (faible).

---

## ADR-004 — Authentification : email ou téléphone + mot de passe, vérification par OTP

- **Date** : 2026-10-18
- **Statut** : Accepté (décision utilisateur D-3, remplace la proposition « OTP sans mot de passe »)
- **Décideur** : Utilisateur ; mise en œuvre Claude (rôle : security-engineer)
- **Contexte** : INTAKE §2.1 (téléphone + OTP, mot de passe possible) ; l'accès aux API SMS est difficile en Afrique.
- **Décision** : Supabase Auth avec deux méthodes : email + mot de passe (vérification et récupération par code à 6 chiffres
  envoyé par email via SMTP) et téléphone + mot de passe (vérification et récupération par code SMS via Twilio Verify ou
  une passerelle locale branchée par hook d'envoi). Une méthode non configurée n'est pas affichée. Téléphone obligatoire au
  profil. Session persistante, jetons dans le stockage sécurisé (Keystore / Keychain) ; limitation des tentatives ; codes de test en développement.
- **Alternatives écartées** : OTP seul sans mot de passe (dépendance totale au SMS) ; liens magiques par email (moins adaptés au mobile qu'un code).
- **Conséquences** : SMTP à configurer (SPF / DKIM / DMARC) ; SMS facultatif au lancement.
- **Impact** : métier / sécurité (moyen).

---

## ADR-003 — Règles métier dans Postgres (fonctions + RLS + pg_cron)

- **Date** : 2026-10-18
- **Statut** : Accepté
- **Décideur** : Claude (rôle : system-design / database-architect)
- **Contexte** : INTAKE §7.C exige des garanties fortes (états, droits, paiements, montants).
- **Décision** : Machine à états, devis, attribution et confirmations implémentés en fonctions SQL transactionnelles ;
  écriture directe des statuts interdite ; RLS sur toutes les tables ; pg_cron pour les délais (offres, expirations,
  annulations automatiques). Edge Functions réservées aux appels externes (paiement, push).
- **Alternatives écartées** : logique dans l'app (contournable), serveur applicatif dédié (coût et maintenance).
- **Conséquences** : règles testées en pgTAP ; une seule source de vérité pour les 3 apps.
- **Impact** : technique (structurant).

---

## ADR-002 — Monorepo Flutter : 3 applications + 1 package partagé

- **Date** : 2026-10-18
- **Statut** : Remplacé par ADR-016 (une seule app)
- **Décideur** : Claude (rôle : mobile-architect)
- **Contexte** : 4 interfaces (client, livreur, restaurant, admin) ; permissions minimales par app ; code commun.
- **Décision** : Workspace Dart : `apps/client` (Android/iOS), `apps/courier` (Android/iOS), `apps/backoffice`
  (web + Android, espaces restaurant et admin selon le rôle), `packages/core` (modèles, auth, Supabase, thème, widgets, l10n).
- **Alternatives écartées** : une seule app pour tous les rôles (permissions de localisation en arrière-plan imposées aux
  clients, risque de rejet store) ; dashboard admin dans une autre techno (deux stacks à maintenir).
- **Conséquences** : 2 apps à publier côté stores (+ back-office Android pour les restaurants) ; logique partagée écrite une fois.
- **Impact** : technique (réversible avec effort).

---

## ADR-001 — Gestion d'état : Riverpod

- **Date** : 2026-10-18
- **Statut** : Accepté
- **Décideur** : Claude (rôle : mobile-architect / state-management-engineer)
- **Contexte** : Besoin d'une gestion d'état Flutter testable, sûre et scalable pour le projet.
- **Décision** : Utiliser **Riverpod** par défaut.
- **Alternatives écartées** : Bloc (plus verbeux pour un MVP), Provider seul (moins sûr à la
  compilation), setState (ne passe pas à l'échelle), GetX (couplage et magie implicite).
- **Conséquences** : État découplé de `BuildContext`, providers testables, bon support du code
  généré. Courbe d'apprentissage modérée acceptée.
- **Impact** : technique (réversible avec effort).

---

## ADR-000 — Modèle d'enregistrement

- **Date** : 2026-10-18
- **Statut** : Accepté
- **Contexte** : Établit le format des décisions. À copier pour chaque nouvelle entrée.
- **Décision** : Utiliser ce gabarit pour toute décision ayant un impact sur l'architecture,
  les dépendances, la sécurité, le coût ou le comportement produit.
- **Conséquences** : Traçabilité complète ; l'utilisateur peut revenir sur tout choix.

---

<!-- Copier ce bloc pour chaque nouvelle décision :

## ADR-NNN — <titre court>

- **Date** :
- **Statut** : Proposé / Accepté / Remplacé par ADR-XXX
- **Décideur** : Claude (rôle : <ex. mobile-architect>)
- **Contexte** :
- **Décision** :
- **Alternatives écartées** :
- **Conséquences** :
- **Impact** : technique / financier / métier / sécurité (et niveau)

-->

## ADR-062 — Un compte, un profil pour le web et le mobile
- **Cause** : le mobile exigeait un profil complet (prénom, nom, téléphone, ville) que le web ne demandait jamais ; le web reproposait l'onboarding aux comptes créés sur le mobile (`onboarded_at` jamais posé).
- **Décision** : règle unique tenue par le serveur (`private.profile_complete`, exposée par `my_roles.profile_complete`). Le web demande le profil complet avant toute suite (villes desservies, comme le mobile) ; le mobile marque le parcours choisi quand le profil est complet. Prénom et nom repris du fournisseur (Google) à l'inscription ; comptes existants complétés uniquement sur les champs vides (métadonnées Google, numéro de connexion, ville de l'établissement). Aucune donnée supprimée.
