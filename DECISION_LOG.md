# Journal de décisions (DECISION_LOG)

> ADR léger. Chaque décision structurante prise par Claude **en autonomie** y est consignée :
> contexte → décision → alternatives écartées → conséquences. Permet de tracer et de contester.
> Format inspiré des Architecture Decision Records. Le plus récent en haut.

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
