# Journal de décisions (DECISION_LOG)

> ADR léger. Chaque décision structurante prise par Claude **en autonomie** y est consignée :
> contexte → décision → alternatives écartées → conséquences. Permet de tracer et de contester.
> Format inspiré des Architecture Decision Records. Le plus récent en haut.

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
- **Statut** : Accepté (le back-office dépend de Q5 ; défaut : inclus)
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
