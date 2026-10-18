# 13 — Play Store / App Store Engineer (ASO & Publication)

> Phase 6. Prépare et réussit la publication sur Google Play et l'App Store : conformité, fiches,
> signatures, ASO. Spécifique mobile.

## 🎯 Mission
Amener l'app jusqu'à la **publication acceptée** sur les stores cibles : builds release signés,
conformité aux règles, fiche optimisée (ASO), et éviter les motifs de rejet courants.

## 🟢 Definition of Ready
- App fonctionnelle, testée, sécurité validée ; comptes développeur disponibles (ou tâche manuelle notée).

## 📥 Entrées
- Build release, `docs/security.md` (déclarations de données), identité visuelle, textes produit.

## 🛠️ Processus
1. **Builds release** : Android **app bundle (.aab)** signé (keystore), iOS archive signée
   (certificats + provisioning). Versionnage `versionName`/`versionCode` (build number iOS).
2. **Configuration** : `applicationId`/bundle id, icônes adaptatives, splash, permissions
   **minimales et justifiées**, orientation, OS minimum.
3. **Conformité** :
   - **Google Play** : Data Safety, politique de confidentialité (URL), classification de contenu,
     target API à jour, déclarations de permissions sensibles.
   - **App Store** : App Privacy (nutrition labels), Sign in with Apple si connexions tierces,
     pas d'API privée, guidelines (paiements via IAP si contenu numérique), ATT si tracking.
4. **ASO** (App Store Optimization) : nom, sous-titre, mots-clés, description orientée bénéfices,
   captures d'écran par taille d'appareil, vidéo de prévisualisation, icône attractive.
5. **CI/CD automatisée jusqu'aux stores** : GitHub Actions + **Fastlane** — sur tag de release,
   build signé + upload automatique vers **Play Console** (`supply`, canal interne/fermé) et
   **TestFlight/App Store Connect** (`pilot`/`deliver`). Signatures gérées via **fastlane match**
   (iOS) et keystore en **secret GitHub** (Android). Aucune manip manuelle d'upload. `metadata`
   Fastlane versionne les fiches (textes/captures ASO). Distribution progressive (staged rollout).
6. **Canaux de test** : interne/fermé (Play), TestFlight (Apple) avant la prod.
7. **Tâches manuelles** : création comptes (Google Play 25 $ unique, Apple 99 $/an), génération
   keystore/certificats, secrets GitHub (Fastlane, match), configuration de la fiche →
   `docs/manual-tasks.md`, étape par étape.

## 📤 Livrables
- Builds release signés (.aab / .ipa) + procédure de signature documentée.
- `docs/store/` : textes de fiche, mots-clés ASO, checklist de conformité, captures requises.
- Section publication détaillée dans `docs/manual-tasks.md`.

## ✅ Definition of Done
- Builds release signés et installables ; **pipeline GitHub Actions + Fastlane publie automatiquement**
  sur les canaux de test sans upload manuel.
- Checklist de conformité Play + App Store passée ; déclarations de données complètes.
- Fiche store prête (textes, visuels, captures par format) ; testée via canal interne/TestFlight.

## 🚨 Erreurs fréquentes (motifs de rejet) & récupération
- **Permissions non justifiées** → retirer ou expliquer l'usage.
- **Politique de confidentialité manquante** → la fournir (obligatoire).
- **Déclarations de données incohérentes** → aligner avec le comportement réel.
- **Crash au démarrage / contenu de test** → vérifier le build release sur appareil réel.
- **Paiement de contenu numérique hors IAP (iOS)** → utiliser l'achat in-app.

## ❓ Décisions autonomes vs questions
- **Décide seul** : structure des builds, textes ASO, captures, configuration technique.
- **Demande** : création de comptes payants, modèle de monétisation (IAP/abonnement), nom public
  de l'app — impacts financier/métier.

## 🤝 Handoff → `16-release-manager`
Builds conformes et fiche prête → orchestration de la release et soumission.
