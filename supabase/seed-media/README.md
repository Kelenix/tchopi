# Images de démonstration — prompts

✅ Intégrées : versions optimisées dans `media/demo/` (envoyées dans le bucket « media » par `supabase start` /
`db reset`, déclaré dans `config.toml`) ; photo de bienvenue dans `packages/core/assets/images/`. Les originaux
restent dans `originaux/` (non versionné). Pour remplacer une image : même nom dans `media/demo/`, puis
`supabase seed buckets`.

- Catalogue élargi (`demo-catalog.sql`) : photos fournies par le porteur du projet, recadrées en carré (produits) et en 16:9
  (`cover-*.jpg`, couvertures).
- Format : JPG, moins de 500 Ko chacune.
- Couvertures : **paysage 16:9** (1600 × 900). Produits : **carré** (800 × 800). Bienvenue : **portrait** (1080 × 1600).
- Aucun texte, logo, filigrane ni visage reconnaissable dans les images.

**Style commun** (à ajouter à la fin de chaque prompt) :

> realistic professional food photography, natural warm daylight, shallow depth of field, appetizing, vibrant but
> natural colors, clean modern composition, no text, no logo, no watermark, no recognizable faces

## Écran de bienvenue

| Fichier | Prompt |
|---------|--------|
| `welcome-hero.jpg` | Top-down view of a colorful Ivorian meal spread on a light wooden table in Abidjan: garba with fried tuna, alloco, grilled fish, a glass of red bissap juice, fresh chili and lime, generous empty light space in the upper half, portrait 2:3 |

## Couvertures des restaurants (16:9)

| Fichier | Prompt |
|---------|--------|
| `cover-maquis-chez-tante.jpg` | Lively open-air Ivorian maquis restaurant at golden hour, plates of attiéké with grilled fish and alloco on a wooden table in the foreground, warm string lights and plants in the soft-focus background, 16:9 |
| `cover-grill-du-plateau.jpg` | Close-up of beef skewers and chicken grilling over glowing charcoal on an African street-food grill, light smoke, sliced onions and chili beside, dark warm background, 16:9 |
| `cover-patisserie-akwaba.jpg` | Bright modern bakery counter with golden croissants, pains au chocolat and glasses of fresh mango and pineapple juice, white marble surface, morning light, 16:9 |

## Produits (carré)

| Fichier | Prompt |
|---------|--------|
| `garba.jpg` | Ivorian garba: a mound of attiéké (cassava couscous) with crispy fried tuna pieces, sliced raw onion, tomato and fresh chili on a simple plate, 45-degree angle, square |
| `alloco-poisson.jpg` | Golden fried plantain slices (alloco) with a whole grilled fish, spicy tomato-onion sauce on the side, on a plate, 45-degree angle, square |
| `kedjenou-poulet.jpg` | Ivorian chicken kedjenou stew in a clay pot, rich tomato and vegetable sauce, small bowl of attiéké beside, square |
| `bissap.jpg` | Tall glass bottle and glass of deep red hibiscus bissap juice with ice and mint, condensation drops, dried hibiscus flowers around, square |
| `gnamakoudji.jpg` | Glass of cloudy pale-yellow fresh ginger juice (gnamakoudji) with ice, fresh ginger root and lime slices beside, square |
| `brochettes-boeuf.jpg` | Four grilled beef skewers on a plate with raw onion rings, chili and a sprinkle of spices, square |
| `poulet-dg.jpg` | Cameroonian-style poulet DG: chicken pieces sautéed with fried ripe plantain, carrots and green beans in a skillet, square |
| `croissant.jpg` | One golden flaky butter croissant on a white plate, crumbs around, square |
| `pain-au-chocolat.jpg` | One pain au chocolat cut in half showing the chocolate, on a white plate, square |
