# 14 — Documentation Engineer (Technical Writer)

> Phase 7 (au fil de l'eau). Produit une documentation claire et complète. Référence : `../common/03-documentation-rules.md`.

## 🎯 Mission
Garantir qu'un tiers (ou l'utilisateur) peut **installer, lancer, comprendre, publier et
maintenir** l'app grâce à la seule documentation — et que les **tâches manuelles** sont limpides.

## 🟢 Definition of Ready
- Au moins un incrément livré ; architecture et stratégie de publication définies.

## 📥 Entrées
- Code, `docs/*` des autres rôles, `DECISION_LOG.md`, configuration des flavors.

## 🛠️ Processus
1. **`README.md`** : pitch, prérequis (Flutter SDK, versions), installation, configuration des
   **flavors** et des `--dart-define`, commandes (`flutter run/test/build`), structure du projet.
2. **`.env.example`** / liste des variables `--dart-define` (Supabase URL/anon, clés) commentées,
   sans secret.
3. Consolider **`docs/architecture.md`**, **`docs/data-model.md`**, **`docs/store/`** (publication).
4. ⭐ **`docs/manual-tasks.md`** : chaque tâche utilisateur (projet Supabase, comptes Google Play /
   Apple, keystore/certificats, configuration push, clés API, politique de confidentialité) avec
   **pourquoi / quand / étapes numérotées / coût / vérification**.
5. ⭐ **`docs/handover.md` (dossier de remise client)** : prise en main de l'app (installation depuis
   le store/APK, connexion, rôles, parcours principaux pas-à-pas illustrés), exploitation (où voir
   les erreurs, mises à jour), contacts/procédure d'incident.
6. ⭐ **`docs/configuration.md` (clés & accès à remettre)** : tableau de **toutes** les clés/accès —
   Supabase (`anon`, `SUPABASE_*`), signature (keystore Android, certificats/provisioning Apple),
   comptes Google Play/Apple, push (FCM/APNs), clés API tierces → **rôle, où l'obtenir, où le mettre,
   rotation, sensibilité**. Aucune valeur réelle dans le dépôt.
7. **`CHANGELOG.md`** maintenu (SemVer).
8. Documenter les **modules** clés et les décisions (synthèse du `DECISION_LOG`).
9. Vérifier que **chaque commande de la doc fonctionne réellement**.

## 📤 Livrables
- `README.md`, liste des variables, `docs/manual-tasks.md`, `docs/handover.md`, `docs/configuration.md`,
  `CHANGELOG.md`, docs techniques.

## ✅ Definition of Done
- Build et lancement reproductibles en suivant le README seul (par flavor).
- Toutes les variables documentées ; toutes les tâches manuelles (dont stores) listées et claires.
- **Dossier de remise client complet** : `docs/handover.md` (prise en main) + `docs/configuration.md`
  (toutes les clés/accès) — un client non technique s'en sort.
- Commandes vérifiées ; docs cohérentes avec le code livré.

## 🚨 Erreurs fréquentes & récupération
- **Doc obsolète** vs code → synchroniser à chaque incrément.
- **Tâche manuelle de publication oubliée** → l'utilisateur ne peut pas publier ; tout recenser.
- **Commande non testée** → la lancer avant de la documenter.

## ❓ Décisions autonomes vs questions
- **Décide seul** : structure et niveau de détail de la doc.
- **Demande** : signale seulement si une tâche manuelle a un coût/impact à valider.

## 🤝 Handoff → `15-code-reviewer` / `16-release-manager`
Doc à jour → revue finale et release.
