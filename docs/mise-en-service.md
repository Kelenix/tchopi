# Mise en service : paiements et cartographie (ADR-039)

> État au 20/10/2026. **Aucun paiement n'est encore opérationnel** : tout a été testé avec des simulateurs de
> Stripe et de nyole, jamais avec un compte marchand réel. Les paiements en ligne restent désactivés dans
> Admin → Paramètres tant que les tests réels (§ 5) ne sont pas faits.

## 0. Prestataire « ONGAL »

Aucun service de paiement nommé « ONGAL » n'a été trouvé (recherche web, documentation nyole). Le lien fourni,
https://app.nyole.com/developer, est l'espace développeur de **nyole** (documentation : https://nyole.com/docs/),
déjà retenu en ADR-028 pour le Mobile Money. C'est lui qui est intégré. Si « ONGAL » désigne un autre prestataire,
donnez son site : la couche de paiement accepte un fournisseur de plus sans toucher à l'app (un fichier
`supabase/functions/_shared/<fournisseur>.ts`).

## 1. Ce qui est implémenté et testé (sans identifiants réels)

| Étape | Carte (Stripe Checkout) | Mobile Money (nyole) | Comment c'est vérifié |
|---|---|---|---|
| Lancement : session de paiement hébergée, montant = total de la commande calculé par le serveur | ✅ | ✅ | Intégration (simulateur) |
| Double toucher : même session (clé d'idempotence transaction + tentative) | ✅ | ✅ | Intégration |
| Webhook mal signé (HMAC-SHA256, 5 min de tolérance) : refusé | ✅ | ✅ | Intégration |
| Webhook annonçant « payé » sans confirmation du prestataire : sans effet (statut toujours **relu chez le prestataire**) | ✅ | ✅ | Intégration |
| Paiement confirmé : commande transmise **une seule fois**, même webhook rejoué | ✅ | ✅ | Intégration |
| Montant ou devise différents : refusé et tracé pour l'admin | ✅ | ✅ | pgTAP |
| Refusé par l'opérateur / la banque : « Réessayer » sur la même page | (géré par la page Stripe) | ✅ | Intégration |
| Abandon / session expirée : nouvelle session au prochain essai | ✅ | ✅ | Intégration |
| En attente sans réponse 15 min : commande annulée, rien transmis | ✅ | ✅ | pgTAP |
| Payé après annulation : « à rembourser » d'office | ✅ | ✅ | pgTAP |
| Remboursement : **automatique** (Stripe, une seule fois) / via le support nyole puis appliqué automatiquement (webhook `payment.updated`) | ✅ | ✅ | Intégration |
| Remboursement refusé après coup par la banque : de nouveau « à rembourser », admin alerté | ✅ | — | Intégration + pgTAP |
| Remboursement fait par le prestataire sans demande de Tchopi : appliqué, admin alerté | — | ✅ | pgTAP |
| Affichage dans l'app : en attente, refusé, payé, à rembourser, remboursé (en direct) | ✅ | ✅ | Tests de l'app |
| Clés secrètes uniquement côté serveur (jamais dans l'app) | ✅ | ✅ | Revue de code |

Cartographie : fond de carte, recherche de lieux, trajet routier, suivi du livreur avec son véhicule, bouton
« Ouvrir la navigation » — détail et évaluation dans `docs/cartographie.md`. Le trajet routier tourne sur le VPS
(OSRM) ; la recherche utilise le service public Photon.

## 2. Clés et paramètres à renseigner

Saisie **sur votre PC**, masquée, envoyée directement au serveur (jamais dans le chat, le code ou GitHub) :

```powershell
.\vps.ps1 cle-paiement STRIPE_SECRET_KEY        # sk_test_… pour les essais, sk_live_… ensuite
.\vps.ps1 cle-paiement STRIPE_WEBHOOK_SECRET    # whsec_… affiché par Stripe à la création du webhook
.\vps.ps1 cle-paiement NYOLE_SECRET_KEY         # af_test_sec_… pour les essais, af_live_sec_… ensuite
.\vps.ps1 cle-paiement NYOLE_RETURN_URL         # https://api.tchopi.com/functions/v1/payments-return
```

Chaque commande relance les fonctions de paiement. Déjà configurés : `PAYMENT_RETURN_URL` (page de retour après
paiement) et l'appel automatique des remboursements (coffre de la base).

## 3. Configuration chez les prestataires

### Stripe (carte bancaire)
1. **Compte au nom d'une société d'un pays où Stripe est ouvert** : Stripe n'accepte pas les sociétés
   immatriculées en Côte d'Ivoire. Vérifiez avec votre conseil les règles d'encaissement par une société étrangère.
2. Vérification d'identité (KYC) puis activation des paiements par carte.
3. Développeurs → Webhooks → Ajouter : URL `https://api.tchopi.com/functions/v1/payments-webhook-stripe`,
   événements `checkout.session.completed`, `checkout.session.expired`, `refund.updated`, `refund.failed`.
   Copier le secret de signature (`whsec_…`) avec la commande ci-dessus.
4. Paramètres → Image de marque : nom « Tchopi », logo, couleur (page de paiement) ; libellé sur relevé bancaire.
5. À savoir : montants facturés en francs CFA (XOF), convertis dans la devise de votre compte bancaire (frais de
   conversion Stripe) ; minimum par paiement ≈ 0,50 € (≈ 330 F) ; litiges (contestations de carte) à suivre dans le
   tableau de bord Stripe (pas automatisés dans l'app).

### nyole (Mobile Money : Orange Money, MTN MoMo, Wave, Moov)
1. Sur https://app.nyole.com/developer, vérifier que votre compte affiche des **clés API**. La documentation nyole
   précise que les comptes ouverts après le 17/10/2026 encaissent via LinkAfr, Griotia ou Wapilot : sans clés,
   contactez nyole.
2. Webhook : URL `https://api.tchopi.com/functions/v1/payments-webhook-nyole`, événements `payment.completed`,
   `payment.failed`, `payment.cancelled` (**à cocher** dans « API et journaux » : ajouté par nyole le 19/09/2026) et
   `payment.updated` (remboursements).
3. Vérification d'identité pour obtenir la clé `af_live_sec_…`.
4. Remboursements : demande au support nyole (pas d'API) ; l'app passe la commande « remboursée » à réception du
   webhook. Reversements de votre solde vers votre Mobile Money depuis le tableau de bord nyole.

### Dans l'app
Admin → Paramètres : activer « Carte bancaire » et/ou « Mobile Money » **après** les tests réels.

## 4. Cartographie : rien à configurer pour lancer
- Fond de carte, recherche de lieux : services publics gratuits, sans clé.
- Trajets : OSRM sur le VPS (déployé automatiquement).
- À surveiller : volume de recherches (service public Photon à usage modéré) ; voir `docs/cartographie.md` § 4.

## 5. Tests restant à faire avant la mise en production

Avec les clés **de test** (`sk_test_…`, `af_test_sec_…`) sur le serveur :

1. **Carte** : commande payée avec 4242 4242 4242 4242 → « Payée », transmise au restaurant ; carte 3-D Secure
   4000 0027 6000 3184 ; carte refusée 4000 0000 0000 0002 → message de refus, nouvel essai possible.
2. **Carte, remboursement** : annuler une commande payée → remboursement visible dans Stripe et « Remboursée » dans
   l'app ; vérifier dans Stripe → Webhooks que chaque envoi a reçu la réponse 200.
3. **Mobile Money** : sur la page nyole de test, simuler un succès, un refus puis un nouvel essai, un abandon.
4. **Délai** : laisser une commande sans payer 15 min → annulée ; payer ensuite → « à rembourser ».
5. **Webhooks réels** : contrôler dans les deux tableaux de bord que les webhooks arrivent sur le VPS (pas d'erreur
   400 de signature).

Puis avec les clés **de production**, petits montants réels :

6. Un paiement réel par carte et un par chaque opérateur Mobile Money utilisé (Orange, MTN, Wave, Moov), puis un
   remboursement réel de chaque type.
7. Rapprochement : montants reçus chez Stripe et nyole = transactions de l'admin (frais déduits).
8. Seulement alors : activer les moyens de paiement pour tous dans Admin → Paramètres.

## 6. Emails par Resend (inscription et récupération par email)

Les codes à 6 chiffres sont générés par Supabase (service d'authentification) ; Resend ne fait que les envoyer.

1. https://resend.com : créer le compte, puis **Domains → Add domain → `tchopi.com`**.
2. Ajouter dans la zone DNS de `tchopi.com` (hPanel Hostinger) les enregistrements affichés par Resend (DKIM, SPF,
   MX d'envoi) et attendre l'état **Verified**. Facultatif mais conseillé : un enregistrement DMARC
   (`_dmarc` → `v=DMARC1; p=none;`).
3. **API Keys → Create API key** (permission « Sending access », domaine `tchopi.com`).
4. Sur ce PC : `.\vps.ps1 email`, coller la clé (elle reste masquée). L'inscription par email s'ouvre sur le
   serveur ; les emails partent de `no-reply@tchopi.com`.
5. Vérifier : inscription sur le site avec votre email → le code arrive (pas en spam).

## 7. Connexion avec Google

1. https://console.cloud.google.com → projet « Tchopi » → **API et services → Écran de consentement OAuth** :
   type Externe, nom « Tchopi », logo, email d'assistance, domaine autorisé `tchopi.com`, puis publier.
2. **Identifiants → Créer → ID client OAuth → Application Web** :
   - Origines JavaScript autorisées : `https://tchopi.com`
   - URI de redirection autorisé : `https://api.tchopi.com/auth/v1/callback`
3. Sur ce PC : `.\vps.ps1 google`, saisir l'identifiant client puis le secret (masqué).
4. Vérifier : « Continuer avec Google » sur https://tchopi.com/connexion.

Le site renvoie vers `https://tchopi.com` après la connexion (`SITE_URL`, liste `ADDITIONAL_REDIRECT_URLS` réglées à
chaque déploiement du serveur). La connexion Google dans l'app mobile viendra ensuite (identifiants Android dédiés).
