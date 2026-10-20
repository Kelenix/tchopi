# Audit avant mise en production — application mobile (2026-10-20)

> Vérifié dans le code, la base, la CI et la documentation. Ce qui n'a pas pu être vérifié est dit comme tel.
> Verdict : **pas prête pour le public**. Le parcours complet fonctionne (tests verts, essais réels en espèces),
> mais 4 points bloquent l'ouverture.

## Bloquant

| # | Point | Constat | Pour débloquer |
|---|-------|---------|----------------|
| B1 | **Inscription impossible pour le public** | Serveur : pas de SMS (seuls les numéros ajoutés par `vps.ps1 testeur` peuvent s'inscrire) et inscription par email coupée (pas de SMTP, `ENABLE_EMAIL_SIGNUP=false`). | Tâche n° 5 (SMTP, puis email activé) et/ou n° 6 (fournisseur SMS). |
| B2 | **Version Play Store non signée** | `android/app/build.gradle.kts` : la version « release » est signée avec la clé de débogage ; Google Play la refuse. | Créer la clé de signature (Claude prépare la configuration ; la clé reste sur votre PC) + compte Play Console (tâche n° 11). |
| B3 | **Textes juridiques absents** | Pas de CGU ni de politique de confidentialité publiées ; obligatoires pour les stores (position, téléphone, adresses). | Tâche n° 10 (canevas fourni par Claude, validation par vous). |
| B4 | **Paiements en ligne jamais essayés en réel** | Stripe et nyole codés et testés contre des imitations locales, jamais avec de vraies clés ; désactivés dans l'admin. | Ouvrir **en espèces seulement**, ou faire les essais de `docs/mise-en-service.md` § 5 avant d'activer. |

## À vérifier avant l'ouverture (non bloquant mais non prouvé)

- **Notifications push** : activées le 2026-10-20 (`vps.ps1 notifications`) ; aucune réception réelle constatée.
  Correctif du même jour : l'autorisation est maintenant demandée à l'ouverture (ADR-041).
- **Sur un vrai téléphone** : position du livreur écran éteint, fluidité, « Ouvrir la navigation » (vérifié seulement
  dans le navigateur).
- **Revue de sécurité formelle** (jalon J5) non faite. Vérifié aujourd'hui : RLS active sur les 26 tables, aucun
  secret dans le code ni dans git (clés serveur dans le `.env` du VPS, compte de service Firebase hors dépôt).
- **Sauvegardes** : quotidiennes sur le VPS (14 jours), copie hors du VPS encore manuelle
  (`docs/deployer-sur-vps.md` § 6).
- **iPhone** : non traité (Android d'abord, D-6).

## Bugs trouvés pendant l'audit

- Écran des commandes du restaurant : toute commande affichait « Espèces à la livraison », même payée par carte ou
  Mobile Money. **Corrigé** (moyen et état du paiement affichés, test ajouté).

## Ce qui est vérifié et fonctionne

- CI verte au dernier envoi : analyse, 66 + 59 tests Flutter, migrations depuis zéro + tests pgTAP de la base,
  builds Android et web, déploiement automatique du serveur.
- Parcours repas et colis de bout en bout, espèces, annulations, remboursements décidés par l'admin, supervision sur
  alerte, notifications « livrée » au restaurant (tests automatiques ; essais réels faits en espèces).

## Manque par rapport à la plateforme web demandée

À ajouter au **backend commun** (donc aussi visible du mobile), voir `../tchopi-web/docs/plan-de-realisation.md` :
type d'établissement **magasin**, **options de produits** (taille, suppléments), retour des paiements en ligne vers le
site web.
