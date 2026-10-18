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

## Zones, tarifs, adresses — Inc-2

| Ressource / action | Accès | Description |
|--------------------|-------|-------------|
| `GET /rest/v1/zones?is_active=eq.true` | connecté | Zones actives (nom, ville, devise, centre, rayon) |
| `GET` / `POST` / `PATCH` / `DELETE /rest/v1/addresses` | titulaire | Champs écrits : `label`, `district`, `landmark`, `instructions`, `latitude`, `longitude`, `is_default` ; `zone_id` et `city` calculés par le serveur |
| `zones`, `pricing_rules` (écriture) | admin | Gestion des zones et des règles par service (`food`, `parcel`) |
| `POST /rest/v1/rpc/admin_simulate_fee` | admin | `{ p_zone_id, p_service, p_straight_km }` → `distance_m`, `delivery_fee`, `courier_earning` |

## Livreurs et administration — Inc-3

| Ressource / action | Accès | Description |
|--------------------|-------|-------------|
| `POST /rest/v1/rpc/submit_courier_profile` | connecté | `{ p_zone_id, p_vehicle_type, p_plate_number, p_photo_path }` → profil livreur (statut `pending`) |
| `GET /rest/v1/couriers` | titulaire, admin | Profil livreur et statut (`pending`, `approved`, `rejected`, `suspended`) |
| Storage `couriers/<user_id>/…` | titulaire, admin | Photo de profil (bucket privé, liens signés) |
| `POST /rest/v1/rpc/admin_set_courier_status` | admin | `{ p_user_id, p_status, p_reason }` (motif obligatoire pour refus et suspension) |
| `POST /functions/v1/admin-users` | admin | `{ action: "suspend" ou "reactivate", user_id, reason }` ou `{ action: "update_login", user_id, email ou phone }` |
| `POST /rest/v1/rpc/my_roles` | connecté | `{ is_admin, courier_status }` |

## Restaurants et catalogue — Inc-4

| Ressource / action | Accès | Description |
|--------------------|-------|-------------|
| `GET /rest/v1/restaurants?select=*,is_open` | connecté | Restaurants actifs (admin et gérants : tous les leurs) ; `is_open` calculé par le serveur |
| `PATCH /rest/v1/restaurants` | gérant | Champs : `description`, `category`, `cover_path`, `phone`, `prep_time_min`, `is_temporarily_closed` |
| `POST /rest/v1/rpc/save_opening_hours` | gérant, admin | `{ p_restaurant_id, p_hours: [{ weekday 1–7, opens_at, closes_at }] }` (remplace tout) |
| `categories`, `products` (écriture) | gérant, admin | Pas de suppression de produit : `archived_at` ; les clients ne voient pas les produits archivés |
| Storage `media/restaurants/<id>/…` | lecture publique ; écriture gérant, admin | Couverture et photos produits (2 Mo max) |
| `POST /rest/v1/rpc/admin_save_restaurant` | admin | `{ p_id (null = création), p_zone_id, p_name, p_description, p_category, p_phone, p_latitude, p_longitude, p_district, p_landmark, p_commission_rate, p_is_active }` → identifiant |
| `POST /rest/v1/rpc/admin_invite_member` / `admin_remove_member` | admin | `{ p_restaurant_id, p_email ou p_phone }` / `{ p_member_id }` |
| `POST /rest/v1/rpc/my_roles` | connecté | `{ is_admin, courier_status, restaurant_ids }` |

## Commandes de repas — Inc-5

| Ressource / action | Accès | Description |
|--------------------|-------|-------------|
| `POST /rest/v1/rpc/quote_food_order` | client | `{ p_restaurant_id, p_address_id, p_items: [{ product_id, quantity 1–50 }] }` → `subtotal`, `delivery_fee`, `total`, `distance_m`, `currency`, `items`, `issues` (`restaurant_closed`, `product_unavailable`) |
| `POST /rest/v1/rpc/place_food_order` | client | `{ p_restaurant_id, p_address_id, p_items, p_payment_method: 'cash', p_expected_total, p_idempotency_key (uuid) }` → la commande ; même clé = même commande |
| `POST /rest/v1/rpc/cancel_order` | client (en attente), admin (motif) | `{ p_order_id, p_reason }` |
| `POST /rest/v1/rpc/transition_order` | gérant, admin | `{ p_order_id, p_to_status, p_reason }` : `pending` → `accepted` ou `rejected` (motif), `accepted` → `preparing` → `ready` |
| `GET /rest/v1/orders?select=*,order_items(*)` | client (siennes), gérant (son restaurant), admin | Montants et adresses figés ; aucune écriture directe |
| `GET /rest/v1/order_events?order_id=eq.<id>` | idem | Chronologie des statuts |
| Temps réel `orders`, `order_events` | idem (RLS) | Nouvelles commandes côté restaurant, suivi côté client |

Refus automatique « sans réponse du restaurant » (`close_reason = no_response`) 10 minutes après la commande.

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
| `address_out_of_zone` | Position hors de toute zone active |
| `forbidden` | Action réservée aux admins |
| `zone_unavailable` | Zone inexistante ou désactivée |
| `courier_suspended` | Profil livreur suspendu |
| `reason_required` | Motif obligatoire |
| `not_found` | Élément introuvable |
| `cannot_target_self` | Action interdite sur son propre compte |
| `invalid_identifier` | Email ou numéro invalide |
| `cart_empty` / `invalid_quantity` | Panier vide ou quantité hors limites |
| `cart_changed` | Restaurant fermé ou produit indisponible : refaire le devis |
| `price_changed` | Le total diffère de celui affiché : refaire le devis |
| `payment_unavailable` | Moyen de paiement pas encore proposé |
| `already_accepted` | Annulation impossible : le restaurant a accepté |
| `invalid_transition` | Changement de statut non autorisé |
