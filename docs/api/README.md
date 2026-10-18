# API — guide pour l'application web

> Même API que les apps mobiles (ADR-010). Base : `https://api.<domaine>` (local : `http://127.0.0.1:54321`).
> En-tête obligatoire sur chaque appel : `apikey: <clé publique>` ; une fois connecté : `Authorization: Bearer <jeton>`.
> Client recommandé côté web : `@supabase/supabase-js`. Les erreurs métier renvoient un **code stable** (liste en fin de page).

## Authentification (`/auth/v1`) — Inc-1

| Besoin | Appel supabase-js | Notes |
|--------|-------------------|-------|
| Méthodes disponibles | `GET /auth/v1/settings` → `external.phone` | Le téléphone n'est proposé que si `true` |
| Inscription email | `auth.signUp({ email, password })` | Code à 6 chiffres envoyé par email ; compte existant → `identities` vide |
| Inscription téléphone | `auth.signUp({ phone: '+225…', password })` | Code SMS |
| Vérifier l'inscription | `auth.verifyOtp({ type: 'signup' \| 'sms', email \| phone, token })` | Ouvre la session |
| Renvoyer le code | `auth.resend({ type: 'signup' \| 'sms', email \| phone })` | 1 fois par minute |
| Connexion | `auth.signInWithPassword({ email \| phone, password })` | `email_not_confirmed` → renvoyer le code |
| Mot de passe oublié (email) | `auth.resetPasswordForEmail(email)` puis `verifyOtp({ type: 'recovery', email, token })` puis `updateUser({ password })` | |
| Mot de passe oublié (téléphone) | `auth.signInWithOtp({ phone, shouldCreateUser: false })` puis `verifyOtp({ type: 'sms', … })` puis `updateUser({ password })` | |
| Changer d'identifiant | `auth.updateUser({ email \| phone })` puis `verifyOtp({ type: 'email_change' \| 'phone_change', … })` | Effectif après le code |
| Déconnexion | `auth.signOut()` | |

Règle mot de passe (serveur) : 8 caractères minimum, lettres et chiffres.

## Données et actions — Inc-1

| Ressource / action | Accès | Description |
|--------------------|-------|-------------|
| `GET /rest/v1/profiles?select=id,first_name,last_name,phone,city` | connecté | Son propre profil (un admin voit tous les profils) |
| `PATCH /rest/v1/profiles?id=eq.<uid>` | connecté | Modifiables : `first_name`, `last_name`, `phone` (E.164), `city` ; refus si compte suspendu |
| `POST /rest/v1/rpc/my_roles` | connecté | `{ "is_admin": bool }` — s'enrichira (livreur, restaurants) |
| `POST /functions/v1/account-delete` | connecté | Anonymise le profil et supprime l'accès (`{ "ok": true }`) |

## Codes d'erreur stables

| Code | Signification |
|------|---------------|
| `invalid_credentials` | Identifiant ou mot de passe incorrect |
| `user_already_exists` / `email_exists` / `phone_exists` | Identifiant déjà utilisé |
| `otp_expired` | Code incorrect ou expiré |
| `over_email_send_rate_limit` / `over_sms_send_rate_limit` / `over_request_rate_limit` | Trop de tentatives |
| `weak_password` | Mot de passe hors règle |
| `user_banned` | Compte suspendu |
| `email_not_confirmed` / `phone_not_confirmed` | Inscription non vérifiée |
| `unauthorized` | Appel de fonction sans session valide |
| `account_delete_failed` | Suppression impossible (réessayer) |
