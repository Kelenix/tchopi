# État du projet — PROJECT_STATE

> Mis à jour par Claude à la fin de chaque phase / incrément. Permet de **reprendre** le
> travail à tout moment, même dans une nouvelle session. Toujours lire ce fichier avant d'agir.

## Snapshot

- **Phase courante** : 4 — Implémentation · Inc-0 (socle) livré, sauf déploiement VPS (accès non fourni)
- **Dernière mise à jour** : 2026-10-18
- **Santé** : 🟢 OK · accès VPS et dépôt GitHub non fournis
- **Prochaine action** : Inc-7 (en ligne, attribution, supervision, paramètres)
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
| 4 — Implémentation          | 🔄 en cours | Inc-0 à Inc-5 livrés ; app unique (ADR-016) |
| 5 — Qualité & performance   | ⬜ à faire | Scénarios S1–S6 |
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
| Inc-6 | Livraison de colis | PAR-01 à 05 | §3.2 | M | ✅ |
| Inc-7 | En ligne, attribution, supervision, paramètres | COU-05, DIS-01 à 04, ADM-03, ADM-05 | §4.1 | L | ⬜ |
| Inc-8 | Mission livreur, code de livraison, échecs | MIS-01 à 10 | §4.2, §4.5 | L | ⬜ |
| Inc-9 | Suivi temps réel, chronologie, notifications | TRK-01 à 03, NOT-01 à 04 | §4.3, §4.4, §4.6 | L | ⬜ |
| Inc-10 | Espèces, transactions, montants séparés | PAY-01, PAY-02, PAY-06, TRX-01 | §5.3, §5.4, §5.6 | M | ⬜ |
| Inc-11 | Mobile Money | PAY-03, PAY-05 | §5.1 | L | ⬜ |
| Inc-12 | Carte bancaire Stripe | PAY-04 | §5.2 | M | ⬜ |
| Inc-13 | Annulations, remboursements, reçus, transactions admin, statistiques | TRX-02, TRX-03, ADM-04, ADM-06 | §5.5, §6.D | M | ⬜ |

TRV-01, TRV-05 et TRV-07 (réseau, erreurs, API documentée) s'appliquent à chaque incrément.

## Jalons démontrables

| Jalon | Après | Démonstration |
|-------|-------|---------------|
| J0 | Inc-0 | Les 3 apps démarrent avec le design system ; API en HTTPS sur le VPS ; CI verte |
| J1 — fin INTAKE phase 1 | Inc-3 | Inscription email / téléphone, adresses validées par zone, livreur approuvé par l'admin |
| J2 — fin INTAKE phase 2 | Inc-6 | Commande de repas reçue et préparée par le restaurant ; demande de colis estimée et confirmée (espèces) |
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
- [ ] Fournisseur Mobile Money (Paystack ou CinetPay selon l'éligibilité de la société) — **avant Inc-11**
- [ ] Infos VPS (offre, IP), nom de domaine, nom / logo de l'app — avant Inc-0 (VPS) et la maquette (marque)

## Blocages

- Accès VPS + domaine non fournis → déploiement automatique non construit (sera fait et testé dès l'accès).

## Tâches manuelles utilisateur en attente

- voir `docs/manual-tasks.md` (priorité : compte marchand de paiement, à démarrer tôt)

## Journal de session (résumé court, le plus récent en haut)

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
  Supabase local (email, doublon, téléphone, mot de passe oublié, suppression) ; parcours vérifié sur émulateur
  (captures docs/design/captures-inc1-*.png). La ville est saisie librement en attendant les zones (Inc-2).

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
