# Données de test (local uniquement)

## Lancer l'app

```powershell
supabase start
.\run.ps1 -d chrome
```

## Se connecter

« Se connecter » → onglet **Téléphone**.

| Compte | Numéro | Mot de passe | Code SMS |
|--------|--------|--------------|----------|
| Client de test (créé par Claude, a déjà une adresse au Plateau) | `07 00 00 00 02` | `Demo2026` | `123456` |
| Ton compte | `07 00 00 00 01` | celui que tu as choisi | `123456` |

Le code SMS n'est demandé qu'à l'inscription. Aucun vrai SMS n'est envoyé en local.

## Rôles

- **Admin** : `.\dev-admin.ps1 +2250700000001`, puis se déconnecter / reconnecter.
- **Gérant de restaurant** : en admin, Restaurants → un restaurant → « Inviter un gérant » → `0700000002`.
  Le compte de test se déconnecte / reconnecte : l'espace Restaurant apparaît (Compte → Espaces).

## Restaurants de démonstration

Maquis Chez Tante (ouvert), Le Grill du Plateau (ouvert), Pâtisserie Akwaba (ouvert de 6 h 30 à 9 h) et leurs menus,
créés par `supabase/seed.sql`, avec leurs photos (`supabase/seed-media/`).

⚠️ `.\check.ps1` (et `supabase db reset`) vide la base : les comptes sont à recréer (« Créer un compte », mêmes numéros).
