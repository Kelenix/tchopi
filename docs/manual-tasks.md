# Tâches manuelles (à faire par vous)

> Ce que Claude ne peut pas faire à votre place : création de comptes, contrats, paiements, signatures.
> Classées par urgence. Les étapes détaillées et les variables exactes seront complétées à l'incrément concerné.
> Ne collez **jamais** de mot de passe ni de clé secrète dans le chat ou le code : vous les saisirez vous-même dans le
> fichier `.env` du VPS ou dans les secrets GitHub (procédure fournie au moment voulu).

---

## 1. Ouvrir les comptes de paiement — ⚠️ à démarrer tout de suite
- **Pourquoi** : encaisser cartes (Stripe, Inc-12) et Mobile Money (Inc-11). La vérification d'entreprise (KYC) peut prendre plusieurs semaines.
- **Quand** : maintenant.
- **Étapes** :
  1. **Stripe** : compte au nom de votre société (pays compatible) ; activer les paiements par carte ; récupérer les **clés de test**.
  2. **Mobile Money** : demander à **Paystack** si votre société peut ouvrir un compte marchand pour la Côte d'Ivoire
     (Orange Money, MTN, Wave) ; à défaut, **CinetPay**. Communiquer le fournisseur retenu à Claude avant l'Inc-11.
  3. Soumettre les documents demandés (registre de commerce, pièce du dirigeant, compte bancaire) ; les clés de production viendront après le KYC.
  4. Vérifier avec votre conseil les obligations liées à l'encaissement par une société étrangère pour une activité en Côte d'Ivoire.
- **Coût** : pas d'abonnement ; commissions par transaction (grilles Stripe et du fournisseur Mobile Money ; ex. 1,95 % Mobile Money annoncé par Paystack en CI).
- **Vérification** : un paiement de test passe à l'état « Réussie » dans l'app après réception du webhook.

## 2. Préparer le VPS Hostinger et le nom de domaine
- **Pourquoi** : héberger Supabase (base de données, authentification, fichiers, fonctions) et exposer l'API en HTTPS.
- **Quand** : Inc-0 (le développement démarre en local en attendant).
- **Étapes** :
  1. Offre VPS avec **8 Go de RAM** recommandés (4 Go minimum), centre de données en **Europe** (le plus proche de l'Afrique de l'Ouest).
  2. Système : **Ubuntu 24.04 LTS** (le modèle Hostinger « Supabase » convient aussi).
  3. Ajouter la **clé SSH publique** que Claude générera sur votre PC (hPanel → VPS → Paramètres → Clés SSH). Aucun mot de passe à partager.
  4. Communiquer l'**adresse IP** du VPS.
  5. Chez votre registraire, créer l'enregistrement DNS `A` : `api.<votre-domaine>` → IP du VPS.
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

## 7. Choisir le fournisseur de fond de carte (avant la publication)
- **Pourquoi** : les cartes (adresses, colis, suivi) utilisent des tuiles OpenStreetMap (ADR-019). En développement, l'app
  lit les serveurs publics d'OpenStreetMap, dont la politique d'usage interdit le trafic d'une app publiée.
- **Quand** : avant les tests réels à grande échelle et la publication (phase 6).
- **Étapes** : 1. Choisir un fournisseur de tuiles OpenStreetMap (ex. MapTiler, Stadia Maps) **ou** héberger ses propres
  tuiles sur le VPS. 2. Récupérer l'URL des tuiles (`…/{z}/{x}/{y}.png`), avec sa clé si le fournisseur en demande une
  (clé publique, restreinte au domaine / à l'app chez le fournisseur). 3. L'ajouter dans `env/prod.json` :
  `"MAP_TILES_URL": "https://…/{z}/{x}/{y}.png"`.
- **Coût** : offres gratuites limitées, puis payantes selon le trafic ; l'hébergement sur le VPS évite l'abonnement mais
  demande de l'espace disque et de la maintenance.
- **Vérification** : la carte s'affiche dans l'écran « Nouvelle adresse » de la version de production.

## 8. Créer le projet Firebase (notifications push)
- **Pourquoi** : notifications client, livreur, restaurant — Inc-9.
- **Quand** : Inc-9.
- **Étapes** : 1. https://console.firebase.google.com → nouveau projet. 2. Ajouter l'app Android
  (`com.tchopi.mobile`) ; dans les paramètres du projet, relever **clé d'API web**, **ID d'application**, **ID de
  l'expéditeur** et **ID du projet**, à reporter dans `env/<environnement>.json` (`FIREBASE_API_KEY`,
  `FIREBASE_APP_ID`, `FIREBASE_SENDER_ID`, `FIREBASE_PROJECT_ID`) — valeurs publiques, aucun fichier
  `google-services.json` n'est nécessaire. 3. Comptes de service → générer une clé privée (JSON) : la saisir
  vous-même comme secret de la fonction `push` (`FCM_SERVICE_ACCOUNT`) sur le serveur. 4. Dans la base du serveur,
  enregistrer dans le coffre l'adresse de la fonction (`push_function_url`) et la clé de service
  (`push_function_key`) ; Claude fournira la commande exacte au déploiement.
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
- **Étapes** : Claude fournira une commande à exécuter avec votre email ou votre numéro.
- **Coût** : gratuit.
- **Vérification** : connexion au back-office avec l'espace Admin visible.
