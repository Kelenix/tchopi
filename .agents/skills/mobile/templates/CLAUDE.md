# CLAUDE.md — <Nom du projet> (Application MOBILE)

> Ce projet est construit avec le système de skills **AI Delivery Team**.
> 👉 Copie ce fichier à la racine de ton projet mobile (il garde le nom `CLAUDE.md`).
> Claude Code le lit automatiquement à chaque session — plus besoin de coller les chemins.

## Stack du projet
Flutter (Dart) · **Riverpod** (gestion d'état) · go_router · Supabase (Postgres + Auth +
Storage + RLS) · freezed · flutter_test + integration_test · GitHub Actions + Fastlane.

## Où se trouvent les skills
Les dossiers `common/` et `mobile/` du système doivent être accessibles dans ce projet, de
préférence sous **`.claude/skills/`** (ou installés une fois pour toutes dans `~/.claude/skills/`).
Si tu les places ailleurs, adapte les chemins ci-dessous.

## Au démarrage / quand je te demande de construire
1. Lis `.claude/skills/mobile/SKILL.md` (orchestrateur), puis
   `.claude/skills/mobile/skills/00-ai-project-director.md` (protocole complet).
2. Lis `.claude/skills/common/09-ai-working-rules.md` (décider seul vs me demander).
3. Lis `INTAKE.md` (mon cahier des charges, à la racine du projet). S'il manque, copie
   `.claude/skills/mobile/templates/INTAKE.md` → `INTAKE.md` et demande-moi de le remplir.
4. Applique le protocole : **reformulation → plan de réalisation → exécution par phases**.

## Règles permanentes (rappel — la source complète est dans `common/`)
- **Décide seul et documente** dans `DECISION_LOG.md`. Ne me pose une question QUE sur impact
  **métier / financier / fonctionnel majeur / légal / irréversible** (questions regroupées).
- **Plan d'abord** ; **chargement progressif** (un fichier de rôle par phase).
- **Sécurité** : RLS Supabase **obligatoire** ; tokens dans le stockage sécurisé
  (Keychain/Keystore) ; aucun secret dans le binaire (`--dart-define` / Edge Functions) ;
  permissions minimales et justifiées.
- **Code professionnel** : propre, scalable, **minimum de code nécessaire** (sans nuire à la
  lisibilité) ; logique hors des widgets ; pas de sur-ingénierie, pas de TODO laissé.
- **Vérifie avant de dire « fait »** : `flutter analyze` + tests verts ; honnêteté sur les
  échecs (protocole d'erreur : `.claude/skills/common/06-error-handling.md`).
- **Suis l'avancement** dans `PROJECT_STATE.md` ; liste les **tâches manuelles** dans
  `docs/manual-tasks.md` (projet Supabase, comptes Google Play / Apple, signatures, push…).
- Respecte la **Definition of Ready / Done** (`.claude/skills/common/10-definition-of-done.md`)
  et les contraintes de publication (stores).

## Comment je lance le projet
Je dirai simplement : **« Lis INTAKE.md et lance le projet selon le skill. »**
Mode par défaut : **PLAN_PUIS_VALIDATION** (présente le plan et attends mon feu vert avant de
coder). Si j'écris **AUTONOME**, enchaîne l'implémentation sans pause, en ne m'interrompant que
sur impact fort.
