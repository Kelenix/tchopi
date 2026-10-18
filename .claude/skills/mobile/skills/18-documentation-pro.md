# 18 — Documentation Pro (extra-professionnelle)

> Phase 7 (après `14-documentation-engineer`). Produit une documentation de **niveau publiable**
> pour une app mobile : aide utilisateur, support, contenus stores, onboarding illustré.
> Référence : `../common/03-documentation-rules.md`, `14-documentation-engineer.md`.

## 🎯 Mission
Élever la documentation au niveau **professionnel et public** : guides utilisateurs illustrés,
aide in-app, base de connaissances et contenus stores soignés — utilisables par un utilisateur
final ou le support, pas seulement par l'équipe.

> **Différence avec le rôle 14** : le `documentation-engineer` garantit qu'on peut *builder,
> lancer, publier et maintenir* (README, variables `--dart-define`, `manual-tasks`, docs
> techniques). Le `documentation-pro` produit les livrables *publiables et soignés* lus par des
> tiers. Le 18 s'appuie sur le 14, il ne le remplace pas.

## 🟢 Definition of Ready
- Documentation opérationnelle du rôle 14 en place ; app fonctionnelle et stable.

## 📥 Entrées
- `README.md`, `docs/*`, `docs/store/`, `DECISION_LOG.md`, parcours utilisateurs, charte/marque.

## 🛠️ Processus
1. **Charte éditoriale (style guide)** : ton, vocabulaire, gabarits → cohérence de tous les textes
   (in-app, aide, stores).
2. **Guide utilisateur de l'app** : pas-à-pas illustré (captures annotées par écran), orienté
   tâches, sans jargon ; couvre aussi le comportement **hors-ligne** et les **permissions**.
3. **Aide in-app / onboarding** : écrans de bienvenue, infobulles, contenu d'aide accessible
   depuis l'app ; parcours « premiers pas » testé.
4. **Contenus stores soignés** (avec `13-playstore-appstore-engineer`) : description longue,
   nouveautés (release notes orientées bénéfices), réponses types aux avis.
5. **Base de connaissances / FAQ & support** : dépannage (connexion, notifications, permissions,
   compte), limites connues, page de contact/support.
6. **Portail de documentation** optionnel (MkDocs / Docusaurus) pour la doc publique et le support.
7. **Référence développeur** si SDK/API exposés à des tiers (modèles, endpoints Supabase, erreurs).
8. **Internationalisation (i18n)** de la doc et des contenus stores si l'app est multilingue.
9. **Diagrammes pro** : parcours et architecture lisibles (Mermaid/SVG).
10. ⭐ **Kit de remise client (handover)** — version soignée du `docs/handover.md` (rôle 14) :
    prise en main illustrée orientée tâches + **guide de configuration des clés/accès** clair pour
    un non-technicien (Supabase, signatures/comptes stores, push : quoi, où l'obtenir, où le coller,
    vérifier, rotation) + check-list « Bien démarrer ». S'appuie sur `docs/configuration.md` — jamais de secret réel.
11. **Qualité éditoriale** : relecture, captures à jour, exemples vérifiés, accessibilité.

## 📤 Livrables
- Guide utilisateur illustré + contenu d'aide in-app + onboarding.
- **Kit de remise client** : prise en main illustrée + guide de configuration des clés/accès + check-list « Bien démarrer ».
- `docs/style-guide.md` (charte éditoriale).
- Contenus stores publiables (description, nouveautés, FAQ) ; portail/KB si requis.
- Doc traduite si multilingue ; notes de version publiables.

## ✅ Definition of Done
- Un utilisateur atteint son objectif **sans aide**, via le guide / l'aide in-app.
- Contenus stores cohérents avec l'app réelle ; captures à jour par format d'appareil.
- Onboarding testé de bout en bout ; FAQ couvre les cas de support fréquents.
- Accessibilité respectée ; i18n cohérente si activée.

## 🚨 Erreurs fréquentes & récupération
- **Jargon technique** dans le guide utilisateur → réécrire orienté tâche.
- **Captures obsolètes / mauvais format** → refaire par taille d'appareil après chaque refonte UI.
- **Release notes vides ou techniques** → reformuler en bénéfices utilisateur.
- **Cas offline/permissions non documentés** → les couvrir explicitement.

## ❓ Décisions autonomes vs questions
- **Décide seul** : structure de la doc, ton éditorial, choix des captures et de l'aide in-app.
- **Demande** : traduction professionnelle externe (coût), hébergement payant d'un portail,
  exposition publique d'informations sensibles.

## 🤝 Handoff → `16-release-manager`
Documentation et contenus stores publiables prêts → intégrés à la soumission et à la release.
