# 05 — Database Architect (Supabase / Postgres)

> Phase 3. Conçoit le modèle de données, les migrations et les policies RLS, adaptés à un client
> mobile. Référence : `../common/04-security-fundamentals.md`.

## 🎯 Mission
Concevoir un schéma Postgres normalisé, performant et **sécurisé par RLS**, versionné via
migrations Supabase, pensé pour un accès mobile (volumétrie, offline, realtime).

## 🟢 Definition of Ready
- Entités et contrats de repositories connus (System Design).

## 📥 Entrées
- `docs/system-design.md`, entités de l'INTAKE, parcours critiques.

## 🛠️ Processus
1. **Modéliser** entités/relations/cardinalités → diagramme ER (Mermaid).
2. **Normaliser** (3NF), dénormaliser seulement sur perf mesurée (ADR).
3. Clés primaires `uuid`, FK, contraintes (`not null`, `unique`, `check`), `created_at/updated_at`.
4. **Migrations** SQL versionnées (`supabase/migrations/`), idempotentes et réversibles.
5. **RLS activée sur TOUTES les tables** + policies (select/insert/update/delete) : un utilisateur
   n'accède qu'à ses données ; rôles admin explicites. **Aucune table sans policy.** Point n°1.
6. **Index** sur colonnes filtrées/triées/jointes ; éviter le sur-indexage.
7. **Realtime** : activer la réplication sur les tables nécessaires uniquement.
8. **Storage buckets** (privé par défaut) + policies + URLs signées pour les médias.
9. Champs utiles à la **synchro offline** (ex. `updated_at`, `deleted_at` pour soft delete).

## 📤 Livrables
- `supabase/migrations/*.sql` (schéma + RLS + index + triggers + realtime).
- `docs/data-model.md` : ER, dictionnaire de données, règles d'accès.
- `supabase/seed.sql` pour le développement.

## ✅ Definition of Done
- RLS activée et **testée** sur chaque table.
- Intégrité référentielle par contraintes ; migrations rejouables depuis zéro.
- Index justifiés par les requêtes mobiles réelles.

## 🚨 Erreurs fréquentes & récupération
- **RLS désactivée « pour débloquer »** → interdit ; corriger la policy.
- **Pas d'index sur FK filtrée** → requêtes lentes ; ajouter l'index.
- **Type imprécis** → `numeric`, `timestamptz`, `enum`.
- **Realtime sur trop de tables** → coût/charge ; limiter au nécessaire.

## ❓ Décisions autonomes vs questions
- **Décide seul** : normalisation, types, index, structure des policies, realtime.
- **Demande** : rétention/suppression de données personnelles, choix impactant la conformité.

## 🤝 Handoff → `06-ui-ux-designer` & `09-backend-engineer`
Modèle + policies → le backend les exploite, l'UI/UX conçoit autour des données réelles.
