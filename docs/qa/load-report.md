# Test de charge du backend

> 2026-10-19 · script `tests/load/backend.mjs` (Node, sans installation ; ADR-030) · Supabase local (Docker, PC
> Windows). Les valeurs absolues dépendront du VPS : relancer le script contre le serveur avant la mise en ligne.

## Parcours mesuré

Chaque utilisateur simulé enchaîne en boucle, sans pause : liste des restaurants (accueil), catégories et produits
du Grill du Plateau (menu), devis de commande (`quote_food_order`), ses 50 dernières commandes avec leurs articles,
et une position de livreur (`report_location`). Comptes : `.\dev-accounts.ps1`.

Seuils : **p95 < 500 ms** et **moins de 1 % d'échecs** par appel.

## Résultats

| Profil | Utilisateurs | Durée | Requêtes | Échecs | p95 le plus haut | Seuils |
|--------|-------------:|------:|---------:|-------:|-----------------:|--------|
| Smoke | 1 | 10 s | 1 194 | 0 | 12 ms | ✅ |
| Charge | 20 | 30 s | 22 518 (≈ 750 / s) | 0 | 48 ms (position du livreur) | ✅ |
| Stress | 50 | 20 s | 11 082 (≈ 550 / s) | 0 | 240 ms (position du livreur) | ✅ |

Détail du profil stress :

| Appel | p50 (ms) | p95 (ms) | Max (ms) |
|-------|---------:|---------:|---------:|
| Accueil : restaurants | 72 | 205 | 709 |
| Menu : catégories | 66 | 196 | 537 |
| Menu : produits | 69 | 213 | 632 |
| Devis de commande | 72 | 203 | 509 |
| Mes commandes | 67 | 201 | 691 |
| Position du livreur | 83 | 240 | 574 |

## Lecture

- Aucun échec, même saturé : le débit plafonne vers 550 à 750 requêtes par seconde sur ce PC, et ce sont les
  temps de réponse qui s'allongent, pas les erreurs.
- Un vrai client fait une requête toutes les quelques secondes ; un livreur en ligne envoie sa position toutes les
  30 s. 750 requêtes par seconde représentent donc plusieurs milliers d'utilisateurs actifs en même temps.
- À refaire contre le VPS (`SUPABASE_URL=https://api.<domaine> SUPABASE_ANON_KEY=… node tests/load/backend.mjs`)
  avec des comptes de test créés sur le serveur.
