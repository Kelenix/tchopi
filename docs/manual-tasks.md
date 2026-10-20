# Tâches manuelles (à faire par vous)

> Ce que Claude ne peut pas faire à votre place : création de comptes, contrats, paiements, signatures.
> Classées par urgence. Les étapes détaillées et les variables exactes seront complétées à l'incrément concerné.
> Ne collez **jamais** de mot de passe ni de clé secrète dans le chat ou le code : vous les saisirez vous-même dans le
> fichier `.env` du VPS ou dans les secrets GitHub (procédure fournie au moment voulu).

---

## 1. Ouvrir les comptes de paiement — ⚠️ à démarrer tout de suite
- **Pourquoi** : encaisser cartes (Stripe, Inc-12) et Mobile Money (Inc-11). La vérification d'entreprise (KYC) peut prendre plusieurs semaines.
- **Guide complet** (clés, webhooks, tests avant production) : `docs/mise-en-service.md`. Les clés se saisissent avec
  `.\vps.ps1 cle-paiement <NOM>` (saisie masquée, jamais dans le chat ni le code).
- **Quand** : maintenant.
- **Étapes** :
  1. **Stripe** (cartes, ADR-034) : compte au nom de votre société (pays compatible) ; activer les paiements par carte.
     - **Essai local** : dans `supabase/functions/.env`, `STRIPE_API_URL=https://api.stripe.com`,
       `STRIPE_SECRET_KEY=sk_test_…` ; webhook avec la Stripe CLI (`stripe listen --forward-to
       http://127.0.0.1:54321/functions/v1/payments-webhook-stripe`), dont le secret `whsec_…` va dans
       `STRIPE_WEBHOOK_SECRET` ; puis `supabase stop` et `supabase start`. Carte de test Stripe : 4242 4242 4242 4242.
     - **Serveur** : dans le `.env` du VPS (`/opt/tchopi/supabase/.env`), `STRIPE_SECRET_KEY` (`sk_live_…` après
       vérification) et `STRIPE_WEBHOOK_SECRET` ; dans le tableau de bord Stripe → Développeurs → Webhooks, URL
       `https://api.tchopi.com/functions/v1/payments-webhook-stripe`, événements `checkout.session.completed`,
       `checkout.session.expired`, `refund.updated` et `refund.failed` ; clés saisies avec `.\vps.ps1 cle-paiement`.
     - Activer « Carte bancaire » dans Admin → Paramètres. Les remboursements par carte sont automatiques.
  2. **Mobile Money — nyole** (retenu, ADR-028) : dans https://app.nyole.com/developer, vérifier que votre compte
     affiche des **clés API** (la doc nyole indique que les comptes ouverts après le 17/10/2026 passent par LinkAfr,
     Griotia ou Wapilot : si vous n'avez pas de clés, contactez nyole). Ensuite :
     - **Essai local** : copiez la clé **secrète de test** (`af_test_sec_…`) dans `supabase/functions/.env`
       (`NYOLE_API_URL=https://app.nyole.com/api`, `NYOLE_SECRET_KEY=…`), puis `supabase stop` et `supabase start`.
       Ne la collez jamais dans le chat ni dans le code. Sur la page de paiement, les boutons « simuler » valident
       ou refusent ; dans l'app, « J'ai payé : vérifier » relit le statut (nyole ne peut pas joindre votre PC).
     - **Serveur** : `.\vps.ps1 cle-paiement NYOLE_SECRET_KEY` (`af_test_sec_…` pour les essais, `af_live_sec_…`
       après vérification d'identité) et `.\vps.ps1 cle-paiement NYOLE_RETURN_URL` ; dans le tableau de bord nyole,
       URL du webhook `https://api.tchopi.com/functions/v1/payments-webhook-nyole`, événements `payment.completed`,
       `payment.failed`, `payment.cancelled` (à cocher) et `payment.updated`.
     - Activer « Mobile Money » dans Admin → Paramètres.
  3. Soumettre les documents demandés (registre de commerce, pièce du dirigeant, compte bancaire) ; les clés de production viendront après le KYC.
  4. Vérifier avec votre conseil les obligations liées à l'encaissement par une société étrangère pour une activité en Côte d'Ivoire.
- **Coût** : pas d'abonnement ; commissions par transaction (grille Stripe ; nyole : 5 % par paiement réussi, retraits vers votre Mobile Money 2,5 %, minimum 500 F).
- **Vérification** : un paiement de test passe à l'état « Réussie » dans l'app après réception du webhook.

## 2. Préparer le VPS Hostinger et le nom de domaine
- **Pourquoi** : héberger Supabase (base de données, authentification, fichiers, fonctions) et exposer l'API en HTTPS.
- **Quand** : Inc-0 (le développement démarre en local en attendant).
- **Étapes** :
  1. Offre VPS avec **8 Go de RAM** recommandés (4 Go minimum), centre de données en **Europe** (le plus proche de l'Afrique de l'Ouest).
  2. Système : **Ubuntu 24.04 LTS** (le modèle Hostinger « Supabase » convient aussi).
  3. Chez votre registraire, créer l'enregistrement DNS `A` : `api.<votre-domaine>` → IP du VPS.
  4. Sur le PC : `.\vps.ps1 cle <IP>`, enregistrer la **clé SSH** affichée sur le VPS (hPanel → VPS → Console web),
     puis `.\vps.ps1 installer api.<votre-domaine>`. Aucun mot de passe à partager. Détails : `docs/deployer-sur-vps.md`.
- **Coût** : votre offre VPS actuelle ; domaine ≈ 10 $/an si vous n'en avez pas.
- **Vérification** : `https://api.<votre-domaine>` répond avec un certificat valide.

## 3. Créer le dépôt GitHub
- **Pourquoi** : versionner le code, exécuter la CI et déployer automatiquement sur le VPS.
- **Quand** : Inc-0.
- **Étapes** : 1. Créer un dépôt **privé** vide sur GitHub. 2. Donner son URL à Claude (le premier envoi se fera avec votre accord).
  3. Ajouter les secrets de déploiement demandés (Settings → Secrets) en suivant la procédure fournie.
- **Coût** : gratuit.
- **Vérification** : la CI s'exécute sur le premier envoi.

## 4. Préparer un téléphone ou un émulateur Android de test
- **Pourquoi** : tester sur un Android modeste (cible principale) et mesurer la fluidité.
- **Quand** : Inc-0.
- **Étapes** : 1. Activer le mode développeur et le débogage USB sur un téléphone Android (idéalement d'entrée de gamme), **ou**
  2. créer un émulateur (Android Studio → Device Manager) avec 2 Go de mémoire.
- **Coût** : gratuit.
- **Vérification** : `flutter devices` affiche l'appareil.

## 5. Configurer l'envoi d'emails (codes OTP par email)
- **Pourquoi** : vérification des comptes email et récupération du mot de passe (Inc-1).
- **Quand** : avant les premiers tests réels de connexion (en local, les emails sont capturés sans envoi réel).
- **Étapes** : 1. Créer une adresse d'envoi (ex. `no-reply@<votre-domaine>`) avec la messagerie Hostinger, ou un service d'envoi
  (offre gratuite). 2. Noter l'hôte SMTP, le port, l'utilisateur ; vous saisirez le mot de passe dans le `.env` du VPS.
  3. Configurer SPF, DKIM et DMARC du domaine (évite le classement en spam).
- **Coût** : inclus dans la messagerie Hostinger, ou offre gratuite du service choisi.
- **Vérification** : le code arrive en boîte de réception (pas en spam).

## 6. Configurer l'envoi de SMS (optionnel au lancement)
- **Pourquoi** : inscription et récupération par téléphone. Sans SMS, seule la connexion email est proposée.
- **Quand** : quand vous souhaitez activer la connexion par téléphone.
- **Étapes** : 1. Twilio (Verify, canal SMS ou WhatsApp) **ou** une passerelle SMS locale disposant d'une API HTTP.
  2. Saisir les identifiants dans le `.env` du VPS. 3. Déclarer des **numéros de test** (code fixe) pour la revue des stores.
- **Coût** : par code envoyé, variable selon le pays et le fournisseur.
- **Vérification** : un SMS est reçu et la connexion aboutit.

## 7. Fond de carte : passer à Google Maps (facultatif, plus tard)
- **Aujourd'hui** : carte moderne OpenFreeMap (ADR-033), gratuite sans limite, sans clé ni compte : rien à faire.
- **Pourquoi changer** : Google Maps affiche davantage de commerces et de lieux à Abidjan.
- **Quand** : seulement si vous acceptez un compte Google Cloud avec carte bancaire.
- **Étapes** : 1. Créer un projet sur https://console.cloud.google.com et un compte de facturation. 2. Activer « Maps SDK
  for Android », « Maps SDK for iOS » et « Maps JavaScript API ». 3. Créer une clé API, restreinte à l'app
  `com.tchopi.mobile` (Android / iOS) et aux sites `tchopi.com` (web). 4. La communiquer à Claude, qui adapte les cartes.
- **Coût** : cartes gratuites sur Android et iOS ; version navigateur gratuite jusqu'à 10 000 affichages par mois, puis
  payante.
- **Vérification** : la carte Google s'affiche dans l'écran « Nouvelle adresse ».

## 8. Créer le projet Firebase (notifications push)
- **Pourquoi** : notifications client, livreur, restaurant — Inc-9.
- **Quand** : Inc-9.
- **Étapes** : 1. https://console.firebase.google.com → nouveau projet. 2. Ajouter l'app Android
  (`com.tchopi.mobile`) ; dans les paramètres du projet, relever **clé d'API web**, **ID d'application**, **ID de
  l'expéditeur** et **ID du projet** — ✅ fait le 2026-10-20 : valeurs publiques inscrites dans
  `packages/core/lib/src/config/env.dart`, aucun fichier `google-services.json` n'est nécessaire. 3. Comptes de service → « Générer une nouvelle clé privée » :
  ranger le fichier JSON dans `env\` (ignoré par git), jamais dans le chat. 4. `.\vps.ps1 notifications` : le
  fichier part sur le serveur sans être affiché (`FCM_SERVICE_ACCOUNT`) ; l'adresse et la clé de la fonction `push`
  sont mises dans le coffre de la base.
- **Coût** : gratuit.
- **Vérification** : une notification de test arrive sur le téléphone.

## 9. Fournir le nom, le logo et les visuels de marque
- **Pourquoi** : identité de l'app (écrans, icône, fiches stores) — maquette de la phase 3.
- **Quand** : avant la maquette (phase 3) ; sinon un nom de travail est utilisé et remplacé plus tard.
- **Étapes** : 1. Nom de l'app. 2. Logo (SVG ou PNG 1024 px). 3. Facultatif : photos de plats locaux dont vous détenez les droits.
  4. Confirmer les identifiants d'application (provisoire : `com.tchopi.mobile`) :
  ils deviennent **définitifs** dès la première publication sur Google Play.
- **Coût** : éventuel graphiste.
- **Vérification** : icône et nom affichés sur le téléphone.

## 10. Rédiger les textes juridiques
- **Pourquoi** : obligatoires pour les stores et pour traiter des données personnelles (téléphone, email, position, adresses).
- **Quand** : avant la phase 6 (publication).
- **Étapes** : 1. CGU / conditions de service (dont la liste des objets autorisés pour les colis). 2. Politique de confidentialité
  publiée à une URL publique. 3. Vérifier les formalités de protection des données du pays de lancement (en Côte d'Ivoire : ARTCI).
  Claude fournira un canevas ; la validation juridique vous revient.
- **Coût** : éventuel conseil juridique.
- **Vérification** : URL accessible et renseignée dans les fiches stores.

## 11. Ouvrir les comptes développeur des stores
- **Pourquoi** : publier les apps (phase 6).
- **Quand** : Google Play dès la phase 4 (test interne possible tôt) ; Apple si Q4 = B.
- **Étapes** : 1. Google Play Console (vérification d'identité incluse). 2. Apple Developer Program (si iOS).
  3. À la première soumission, remplir dans la Play Console « Contenu de l'application » : **déclaration des
  services de premier plan** (type « localisation » : position du livreur en ligne, avec notification permanente)
  et **accès à la localisation** (pendant l'utilisation seulement). Claude fournira le texte et la courte vidéo
  demandés.
- **Coût** : Google Play 25 $ (une fois) ; Apple 99 $/an.
- **Vérification** : accès à la console et création de la fiche de l'app.

## 12. Créer le premier administrateur
- **Pourquoi** : l'admin crée ensuite les restaurants et valide les livreurs.
- **Quand** : après le premier déploiement sur le VPS (Inc-3).
- **Étapes** : `.\vps.ps1 testeur <numéro> <code>`, inscription dans l'app avec ce numéro, puis `.\vps.ps1 admin <numéro>`
  (`docs/deployer-sur-vps.md` § 3).
- **Coût** : gratuit.
- **Vérification** : connexion au back-office avec l'espace Admin visible.
