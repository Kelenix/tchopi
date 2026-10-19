# Données de test (local uniquement)

## Préparer

```powershell
supabase start
.\dev-accounts.ps1
```

`dev-accounts.ps1` crée ou remet en état les comptes ci-dessous (mot de passe, profil, rôle), sans vider la base.
À relancer après `.\check.ps1` ou `supabase db reset`, qui vident la base.

## Se connecter

« Se connecter » → numéro (avec ou sans espaces) et mot de passe **`Tchopi2026`** pour tous les comptes.

| Profil | Numéro | Ce qu'on voit |
|--------|--------|---------------|
| Admin | `07 00 00 00 03` | Administration uniquement |
| Client | `07 00 00 00 04` | Espace Client |
| Livreur (approuvé, moto) | `07 00 00 00 05` | Client + Livreur (« Changer d'espace » dans Profil) |
| Restaurant (gérante du Grill du Plateau) | `07 00 00 00 06` | Client + Restaurant |

Commande complète : client (`04`) qui commande, livreur (`05`) « En ligne » avec la localisation autorisée,
restaurant (`06`) qui accepte ; l'admin (`03`) suit tout dans Commandes en cours.

## Serveur en ligne (api.tchopi.com)

`.\dev-accounts.ps1 -Serveur` crée les mêmes quatre comptes sur le serveur (accès VPS requis), avec un mot de passe
aléatoire noté seulement sur ce PC dans `env/comptes-serveur.txt` (jamais commité).

## Créer un nouveau compte

En local, aucun vrai SMS n'est envoyé : seuls les numéros `07 00 00 00 01` à `07 00 00 00 09` sont acceptés à
l'inscription par téléphone, avec le code **`123456`** (`supabase/config.toml`, `[auth.sms.test_otp]`).
`07 00 00 00 09` est déjà pris (essai d'inscription). Par email : le code arrive sur http://127.0.0.1:54324 (PC).

`07 00 00 00 01` et `07 00 00 00 02` servent aussi aux tests automatiques : leur mot de passe peut changer.

## Restaurants de démonstration

Maquis Chez Tante (ouvert), Le Grill du Plateau (ouvert), Pâtisserie Akwaba (ouvert de 6 h 30 à 9 h) et leurs menus,
créés par `supabase/seed.sql`, avec leurs photos (`supabase/seed-media/`).
