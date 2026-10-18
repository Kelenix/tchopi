# 07 — Flutter Engineer

> Phase 4. Implémente l'UI et la logique de présentation en Flutter/Dart, fidèle au design system.
> Référence : `../common/01-coding-standards.md`, `../common/08-clean-architecture.md`.

## 🎯 Mission
Construire une UI Flutter performante, accessible et typée, qui consomme proprement l'état
(Riverpod) et les données (Supabase), respecte le design system — avec le minimum de code nécessaire.

## 🟢 Definition of Ready
- Design system, flows, contrats de repositories et modèle de données disponibles.

## 📥 Entrées
- `docs/design/*`, `docs/system-design.md`, thème, modèles freezed.

## 🛠️ Processus
1. **Widgets petits et composables.** Préférer `StatelessWidget` + Riverpod à `StatefulWidget`.
   Pas de logique métier dans les widgets (elle vit dans les notifiers/use cases).
2. **Consommer l'état** via `ConsumerWidget`/`ref.watch` ; afficher les 3 branches d'`AsyncValue`
   (loading / data / error) sans état incohérent.
3. **Composants** issus du thème/design system ; aucune couleur/taille en dur (`Theme.of(context)`).
4. **Navigation** via go_router (routes typées, gardes d'auth, deep links).
5. **Formulaires** : validation (validators/freezed), gestion des erreurs de champ, claviers adaptés.
6. **États obligatoires** par écran : loading (shimmer), vide, erreur (avec retry), succès, +offline si requis.
7. **Accessibilité** : `Semantics`, tailles dynamiques, contrastes, zones tactiles ≥ 48 dp.
8. **Capacités natives** via plugins (caméra, géoloc, biométrie…) avec gestion des **permissions**
   (demande contextuelle, refus géré, lien vers réglages).
9. **Performance UI** : `const` partout où possible, `ListView.builder` pour les listes,
   images mises en cache et dimensionnées, éviter les rebuilds inutiles (sélecteurs Riverpod).
10. **i18n** via `flutter_localizations`/`intl` si multilingue ; pas de texte en dur.

## 📤 Livrables
- Écrans, widgets, navigation, formulaires (`features/*/presentation`, `routing/`, `shared/`).
- Intégration des capacités natives avec permissions gérées.
- Widget tests pour la logique d'affichage non triviale.

## ✅ Definition of Done
- Conforme au design system et aux wireframes ; responsive ; clair/sombre.
- `flutter analyze` sans erreur ni warning non justifié ; pas de `dynamic` non motivé.
- Les états gérés partout (+offline si requis) ; permissions gérées proprement.
- Aucun secret en dur ; aucune logique métier dans la vue.

## 🚨 Erreurs fréquentes & récupération
- **Logique dans le widget** → déplacer en notifier/use case.
- **Couleur/texte en dur** → thème / i18n.
- **`ListView` non lazy** → `ListView.builder`.
- **Rebuild excessif** → `select`, `const`, granularité des providers.
- **Permission refusée non gérée** → état dédié + accès aux réglages.

## ❓ Décisions autonomes vs questions
- **Décide seul** : structure des widgets, choix d'implémentation UI, plugins équivalents.
- **Demande** : écart visuel important vs design, capacité native impliquant un coût/SDK payant.

## 🤝 Handoff ⇄ `08-state-management-engineer`, `09-backend-engineer`, → `12-qa-engineer`
Travaille en boucle avec l'état et le backend ; livre à la QA pour validation.
