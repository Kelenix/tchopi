# Plan de test et résultats

> Phase 5 (2026-10-19). Rôle : `12-qa-engineer`. Lancer tout : `.\check.ps1 -Integration` (vide la base locale,
> puis `.\dev-accounts.ps1`). Charge : `node tests/load/backend.mjs`.

## Types de tests

| Type | Où | Ce qui est couvert | Résultat |
|------|----|--------------------|----------|
| Unitaires | `packages/core/test`, `apps/mobile/test` | formats (monnaie, téléphone), identifiants, erreurs, règles d'espaces et de navigation, panier, paiements | ✅ 42 (core) + 61 (app), avec les widgets |
| Widgets | idem | écrans clés : états chargement / vide / erreur, actions, montants serveur | ✅ (compris ci-dessus) |
| Petits écrans, grande police | `small_screen.dart` + tests « petit écran » | connexion, inscription, accueil, fiche restaurant, validation, suivi, mission : 320 × 568 dp, police + 30 %, aucun débordement | ✅ |
| Base de données (pgTAP) | `supabase/tests/database` (13 fichiers) | règles métier, transitions de statut, RLS par rôle, attribution, paiements, remboursements | ✅ 246 / 246 |
| Intégration réelle | `test/integration` (Supabase local) | parcours complets contre la vraie base et les Edge Functions | ✅ 3 (core) + 9 (app) |
| Charge | `tests/load/backend.mjs` | parcours client et position livreur, 1 / 20 / 50 utilisateurs | ✅ `docs/qa/load-report.md` |
| Sécurité | pgTAP (RLS), `supabase db lint` | chaque rôle ne voit que ses données ; RLS + politiques sur les 25 tables ; lint sans alerte | ✅ |

## Scénarios de l'INTAKE (S1 à S6)

| Scénario | Couvert par |
|----------|-------------|
| S1 — commande de repas de bout en bout | intégration `orders_backend_test` (commande, réception en direct, acceptation, attribution, offre acceptée) ; pgTAP `orders`, `dispatch`, `missions` (récupération, code, livraison) |
| S2 — colis avec code de livraison | intégration `orders_backend_test` (devis, demande unique, code) ; pgTAP `parcels`, `missions` (code, essais limités) |
| S3 — Mobile Money | intégration `mobile_money_test` (page nyole, refus, nouvel essai, confirmation signée) ; pgTAP `mobile_money` |
| S4 — espèces | pgTAP `payments`, `missions` (encaissement, registre, versement) |
| S5 — aucun livreur | pgTAP `dispatch` (refus sans livreur en ligne, alerte 10 min, annulation 30 min) ; widget « toujours sans livreur » |
| S6 — annulation et remboursement | intégration `orders_backend_test` (remboursement décidé par l'admin) ; pgTAP `refunds` |

## Non couvert automatiquement (à vérifier à la main)

- Réception réelle des notifications push (projet Firebase à créer, tâche manuelle n° 8).
- Vraie API nyole (clés de test à fournir, tâche n° 1) ; carte bancaire (Inc-12).
- Position du livreur écran éteint sur un vrai téléphone, fluidité mesurée sur téléphone (`docs/performance.md`).
