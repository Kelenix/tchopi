# Cartographie en Côte d'Ivoire : évaluation et choix (ADR-039)

> Octobre 2026. Quatre besoins distincts, chacun servi par le service le plus adapté. La carte de l'app
> reste en place ; rien de payant n'est nécessaire pour lancer.

## 1. Les quatre besoins

| Besoin | Où dans l'app | Service retenu | Coût |
|---|---|---|---|
| **Affichage** (fond de carte) | Adresses, colis, suivi client, mission livreur | OpenFreeMap (données OpenStreetMap), tuiles vectorielles, styles « positron » (clair) et « dark » (sombre) | Gratuit, sans clé |
| **Recherche de lieux** | Bouton loupe des cartes de sélection (adresse, colis) | Photon (données OpenStreetMap), limité à la Côte d'Ivoire, proche de la carte d'abord | Gratuit (service public, usage modéré) |
| **Calcul d'itinéraire** (trajet tracé) | Suivi client, mission livreur | OSRM sur le VPS (`https://api.tchopi.com/route/…`, carte Geofabrik mise à jour chaque dimanche) | Inclus dans le VPS |
| **Navigation** (guidage vocal) | Bouton « Ouvrir la navigation » du livreur | Application du téléphone : Google Maps, Waze, OsmAnd… (Android propose celles installées), Plans sur iPhone | Gratuit |

L'adresse d'un client reste **l'épingle posée sur la carte + quartier + point de repère** : en Côte d'Ivoire, les
rues sont rarement nommées et les numéros quasi inexistants. La recherche sert à **amener la carte au bon endroit**
(quartier, carrefour, pharmacie, marché…), l'épingle fait foi.

## 2. Couverture réelle mesurée (OpenStreetMap)

Essais du 20/10/2026, sans clé, sur les services publics :

| Recherche | Nominatim | Photon |
|---|---|---|
| Riviera 2, Cocody | ✅ quartier | ✅ |
| Carrefour de la Vie | ✅ carrefour | ✅ |
| Yopougon Maroc | ✅ quartier | ✅ |
| Koko, Bouaké | ❌ | ✅ quartier |
| Pharmacie Saint-Jean, Cocody | ✅ pharmacie | ✅ |
| Marché d'Adjamé | ❌ | ✅ (même sans accents) |
| Lobia, Tazibouo (Daloa) | ✅ quartiers | ✅ |
| Gare de Bassam, Treichville | ✅ | ✅ |
| Riviera Palmeraie, Sococé, Cap Sud, PlaYce Marcory | — | ✅ |
| Gare routière d'Adjamé | — | ❌ (résultat hors pays avant filtrage) |

- **Villes et quartiers** : bons à Abidjan et dans les grandes villes ; plus clairsemés dans les petites villes,
  d'où la liste de quartiers intégrée à l'app en complément (`places_reference.dart`).
- **Routes** : réseau routier complet sur Abidjan (trajets OSRM réalistes vérifiés : Plateau → Riviera).
- **Lieux** : commerces, pharmacies, arrêts, centres commerciaux présents à Abidjan ; moins de lieux dans
  l'intérieur du pays.
- **Adresses postales** : absentes partout (normal en Côte d'Ivoire), quel que soit le fournisseur.

**Conclusion** : la couverture suffit pour la commande et le suivi. Photon trouve mieux que Nominatim (recherche
approximative, sans accents), c'est lui qui est branché. La recherche est limitée au pays.

## 3. Comparaison avec les solutions payantes

| | OpenStreetMap (actuel) | Google Maps Platform | Mapbox |
|---|---|---|---|
| Couverture CI (lieux, commerces) | Bonne à Abidjan, moyenne ailleurs | La meilleure (fiches commerces) | OpenStreetMap + données propres, proche d'OSM |
| Affichage mobile | Gratuit | SDK Android/iOS gratuit (illimité) ; web 7 $/1000 après 10 000/mois | Gratuit jusqu'à 25 000 utilisateurs/mois |
| Recherche (autocomplétion) | Gratuit (Photon) | 2,83 $/1000 requêtes après 10 000/mois | Offre gratuite puis payante |
| Itinéraire | Gratuit (OSRM hébergé) | 5 $/1000 après 10 000/mois | Offre gratuite puis payante |
| Navigation intégrée | — (app externe) | Navigation SDK : 25 $/1000 après 1 000/mois | Navigation SDK payant |
| Clé, carte bancaire, compte | Aucun | Compte de facturation Google obligatoire | Compte et clé |

Tarifs Google : grille officielle (developers.google.com/maps/billing-and-pricing/pricing), octobre 2026.

**Navigation par application externe (votre choix)** : retenu. Le livreur garde l'application qu'il connaît (Waze et
Google Maps sont très utilisés à Abidjan), avec trafic en direct et guidage vocal, sans coût ni SDK lourd dans l'app.
Une navigation intégrée (SDK Google) ne se justifierait que pour suivre le livreur pas à pas dans l'app : le suivi
par position (toutes les quelques secondes) suffit déjà au client.

## 4. Quand passer à un service payant

- **Recherche** : si les clients ne trouvent pas leurs lieux (à mesurer : recherches sans résultat), brancher Google
  Places Autocomplete sur le même bouton (`PLACES_SEARCH_URL` / `place_search.dart`, un seul fichier à adapter).
  Jusqu'à 10 000 recherches par mois gratuites.
- **Volume** : le service public Photon demande un usage modéré. Au-delà de quelques milliers de recherches par
  jour, héberger Photon sur un serveur (≈ 2 Go de mémoire pour la Côte d'Ivoire) ou passer à un fournisseur payant.
- **Affichage** : OpenFreeMap n'impose pas de limite ; rien à changer.
