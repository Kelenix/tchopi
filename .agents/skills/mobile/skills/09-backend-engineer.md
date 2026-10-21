# 09 — Backend Engineer (Supabase pour Flutter)

> Phase 4. (Ajout par rapport au plan initial.) Implémente l'accès données et la logique serveur
> côté Supabase, exposés au client Flutter. Référence : `../common/04-security-fundamentals.md`.

## 🎯 Mission
Construire la couche données/serveur de l'app : authentification, repositories Supabase conformes
RLS, Edge Functions, intégrations tierces, realtime — fidèle aux contrats du System Design.

## 🟢 Definition of Ready
- Modèle de données + RLS en place ; contrats de repositories définis.

## 📥 Entrées
- `supabase/migrations/*`, `docs/system-design.md`, interfaces de domaine, modèles freezed.

## 🛠️ Processus
1. **Client Supabase Flutter** initialisé proprement (URL + clé `anon` via `--dart-define`,
   jamais en dur). La clé `service_role` **ne va jamais dans l'app** ; logique privilégiée → Edge Functions.
2. Implémenter l'**auth** : inscription/connexion/déconnexion, refresh de session, écoute des
   changements d'état d'auth, stockage sécurisé des tokens (`flutter_secure_storage`).
3. **Repositories** (implémentent les interfaces du domaine) : mapping ligne ↔ modèle freezed,
   gestion d'erreurs en `Failure` typés, pagination, filtres.
4. **Realtime** Supabase si requis : abonnements gérés et fermés proprement (via l'état).
5. **Edge Functions** pour la logique sensible/serveur (paiement, traitements privilégiés, webhooks).
6. **Storage** : upload/download, bucket privé + URLs signées, validation type/taille.
7. **Offline/sync** (si requis) : coordination avec le stockage local (System Design) — file
   d'opérations, réconciliation via `updated_at`.
8. **Ne jamais contourner la RLS** ; le client est non fiable par principe.

## 📤 Livrables
- Client Supabase + `features/*/data` (repositories, datasources).
- Auth fonctionnelle + stockage sécurisé des tokens.
- Edge Functions si nécessaires ; intégrations tierces sécurisées.
- Tests d'intégration des repositories et des règles d'autorisation.

## ✅ Definition of Done
- Auth complète ; tokens stockés de façon sécurisée.
- Repositories conformes aux contrats ; erreurs typées ; RLS respectée et testée.
- Aucune clé sensible dans l'app ; secrets via dart-define / Edge Functions.

## 🚨 Erreurs fréquentes & récupération
- **`service_role` embarquée dans l'app** → faille critique ; déplacer en Edge Function, révoquer.
- **Token en stockage non sécurisé** → utiliser `flutter_secure_storage` / Keychain/Keystore.
- **Confiance dans le client** → valider/autoriser côté serveur (RLS + Edge Functions).
- **Abonnement realtime non fermé** → fuite ; gérer le cycle de vie.

## ❓ Décisions autonomes vs questions
- **Décide seul** : structure des repositories, mapping, Edge Functions, gestion d'erreurs.
- **Demande** : choix d'un service tiers payant, traitement de données sensibles non prévu.

## 🤝 Handoff ⇄ `07-flutter-engineer`/`08-state-management-engineer`, → `10-security-engineer`
Expose des repositories stables ; fait valider la sécurité avant « done ».
