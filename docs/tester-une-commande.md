# Tester une commande de bout en bout (3 comptes)

> Circuit : ADR-037. Comptes de test : `docs/donnees-de-test.md` (même mot de passe pour tous).
> Il faut 3 appareils (ou 2 téléphones + le PC en web) : **client** `07 00 00 00 04`, **restaurant**
> `07 00 00 00 06` (Le Grill du Plateau, ouvert de 7 h à 23 h 30), **livreur** `07 00 00 00 05`.

| # | Qui | Action | Ce qu'on doit voir |
|---|-----|--------|--------------------|
| 1 | Client | Accueil → Le Grill du Plateau → ajouter un plat → panier → **Espèces** → Commander | Commande passée **même sans livreur en ligne** (message d'information seulement) ; numéro `R-…` ; statut « En attente de confirmation » |
| 2 | Restaurant | Espace Restaurant → Nouvelles → **Accepter**, puis **Commencer la préparation** | Client : « Acceptée », puis « En préparation » |
| 3 | Restaurant | **Marquer prête** | Restaurant : « Prête · proposée aux livreurs, en attente d'acceptation » ; client : « Prête », notification « un livreur va la récupérer » |
| 4 | Livreur | Espace Livreur → passer **En ligne** (autoriser la localisation) | Dans les 10 s : la commande s'ouvre en plein écran (gain, distance jusqu'au restaurant, espèces à encaisser) et reste listée sous « Commandes à récupérer » |
| 5 | Livreur | **Accepter** | Plus aucun autre livreur ne peut la prendre ; client et restaurant : « Livreur en route vers le restaurant » + nom du livreur |
| 6 | Livreur + restaurant | Au comptoir, le livreur donne le **numéro de commande** ; le restaurant appuie sur **Remise au livreur** (ou le livreur sur « Commande récupérée ») | Statut « Récupérée » |
| 7 | Livreur | **En route** | Client : « En route », position du livreur sur la carte |
| 8 | Client → Livreur | Le client lit son **code de livraison** (écran de la commande) ; le livreur le saisit, puis confirme les espèces | Statut « Livrée » chez les trois |

**Cas à essayer aussi**

- *Aucun livreur au moment où la commande est prête* : faire les étapes 1 à 3 avec le livreur **hors ligne**. La
  commande reste « Prête » ; dès que le livreur passe en ligne (étape 4), elle lui est proposée. Après 10 min
  d'attente, le restaurant voit « Toujours sans livreur » (l'équipe est prévenue) ; le repas n'est jamais annulé
  automatiquement.
- *Désistement* : après l'étape 5, le livreur ouvre la mission → « Abandonner la mission » (motif). La commande
  redevient « Prête » et est reproposée aux autres livreurs disponibles.
- *Livreurs affiliés* (admin `07 00 00 00 03`) : Administration → Restaurants → Le Grill du Plateau → « Livreurs
  affiliés » : cocher un livreur. Seuls les livreurs cochés reçoivent alors ses commandes ; sans livreur coché,
  tous les livreurs de la zone les reçoivent.
