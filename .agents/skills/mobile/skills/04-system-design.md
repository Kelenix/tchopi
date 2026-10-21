# 04 — System Design

> Phase 3. Conception détaillée : modules, contrats repositories, flux, synchronisation. Le « comment ».

## 🎯 Mission
Détailler le fonctionnement interne de l'app : contrats des repositories, flux de données entre
couches, gestion de l'asynchrone et de l'offline, stratégies de cache et de résilience.

## 🟢 Definition of Ready
- Architecture mobile validée (`docs/architecture.md`).

## 📥 Entrées
- `docs/architecture.md`, user stories, modèle de données préliminaire.

## 🛠️ Processus
1. Définir les **contrats des repositories** (interfaces du domaine) : signatures, entrées/sorties
   typées (freezed), erreurs possibles (`Failure` typés). Le domaine ne connaît pas Supabase.
2. Modéliser les **flux** des parcours critiques (Mermaid sequence) : auth, lecture, mutation, sync.
3. Définir la gestion de l'**asynchrone** : `AsyncValue` (loading/data/error) partout, pas d'état
   incohérent ; annulation et `dispose` des abonnements (realtime).
4. Définir la **stratégie offline/cache** (si requise) : source de vérité locale (ex. Drift/Isar
   ou cache mémoire), politique de synchro, résolution de conflits, file d'opérations en attente.
5. Définir **pagination**, tri, filtrage standardisés ; **realtime** Supabase si pertinent.
6. Définir la **résilience** : timeouts, retries (transitoire only), idempotence des mutations.

## 📤 Livrables
- `docs/system-design.md` : contrats repositories, diagrammes de séquence, stratégie offline/cache.
- Interfaces de domaine esquissées + modèles freezed.

## ✅ Definition of Done
- Chaque parcours critique a un flux documenté de bout en bout (online et offline si requis).
- Contrats typés avec erreurs définies ; états asynchrones modélisés.
- Stratégie de cache/synchro explicite et cohérente.

## 🚨 Erreurs fréquentes & récupération
- **Domaine couplé à Supabase** → introduire une interface de repository.
- **États asynchrones non gérés** (pas de loading/error) → utiliser `AsyncValue`.
- **Abonnement realtime non libéré** → fuite ; `dispose`/`autoDispose`.
- **Conflit de synchro non géré** → définir la règle (dernier gagne / fusion).

## ❓ Décisions autonomes vs questions
- **Décide seul** : forme des contrats, cache, pagination, stockage local.
- **Demande** : stratégie offline complexe à enjeu produit, choix d'un service de sync payant.

## 🤝 Handoff → `05-database-architect`
Contrats et flux → modèle de données et policies qui les soutiennent.
