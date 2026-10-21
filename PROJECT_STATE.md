# État du projet — PROJECT_STATE

> Mis à jour par Claude à la fin de chaque phase / incrément. Permet de **reprendre** le
> travail à tout moment, même dans une nouvelle session. Toujours lire ce fichier avant d'agir.

## Snapshot

- **Phase courante** : 5 — Qualité & performance faite · Inc-12 (carte Stripe) livré, à brancher sur vos clés · back-end en ligne sur https://api.tchopi.com (VPS partagé, ADR-031) ; app web sur tchopi.com et Play Store à venir
- **Dernière mise à jour** : 2026-10-21
- **Santé** : 🟢 OK · serveur en ligne ; inscriptions réservées aux numéros autorisés (pas encore de SMS)
- **Prochaine action** : phase 6 (publication : signature, fiche Play Store) ; essais réels Stripe et nyole dès réception de vos clés de test (tâche manuelle n° 1)
- **Plan de référence** : `docs/plan-de-realisation.md` · Design : `docs/design/design-system.md`
- **Maquette** : `docs/design/maquette.html` — https://claude.ai/artifact/9GyaG6F34CkTe1qQpsy1cP (privée)

## Environnement constaté (2026-10-18)

Flutter 3.41.9 · Dart 3.11.5 · Supabase CLI 2.116.0 · Docker 29.8.2 · Java 21 · Node 24 · adb présent ·
émulateur créé : tchopi_entree_de_gamme (Android 37, 2 Go) · Deno absent · Docker OK, Supabase local démarré (Postgres 17) · git initialisé, aucun commit.

## Avancement par phase

| Phase | État | Notes |
|-------|------|-------|
| 0 — Cadrage & intake        | ✅ fait | Plan v2 validé (D-1 à D-7) |
| 1 — Définition produit      | ✅ fait | `docs/product/user-stories.md` (60 stories), `docs/product/screens.md` (45 fiches) |
| 2 — Planification           | ✅ fait | Backlog, jalons, chemin critique ci-dessous ; risques : plan §10 |
| 3 — Architecture & design   | ✅ fait | Architecture, conception, données, design system ; maquette v1 validée |
| 4 — Implémentation          | ✅ fait | Inc-0 à Inc-13 livrés (paiements réels : clés à fournir) |
| 5 — Qualité & performance   | ✅ fait | `docs/performance.md`, `docs/qa/` ; reste la mesure de fluidité sur votre téléphone |
| 6 — Publication (stores)    | ⬜ à faire | |
| 7 — Documentation           | ⬜ à faire | |
| 8 — Maintenance             | ⬜ à faire | |

> États : ⬜ à faire · 🔄 en cours · ✅ fait · ⏸️ en attente (raison)

## Backlog incréments (incrément vertical = livrable)

| ID | Incrément | Stories (`docs/product/user-stories.md`) | Exigence | Taille | État |
|----|-----------|-------------------------------------------|----------|--------|------|
| Inc-0 | Socle : monorepo, design system, l10n, navigation, Supabase local, CI, VPS + déploiement auto | TRV-02, TRV-03, TRV-04, TRV-06 | §7.A, D-1, D-4 | L | ✅ (VPS ⏸️ accès) |
| Inc-1 | Authentification email / téléphone, profils, rôles, suppression de compte | AUTH-01 à 09 | §2.1, D-3 | L | ✅ |
| Inc-2 | Zones + tarifs (admin), adresses client | ADR-01 à 07 | §2.2, §5.6 | M | ✅ |
| Inc-3 | Profils livreurs, validation admin, gestion utilisateurs | COU-01 à 04, ADM-02 | §2.3, §6.D | M | ✅ |
| Inc-4 | Restaurants et catalogue | RES-01 à 05 | §3.1, §6.C | M | ✅ |
| Inc-5 | Commande de repas (client + restaurant) | ORD-01 à 13 | §3.1, §6.A | L | ✅ |
| Inc-6 | Livraison de colis | PAR-01 à 05 | §3.2 | M | ⏸️ Exclu du produit actuel (ADR-064) ; données historiques conservées |
| Inc-7 | En ligne, attribution, supervision, paramètres | COU-05, DIS-01 à 04, ADM-03, ADM-05 | §4.1 | L | ✅ |
| Inc-8 | Mission livreur, code de livraison, échecs | MIS-01 à 10 | §4.2, §4.5 | L | ✅ |
| Inc-9 | Suivi temps réel, chronologie, notifications | TRK-01 à 03, NOT-01 à 04 | §4.3, §4.4, §4.6 | L | ✅ (push : Firebase à créer) |
| Inc-10 | Espèces, transactions, montants séparés | PAY-01, PAY-02, PAY-06, TRX-01 | §5.3, §5.4, §5.6 | M | ✅ |
| Inc-11 | Mobile Money | PAY-03, PAY-05 | §5.1 | L | ✅ nyole (essai réel : clés de test à fournir) |
| Inc-12 | Carte bancaire Stripe | PAY-04 | §5.2 | M | ✅ Stripe Checkout (essai réel : clés de test à fournir) |
| Inc-13 | Annulations, remboursements, reçus, transactions admin, statistiques | TRX-02, TRX-03, ADM-04, ADM-06 | §5.5, §6.D | M | ✅ (remboursements auto : Inc-11 / 12) |

TRV-01, TRV-05 et TRV-07 (réseau, erreurs, API documentée) s'appliquent à chaque incrément.

## Jalons démontrables

| Jalon | Après | Démonstration |
|-------|-------|---------------|
| J0 | Inc-0 | Les 3 apps démarrent avec le design system ; API en HTTPS sur le VPS ; CI verte |
| J1 — fin INTAKE phase 1 | Inc-3 | Inscription email / téléphone, adresses validées par zone, livreur approuvé par l'admin |
| J2 — fin INTAKE phase 2 | Inc-5 | Commande de repas reçue et préparée par le restaurant |
| J3 — fin INTAKE phase 3 | Inc-9 | Scénarios S1, S2 et S5 de bout en bout en espèces, avec suivi temps réel et notifications |
| J4 — fin INTAKE phase 4 | Inc-13 | Scénarios S3, S4, S6 ; **MVP complet** |
| J5 | Phases 5–7 | Mesures de performance, revue sécurité, builds signés, test interne Google Play |

**Chemin critique** : comptes de paiement (KYC) → Inc-11 / Inc-12 · accès VPS + domaine → tests réels sur téléphone ·
validation de la maquette → code des écrans à partir de l'Inc-1. Registre des risques : `docs/plan-de-realisation.md` §10.

## Décisions ouvertes / questions à l'utilisateur

- [x] Q1/Q2 — Côte d'Ivoire (Abidjan, XOF) ; cartes via Stripe (D-5)
- [x] Q3 — Email ou téléphone + mot de passe, OTP email / SMS (D-3)
- [x] Q4 — Android d'abord (D-6)
- [x] Q5 — Back-office restaurant + admin dans ce projet (D-7)
- [x] Fournisseur Mobile Money : **nyole** (ADR-028)
- [ ] Infos VPS (offre, IP), nom de domaine, nom / logo de l'app — avant Inc-0 (VPS) et la maquette (marque)

## Blocages

- Déploiement continu (GitHub Actions) à ajouter ; copie des sauvegardes hors du VPS manuelle (`docs/deployer-sur-vps.md` § 6).

## Tâches manuelles utilisateur en attente

- voir `docs/manual-tasks.md` (priorité : compte marchand de paiement, à démarrer tôt)

## Journal de session (résumé court, le plus récent en haut)

- 2026-10-21 — Parcours mobile restaurant uniquement (ADR-064) : bouton central redirigé directement vers le catalogue, points d'entrée colis retirés et anciens liens renvoyés vers l'accueil. L'action « Personnaliser » est maintenant visible pour les produits avec options. Palette Tchopi orange harmonisée sur les thèmes clair et sombre (ADR-065).
- 2026-10-20 — Notifications : autorisation demandée à l'ouverture (ADR-041), configuration Firebase dans `Env`,
  `vps.ps1 notifications` (compte de service). Audit avant production (`docs/audit-mise-en-production.md`) : 4 points
  bloquants (inscription publique, signature Play Store, textes juridiques, paiements réels) ; bug corrigé : le
  restaurant voyait « Espèces » pour les commandes payées en ligne. Plateforme web lancée dans `../tchopi-web`.
- 2026-10-20 — Retours d'essai (ADR-040) : admin « Commandes à traiter » limité aux commandes en alerte (attribution
  manuelle et confirmation sans code conservées) ; restaurant notifié « Commande livrée » (migration
  `20261020110000`, message à l'écran des commandes). Analyse et tests Flutter verts ; tests de la base (pgTAP)
  exécutés par la CI (Docker absent sur ce PC).
- 2026-10-20 — Trajets des cartes hébergés (ADR-038) : OSRM v6 sur le VPS (carte Côte d'Ivoire Geofabrik, profil
  voiture, mise à jour chaque dimanche), public sur `https://api.tchopi.com/route/v1/driving/…` ; `ROUTING_URL` par
  défaut sur ce serveur. Essai sur le VPS : préparation 2 min 30 (pic 1,2 Go), service 300 Mo, trajet Abidjan
  6,6 km en 200. Preuves : analyse 0 ; 59 + 64 tests Flutter.

- 2026-10-20 — Paiements prêts pour les comptes marchands, cartographie évaluée (ADR-039) : remboursements signalés
  par nyole (REFUNDED) et refus tardif d'un remboursement Stripe gérés ; `.\vps.ps1 cle-paiement` pour saisir les
  clés ; recherche de lieux (Photon/OSM) sur les cartes de sélection ; « Ouvrir la navigation » pour le livreur.
  « ONGAL » introuvable : nyole conservé (lien fourni). Récapitulatif : `docs/mise-en-service.md` ; évaluation :
  `docs/cartographie.md`. **Paiements non opérationnels** tant que les tests réels ne sont pas faits.
- 2026-10-20 — Refonte design (ADR-038) : thème sombre de la maquette + sélecteur Apparence mémorisé ; choix de
  ville compact (toutes les villes de CI, recherche sans accents) ; quartiers suggérés (adresses, colis, restaurant) ;
  carte de livraison commune (trajet routier, retrait, destination, livreur orienté et animé, fond clair/sombre) ;
  menus, fenêtres et listes harmonisés ; accueil lisible sur petit écran. Vérifié dans le navigateur en clair et en
  sombre, 320 et 375 px : accueil, compte, ville, quartier, suivi (déplacement du livreur), mission livreur.
  Preuves : `check.ps1 -Integration` vert (analyse 0 ; 59 + 64 tests Flutter ; pgTAP ; intégration 3 + 10).
- 2026-10-19 — Prise en charge revue (ADR-037) : commande sans livreur, offre à tous les livreurs éligibles à
  « Prête », premier qui accepte, attente reproposée, alerte restaurant, désistement → reproposée, livreurs
  affiliés (admin), libellés « Livreur en route vers le restaurant ». Procédure : `docs/tester-une-commande.md`.
  Vérifié dans le navigateur : commande R-MC488 passée sans livreur, marquée Prête, livreur passé en ligne → offre
  reçue en plein écran, acceptée, mission ouverte. Corrigé : titre de mission tronqué, accents des comptes de test.
  Preuves : `check.ps1 -Integration` vert (analyse 0 ; 43 + 64 tests Flutter ; pgTAP 259/259 ; intégration 3 + 10).

- 2026-10-19 — Villes (ADR-036) : 10 villes ivoiriennes en plus d'Abidjan, avec tarifs ; tests isolés de ces données.
  Comptes de test sur le serveur : `.\dev-accounts.ps1 -Serveur` (mot de passe aléatoire noté seulement dans
  `env/comptes-serveur.txt`). Preuves : analyse 0 ; 64 + 43 tests Flutter ; pgTAP 261/261 ; intégration 10 + 3.

- 2026-10-19 — Déploiement continu (ADR-035) : job « Déploiement du serveur » dans la CI (main, après les tests),
  clé SSH réservée à GitHub et empreinte du VPS vérifiée, branché par `vps.ps1 ci`. Constaté : la CI ne déployait
  rien jusqu'ici et ce PC n'a pas d'accès SSH au VPS : l'Inc-12 n'est pas encore sur le serveur. Reste à faire par vous :
  `.\vps.ps1 ci` une fois, depuis le PC qui a accès au VPS. Vérifié : syntaxe de `vps.ps1` et `server.sh` ; le job
  ne s'exécutera réellement qu'avec les secrets.

- 2026-10-19 — Inc-12 (branche feat/inc-12-carte, ADR-034) : carte par Stripe Checkout (page hébergée, 3-D Secure),
  même circuit que Mobile Money (couche commune aux fournisseurs), webhook signé + statut relu chez Stripe,
  remboursement automatique des paiements par carte (tâche planifiée → payments-refund), page de retour, carte
  activable par l'admin. Vérifié dans le navigateur avec un Stripe simulé : activation admin, commande R-SV2ZJ par
  carte, page de paiement (2 525 XOF), retour, commande transmise, annulation → « Remboursement effectué » en direct.
  Corrigé à cette occasion : « rien ne vous sera facturé » affiché en annulant une commande déjà payée. Puis fusion
  de main (app à la racine, serveur en ligne) : migration carte renumérotée 20261019160000. Preuves :
  `check.ps1 -Integration` vert (analyse 0 ; 43 + 64 tests Flutter ; pgTAP 261/261 ; intégration 3 + 10). Non
  vérifié : vraie API Stripe (clés de test à fournir), déploiement sur le VPS (`.\vps.ps1 deployer`).

- 2026-10-19 — ADR-033 : zone d'Abidjan et tarifs par migration (déployée), restaurants de démonstration en ligne
  (`vps.ps1 demo` : 3 restaurants, 9 plats, 12 photos) ; carte moderne OpenFreeMap (repli OpenStreetMap), rendu
  vérifié dans le navigateur sur Abidjan. Numéros de test valides : +2250700000001 / 02. Tests 61 + 43, analyse OK.

- 2026-10-19 — ADR-032 (demande utilisateur) : app déplacée à la racine (`lib/`, `android/`… ; paquet `tchopi`),
  serveur en ligne par défaut dans `Env` : `flutter run` suffit. Supprimés : `run.ps1`, `phone.ps1`, guide Wi-Fi,
  `vps.ps1 config`. Scripts, CI, hook et docs adaptés. Vérifié : analyse sans problème, tests 61 (app) + 42 (core).
  Inscription : l'app ne propose que les modes actifs sur le serveur (téléphone seul tant que le SMTP manque) ; message
  clair si un email est refusé (`email_provider_disabled`).

- 2026-10-19 — Back-end déployé sur le VPS (ADR-031) : https://api.tchopi.com (nginx de l'hôte + certbot), Supabase
  officiel figé `self-hosted/v0.8.3` allégé (7 conteneurs `tchopi-*`, ~660 Mo), pilote fermé (numéros autorisés avec
  code, pas de SMS), sauvegardes quotidiennes ; outils `vps.ps1` (PC, une clé SSH par PC) + `infra/server.sh` ; APK de
  test `phone.ps1` (serveur en ligne par défaut, `-Local` pour le PC) ; message clair si l'envoi du SMS échoue. Testé d'abord dans Docker sur le PC (inscription
  autorisée / refusée, admin, fonctions, temps réel, fichiers, Studio à la demande, pg_dump, redéploiement sans
  rejeu). Sur le VPS : 14 migrations, 7 services sains, API joignable en HTTPS, autres sites du serveur intacts.

- 2026-10-19 — Phase 5 (ADR-030) : APK arm64 22,5 Mo (< 25) ; photos décodées à la taille affichée et en cache
  disque ; 9 index de clés étrangères ; tests petit écran + police 130 % (7 écrans, aucun débordement) ; charge
  (Node) 1/20/50 utilisateurs sans échec, p95 ≤ 240 ms ; lint base sans alerte, RLS sur les 25 tables. Vérifié dans le
  navigateur : couvertures et vignettes nettes. Preuves : `check.ps1 -Integration` vert (analyse 0 ; 42 + 61 tests
  Flutter ; pgTAP 246/246 ; intégration 3 + 9). Non mesuré : démarrage et 60 i/s sur téléphone réel (commande dans
  `docs/performance.md`).

- 2026-10-19 — ADR-029 (demande utilisateur) : l'Administration n'est plus proposée dans « Changer d'espace » ;
  un compte admin arrive directement dans l'Admin et n'en sort pas (écrans Admin et « Mon compte » seulement).
  Client, Livreur et Restaurant restent cumulables. Installation sur téléphone : `phone.ps1` + guide
  `docs/installer-sur-telephone.md`. Vérifié dans le navigateur (format téléphone) : compte livreur → Client et
  Livreur seulement ; même compte rendu admin → tableau de bord direct, `/spaces` et `/home` renvoyés à l'Admin,
  « Mon compte » sans changement d'espace ; rôle retiré → retour à l'espace Client, `/admin` refusé. Preuves :
  analyse 0 problème ; 57 + 41 tests Flutter.
  Puis, après retour utilisateur sur téléphone : écrans d'accès refaits (photo + marque en haut, formulaire sur
  feuille, bouton sous les champs) ; comptes de test par profil (`dev-accounts.ps1`) ; inscription locale ouverte aux
  numéros 07 00 00 00 01 à 09 (code 123456 ; les autres numéros échouaient faute de SMS). Vérifié : connexion des
  4 comptes avec leurs rôles, inscription + code par l'API, connexion du client dans le navigateur.

- 2026-10-19 — Inc-11 (branche feat/inc-11-mobile-money, ADR-028) : Mobile Money par nyole (page hébergée, commande en
  attente de paiement, webhook signé + statut relu chez nyole, refus / nouvel essai, changement de moyen, expiration
  15 min, paiement tardif à rembourser), choix du moyen pour les colis, activation admin. Vérifié dans le navigateur
  avec un nyole simulé envoyant de vrais webhooks signés : activation admin, commande Mobile Money, page de paiement,
  refus affiché puis succès reçu en direct (commande transmise, « Mobile Money · Payée », reçu avec référence),
  changement de moyen (commande annulée, panier restauré). Corrigé à cette occasion : code de livraison affiché avant
  paiement, bouton de confirmation trop long. Non vérifié : vraie API nyole (clés de test à fournir, tâche n° 1).
  Preuves : analyse 0 problème ; tests Flutter ; pgTAP 246/246 ; intégration de bout en bout (Edge Functions + nyole
  simulé).

- 2026-10-19 — Inc-13 (branche feat/inc-13-transactions, ADR-027) : circuit de remboursement (à rembourser d'office
  après annulation d'une commande payée, décision de l'admin après un échec, « Remboursée » avec référence,
  notifications), reçu partageable, historique groupé par jour, tableau de bord admin, filtres des transactions.
  Vérifié dans le navigateur : Paiements et reçu du client (copie), tableau de bord (2 commandes, 2 275 F, espèces
  4 550 F, 1 remboursement), demande puis marquage du remboursement par l'admin avec chronologie à jour en direct,
  filtre « Remboursements » du client. Corrigé à cette occasion : message « Reçu copié » caché sous les feuilles,
  libellé « Motif » sur la référence de remboursement, sous-total affiché pour un colis, état du paiement absent du
  suivi en direct. Preuves : analyse 0 problème ; tests Flutter ; pgTAP 226/226 ; 4 tests d'intégration réels
  (dont remboursement et statistiques).

- 2026-10-19 — Inc-10 (branche feat/inc-10-especes, ADR-026) : moyens de paiement par pays, transactions (en
  attente → réussie à l'encaissement, annulée sinon), versements d'espèces par l'admin. Vérifié dans le navigateur :
  Paiements du client (En attente, Annulée, Réussie), admin Transactions, Espèces (Koffi doit 5 525 F → versement
  5 000 F → reste 525 F), moyens de paiement « Bientôt ». Corrigé à cette occasion : numéro de commande des
  transactions lu au mauvais champ (affichait le statut). Non vérifié à l'écran : refus quand aucun moyen n'est actif
  (couvert par tests). Preuves : analyse 0 problème ; 41 + 49 tests Flutter ; pgTAP 213/213 ; 3 + 7 tests
  d'intégration réels (transactions réussie et annulée).

- 2026-10-19 — Inc-9 (branche feat/inc-9-suivi, ADR-025) : position et photo du livreur visibles du client pendant
  la commande, estimation d'arrivée, position ancienne grisée, bandeau de connexion perdue, chronologie côté livreur
  et restaurant ; file de notifications par déclencheur, fonction `push` (FCM) appelée par la base, appareils,
  autorisation après explication, bip navigateur pour le restaurant. Vérifié : chaîne événement → file → pg_net →
  fonction (« non configurée » sans Firebase) ; dans le navigateur, suivi R-BX4X5 en route (carte, « environ
  7 min »), position vieillie → grisée « il y a 3 min · estimation indisponible » en direct, chronologie restaurant ;
  APK Android compilé avec Firebase. Non vérifié : réception réelle d'une notification (projet Firebase à créer,
  tâche manuelle n° 8). Preuves : analyse 0 problème ; 39 + 45 tests Flutter ; pgTAP 197/197 ; 3 + 7 tests
  d'intégration réels (position du livreur reçue en direct par le client, notifications en file).

- 2026-10-19 — Inc-8 (branche feat/inc-8-mission, ADR-024) : étapes de mission côté serveur, code à essais limités
  (blocage + alerte, confirmation admin sans code), registre des espèces, problèmes / échec, abandon, remise par le
  restaurant, gains du jour et historique ; écrans Mission, Code, Problème, Historique ; alertes admin. Vérifié dans
  le navigateur (livreur, position simulée) : offre → mission, refus « pas prête », récupération, en route, code faux
  (4 essais restants) puis juste, encaissement 5 525 F, fin (+1 075 F), tableau de bord et historique à jour ; écran
  « session expirée » du correctif précédent. Corrigé à cette occasion : double appui sur Accepter, en-tête de
  mission qui débordait, carte non recentrée à l'étape suivante, libellés d'itinéraire tronqués. Non vérifié à
  l'écran : remise par le restaurant, confirmation admin sans code (couverts par tests). Preuves : analyse 0 problème ;
  39 + 40 tests Flutter ; pgTAP 182/182 ; 3 + 7 tests d'intégration réels (mission complète jusqu'à l'encaissement).

- 2026-10-18 — Correctif (branche feat/inc-7-attribution) : au chargement du compte, une session refusée ou un compte
  supprimé n'est plus présenté comme une coupure réseau (message exact, « Se reconnecter »). Constaté dans le
  navigateur après une réinitialisation de la base locale. Preuves : analyse 0 problème ; 39 + 34 tests Flutter ;
  pgTAP 147/147 ; 3 + 7 tests d'intégration réels (dont compte supprimé → « session expirée »).

- 2026-10-18 — Inc-7 (branche feat/inc-7-attribution, ADR-023) : paramètres de la plateforme, mise en ligne et
  position des livreurs, offres de 45 s au plus proche, refus / expiration → suivant, alerte 10 min et annulation
  30 min sans livreur (tâche toutes les 10 s), attribution manuelle ; plus de commande sans livreur en ligne ;
  écrans Livreur (tableau de bord, offre plein écran), suivi client (livreur, « toujours sans livreur »), Admin
  (Commandes en cours, détail, attribution, Paramètres). Vérifié dans le navigateur (deux comptes) : livreur en ligne,
  commande R-UKGXB acceptée puis en préparation, offre reçue en direct (+1 075 F, 45 s), acceptée, livreur visible du
  client, supervision, attribution, paramètres enregistrés et tracés. Position simulée dans le navigateur intégré
  (géolocalisation refusée par celui-ci ; message d'erreur prévu affiché). Corrigé à cette occasion : message
  d'erreur persistant par-dessus l'offre, bouton d'appel illisible, libellé des filtres. Preuves : analyse 0 problème ;
  36 + 34 tests Flutter ; pgTAP 147/147 ; 3 + 7 tests d'intégration réels (dont offre reçue en temps réel et acceptée).
  Non vérifié : notification permanente et suivi GPS sur un vrai téléphone Android.

- 2026-10-18 — Inc-6 (branche feat/inc-6-colis, ADR-022) : types de colis, devis et demande serveur, codes de
  livraison (aussi pour les repas), annulation colis ; écran 4 étapes, suivi avec code et partage. Vérifié dans le
  navigateur (format téléphone) : 4 étapes, liste des objets interdits, case obligatoire, devis 800 F, demande C-BL87T
  créée avec code, annulation. Corrigé à cette occasion : départ = arrivée accepté (refusé sous 100 m), décimales
  « 0.5 km », textes d'annulation et d'espèces des colis. Preuves : analyse 0 problème ; 36 + 23 tests Flutter ;
  pgTAP 109/109 ; 3 + 6 tests d'intégration verts. Reporté à l'Inc-7 : types selon les moyens de transport disponibles,
  refus sans livreur en ligne, retrait de l'offre à l'annulation.

- 2026-10-18 — Refonte de structure (ADR-021) avant l'Inc-6 : barres du haut, accueil maquette, navigation basse
  Client + Paiements, recherche (ORD-03), espace Restaurant enrichi, profil, états vides. Preuves : analyse 0 problème ;
  35 + 22 tests Flutter ; vérifié dans Chrome (accueil, paiements, suivi, profil, restaurant).

- 2026-10-18 — Inc-5 (branche feat/inc-5-commandes, ADR-020) : commandes, devis et création serveur, machine à états,
  refus auto (pg_cron), temps réel ; panier, validation, suivi, historique ; écran Commandes du restaurant.
  Preuves : analyse 0 problème ; 35 + 22 tests Flutter ; pgTAP 94/94 ; 5 tests d'intégration app verts dont commande
  réelle (double envoi, réception en direct, acceptation) ; parcours vérifié dans Chrome (ajout au panier, devis 1 525 F
  de frais, commande R-GWG8R, réception et acceptation côté restaurant, statut mis à jour sur l'accueil).
  Note : le test d'intégration core « téléphone » échoue tant que le compte 07 00 00 00 01 existe (passe après db reset).

- 2026-10-18 — Refonte visuelle après retour utilisateur (ADR-019) : thème clair imposé, bienvenue claire, carte
  OpenStreetMap (flutter_map) avec épingle animée, accueil client et fiche restaurant, motifs teintés sans photo,
  restaurants de démonstration (seed local). Bug corrigé : tris inversés (Supabase trie en décroissant par défaut).
  Preuves : analyse 0 problème ; 35 + 15 tests Flutter verts ; pgTAP vert ; parcours vérifié dans Chrome au format téléphone
  (inscription par téléphone, accueil, fiche restaurant, carte réelle, adresse enregistrée dans la zone).
  Non vérifié : affichage sur appareil Android.
  Puis photos intégrées (bienvenue, 3 couvertures, 9 produits), vérifiées dans Chrome.

- 2026-10-18 — Inc-4 : restaurants (création et commission par l'admin, gérants invités par email ou numéro),
  espace Restaurant (menu, catégories, produits avec photo, disponibilité, archivage, profil, horaires, fermeture
  temporaire), écran admin Restaurants. Exécution par l'utilisateur sous Windows PowerShell : scripts `run.ps1`,
  `check.ps1`, `dev-admin.ps1`, README réécrit sans `&&`, lancement conseillé dans Chrome (aucun appareil Android
  branché). Preuves : `check.ps1` vert (analyse 0 problème ; 59 tests Flutter ; pgTAP 70/70) ; 7 tests d'intégration
  réels dont restaurants. Non vérifié : affichage à l'écran (lancement local arrêté à la demande de l'utilisateur).

- 2026-10-18 — Réorganisation en **une seule app** `apps/mobile` avec espaces par rôle (ADR-016), puis Inc-3 : profil
  livreur (zone, moyen de transport, photo privée), statut, validation / refus / suspension par l'admin, gestion des
  comptes (recherche, suspension avec blocage de connexion, changement d'identifiant), journal d'audit. Preuves :
  analyse 0 problème ; 56 tests Flutter ; pgTAP 52/52 ; 6 tests d'intégration réels. Non vérifié : affichage sur
  appareil (lancement local arrêté à la demande de l'utilisateur).

- 2026-10-18 — Inc-2 (branche feat/inc-2-adresses) : zones desservies et règles tarifaires (PostGIS, calcul des frais
  serveur arrondi à 25 F, simulateur admin), adresses client (carte, GPS, quartier, repère, défaut, refus hors zone),
  écran Zones et tarifs du back-office, ville du profil choisie parmi les zones. Preuves : analyse 0 problème ;
  51 tests Flutter ; pgTAP 35/35 ; 5 tests d'intégration réels (comptes, adresses, zones admin). Non vérifié : affichage
  de la carte (clé Google Maps absente) ; APK non recompilé après la correction Gradle (lancement local arrêté à la
  demande de l'utilisateur, la CI compilera).

- 2026-10-18 — Inc-1 (branche feat/inc-1-auth) : inscription / connexion email ou téléphone + mot de passe, codes OTP
  (email via modèles FR, SMS via numéros de test en local), profil obligatoire, compte (modification, changement
  d'identifiant, déconnexion, suppression avec anonymisation), accès par rôle (back-office réservé aux admins pour
  l'instant). Preuves : analyse 0 problème ; 47 tests Flutter ; pgTAP 17/17 ; 3 tests d'intégration réels contre
  Supabase local (email, doublon, téléphone, mot de passe oublié, suppression) ; parcours vérifié sur émulateur.
  La ville est saisie librement en attendant les zones (Inc-2).

- 2026-10-18 — Supabase local démarré ; migration appliquée ; pgTAP 3/3 verts ; env/local.json créé (non versionné).

- 2026-10-18 — Inc-0 : workspace Dart (3 apps + core), design system en code (contrastes AA testés), police embarquée,
  textes FR, navigation, Supabase avec session sécurisée, écran de bienvenue, migration + test pgTAP (non exécuté :
  Docker en panne), CI GitHub Actions (non exécutée : pas de dépôt), hooks Git. Preuves : analyse 0 problème, 28 tests
  verts, 2 APK + web compilés, app Client lancée sur émulateur en mode optimisé (67 Mo de mémoire).

- 2026-10-18 — Phases 1 à 3 : user stories, fiches écran, backlog et jalons, architecture, conception système, modèle de
  données + RLS + API métier, design system, maquette interactive v1 publiée. Aucun code applicatif encore.
- 2026-10-18 — Précisions utilisateur intégrées (design, API web, email + mot de passe, VPS Hostinger) ; réponses :
  CI + Stripe, Android d'abord, back-office inclus ; plan v2 validé.
- 2026-10-18 — Lecture de l'INTAKE et des skills ; plan de réalisation, hypothèses H-01…H-20, questions Q1–Q4,
  ADR initiaux et tâches manuelles rédigés.
