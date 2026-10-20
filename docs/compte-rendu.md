# Comptes rendus de travail

> Le plus récent en haut. Détails techniques : `PROJECT_STATE.md`, décisions : `DECISION_LOG.md`.

---

## 2026-10-20 — Paiements, cartographie, trajets

### Résumé
- Paiements Stripe (carte) et nyole (Mobile Money) **prêts** : il ne reste qu'à saisir vos identifiants marchands et
  faire les tests réels. **Rien n'est encore opérationnel** (testé avec des imitations locales de Stripe et nyole,
  jamais avec un vrai compte) : les moyens de paiement restent désactivés dans l'admin.
- Commits : `4609140` (trajets sur le serveur), `3c6205b` (paiements, recherche de lieux, navigation), sur la
  branche `feat/inc-12-carte` et sur `main`. Toutes les vérifications passent (analyse, tests app et base,
  intégration).

### « ONGAL »
Aucun service de paiement à ce nom n'a été trouvé. Le lien donné mène à **nyole**, déjà choisi pour le Mobile Money :
c'est lui qui est intégré. Si ONGAL est un autre prestataire, donnez son site : il s'ajoute sans toucher à l'app.

### Paiements : ajouté
- Remboursement fait par l'équipe nyole (via leur support) : la commande passe « remboursée » automatiquement ; si
  Tchopi ne l'avait pas demandé, l'admin est alerté.
- Remboursement Stripe refusé après coup par la banque : la commande redevient « à rembourser », l'admin est alerté.
- `.\vps.ps1 cle-paiement <NOM>` : la clé se tape sur votre PC sans s'afficher et va directement sur le serveur
  (jamais dans le chat ni le code).

### Paiements : déjà en place, revérifié
- Page de paiement ouverte une seule fois même en cas de double appui.
- Faux webhook refusé ; statut toujours relu chez le prestataire.
- Montant différent rejeté ; commande transmise une seule fois.
- Refus, abandon, attente gérés ; annulation après 15 min sans paiement.
- Remboursements par carte automatiques.

### Cartographie
- Carte actuelle conservée. Couverture OpenStreetMap mesurée : quartiers, carrefours, pharmacies, marchés bien
  trouvés à Abidjan, moins dans les petites villes (détail : `docs/cartographie.md`).
- **Recherche de lieux** : loupe sur les cartes de sélection (adresse, colis). Essai : « marche adjame » trouve le
  marché d'Adjamé.
- **« Ouvrir la navigation »** (livreur) : Android propose les applis installées (Google Maps, Waze…), iPhone ouvre
  Plans. Vérifié sur le web (ouvre Google Maps), **pas encore sur un vrai téléphone**.
- **Trajets** : calculés sur votre serveur (`https://api.tchopi.com/route/…`), carte mise à jour chaque dimanche.
- Votre approche est retenue : carte dans l'app pour commander et suivre, application externe pour guider le livreur.
  Google Maps payant seulement si des lieux manquent (navigation intégrée ≈ 25 $ pour 1 000 trajets : non justifiée).

### À faire de votre côté
1. **Clés** : `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `NYOLE_SECRET_KEY`, `NYOLE_RETURN_URL` avec
   `.\vps.ps1 cle-paiement <NOM>`.
2. **Stripe** : compte au nom d'une société d'un pays où Stripe est ouvert (pas les sociétés immatriculées en Côte
   d'Ivoire), puis webhook avec 4 événements.
3. **nyole** : vérifier que le compte affiche des clés API (comptes ouverts après le 17/10 : autres outils), puis
   webhook ; cocher à la main l'événement `payment.cancelled`.
4. **Tests** : d'abord avec les clés de test (cartes de test Stripe, simulation nyole, remboursements, délai de
   15 min), puis petits paiements réels par opérateur ; activer les paiements dans l'admin seulement après.

Procédure détaillée : `docs/mise-en-service.md`.

### Sources
- Documentation nyole : https://nyole.com/docs/
- Tarifs Google Maps Platform : https://developers.google.com/maps/billing-and-pricing/pricing
- Devises Stripe : https://docs.stripe.com/currencies
- Événements Stripe : https://docs.stripe.com/api/events/types
