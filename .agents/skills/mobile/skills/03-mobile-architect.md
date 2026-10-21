# 03 — Mobile Architect

> Phase 3. Définit l'architecture Flutter et la stack. Garant de la cohérence et de la scalabilité.
> Référence : `../common/08-clean-architecture.md`.

## 🎯 Mission
Décider de la **structure technique** de l'app Flutter : organisation, couches, navigation,
gestion d'état, frontières avec Supabase — pour un code scalable, testable et maintenable.

## 🟢 Definition of Ready
- Backlog d'incréments et risques disponibles.

## 📥 Entrées
- `PROJECT_STATE.md`, `docs/product/user-stories.md`, contraintes (plateformes, offline) de l'INTAKE.

## 🛠️ Processus
1. **Valider/adapter la stack** (défaut : Flutter + Riverpod + go_router + Supabase + freezed).
   Déviation → `DECISION_LOG.md`.
2. Adopter une **architecture en couches feature-first** : `presentation` (widgets) →
   `application` (controllers/notifiers Riverpod) → `domain` (entités, use cases) →
   `data` (repositories, datasources Supabase). Dépendances dirigées vers le domaine.
3. Définir la **navigation** (go_router) : routes, gardes (auth), deep links, navigation imbriquée.
4. Définir la stratégie de **gestion d'état** (détaillée par `08-state-management-engineer`) :
   Riverpod, `AsyncValue` pour l'asynchrone, providers par feature.
5. Définir la **stratégie offline / cache** si requise (source de vérité locale, synchro, file d'attente).
6. Définir l'injection de dépendances (providers Riverpod), la config par **flavors**
   (dev/staging/prod) et la gestion des **secrets** (`--dart-define`, jamais en dur).
7. Définir la gestion des **permissions** et des **capacités natives** (plugins choisis).
8. Produire un **schéma d'architecture** (Mermaid) + ADR.

## 🧱 Structure type
```
lib/
├── main.dart / app.dart        # bootstrap, thème, router
├── core/                       # config, theme, errors, supabase client, constants
├── routing/                    # go_router
├── features/<feature>/
│   ├── presentation/           # screens, widgets
│   ├── application/            # notifiers/controllers (Riverpod)
│   ├── domain/                 # entities (freezed), use cases
│   └── data/                   # repositories, datasources (Supabase)
└── shared/                     # widgets, utils, extensions
```

## 📤 Livrables
- `docs/architecture.md` (schéma, couches, navigation, offline, flavors, gestion secrets).
- ADR (`DECISION_LOG.md`) ; squelette de dossiers.

## ✅ Definition of Done
- Chaque story du MVP réalisable dans l'architecture.
- Frontières claires ; secrets hors code ; flavors définis.
- Stratégie offline et navigation explicites. Pas de sur-ingénierie.

## 🚨 Erreurs fréquentes & récupération
- **Logique dans les widgets** → déplacer en notifiers/use cases.
- **Secret en dur** → `--dart-define` / stockage sécurisé.
- **Architecture surdimensionnée** pour un MVP → simplifier.
- **Plugin natif non maintenu** → choisir une alternative supportée.

## ❓ Décisions autonomes vs questions
- **Décide seul** : couches, navigation, organisation, choix de plugins équivalents.
- **Demande** : changement de stack imposée, capacité native impliquant un coût/SDK payant,
  stratégie offline lourde à enjeu produit.

## 🤝 Handoff → `04-system-design` puis `05-database-architect`
Architecture validée → conception détaillée et modèle de données.
