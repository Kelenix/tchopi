# Fiches écran — MVP Livraison

> Phase 1 (INTAKE §10, étape 2). Pour chaque écran : objectif, informations, actions, validations, états, erreurs,
> stories liées (`docs/product/user-stories.md`). L'apparence suit `docs/design/direction.md` ; la maquette interactive
> (phase 3) illustre les écrans clés.
>
> **États standard** (tous les écrans de données) : *chargement* = squelettes de la forme du contenu · *vide* = illustration
> légère + phrase + action · *erreur* = message clair + « Réessayer » · *hors ligne* = bandeau « Connexion perdue —
> reconnexion… », contenu en cache conservé, actions serveur désactivées. Seuls les écarts sont précisés ci-dessous.

---

## Navigation

```
Client     : Bienvenue → (Inscription | Connexion) → Code → Profil → Accueil
             Barre basse : Accueil · Commandes · [● Colis] · Paiements · Profil
             Barre « Panier » flottante dès qu'un produit est ajouté
Livreur    : Bienvenue → (Inscription | Connexion) → Code → Profil livreur → Statut de validation → Tableau de bord
             Barre basse : Accueil · Historique · Profil ; l'offre de mission s'affiche par-dessus tout écran
Back-office: Connexion → Code → espace selon le rôle
             Restaurant (barre basse) : Commandes · Menu · Historique · Profil
             Admin (menu latéral)     : Tableau de bord · Commandes · Livreurs · Restaurants · Utilisateurs ·
                                        Transactions · Zones et tarifs · Paramètres
```

---

## Écrans communs aux 3 apps

### S-01 · Bienvenue
- **Objectif** : donner envie et orienter vers l'inscription ou la connexion.
- **Affiche** : photo plein écran (plat local / livreur), titre fort, phrase d'accroche ; boutons « Créer un compte » (plein) et « Se connecter » (contour).
- **Actions** : créer un compte · se connecter.
- **États** : statique (aucun appel réseau).
- **Stories** : AUTH-01, AUTH-02, AUTH-04.

### S-02 · Inscription
- **Objectif** : créer un compte en moins d'une minute.
- **Affiche** : sélecteur « Email » / « Téléphone » (téléphone masqué si aucun SMS configuré) ; champ email **ou** indicatif (+225 par défaut) + numéro ; mot de passe avec affichage, règle visible ; lien CGU et confidentialité.
- **Actions** : « Continuer » → envoi du code · « J'ai déjà un compte ».
- **Validations** : email valide ; numéro valide pour l'indicatif ; mot de passe ≥ 8 caractères, lettres et chiffres. Bouton actif seulement si tout est valide.
- **États** : envoi en cours (bouton avec indicateur, champs verrouillés).
- **Erreurs** : « Un compte existe déjà avec cet email / ce numéro » + « Se connecter » · « Trop de tentatives, réessayez dans 1 min ».
- **Stories** : AUTH-01, AUTH-02.

### S-03 · Code de vérification
- **Objectif** : vérifier l'email ou le numéro (inscription, récupération, changement d'identifiant).
- **Affiche** : destination masquée (« k•••@gmail.com »), 6 cases, compte à rebours avant renvoi.
- **Actions** : saisie (collage et remplissage automatique SMS sur Android) · « Renvoyer le code » (après 60 s) · « Modifier l'email / le numéro ».
- **Validations** : 6 chiffres ; validation automatique à la 6ᵉ saisie.
- **Erreurs** : « Code incorrect ou expiré » (cases secouées, vidées) · « Code renvoyé ».
- **Stories** : AUTH-01, AUTH-02, AUTH-05, AUTH-07.

### S-04 · Connexion
- **Affiche** : email ou téléphone (un seul champ qui détecte le format, indicatif si numéro), mot de passe, « Mot de passe oublié ? ».
- **Actions** : se connecter · mot de passe oublié · créer un compte.
- **Erreurs** : « Email, numéro ou mot de passe incorrect » · « Trop de tentatives, réessayez dans N min » · « Votre compte est suspendu » + « Contacter le support » · Back-office : « Accès réservé aux restaurants partenaires et à l'équipe ».
- **Stories** : AUTH-04, AUTH-09.

### S-05 · Mot de passe oublié
- **Étapes** : identifiant → code (S-03) → nouveau mot de passe + confirmation.
- **Validations** : mêmes règles qu'à l'inscription ; les deux saisies identiques.
- **Message** : « Si un compte existe, un code vient d'être envoyé » (identique dans tous les cas).
- **Stories** : AUTH-05.

### S-06 · Compléter le profil
- **Affiche** : prénom, nom, téléphone de contact (indicatif), ville (liste des villes desservies).
- **Validations** : tous obligatoires ; téléphone valide.
- **Suite** : Client → éditeur d'adresse (C-14) proposé ; Livreur → profil livreur (L-01).
- **Stories** : AUTH-03.

---

## App Client

### C-01 · Accueil
- **Objectif** : accéder aux deux services en un geste et voir sa commande en cours.
- **Affiche** : salutation (« Bonjour Aïcha »), adresse active (quartier + repère) ; **carte héro** de la commande en cours (photo, statut, ETA, barre de progression) si présente ; deux grandes tuiles **Repas** et **Colis** ; quelques restaurants ouverts à proximité (raccourci).
- **Actions** : changer l'adresse (feuille avec mes adresses + « Ajouter ») · ouvrir le suivi · ouvrir Repas · ouvrir Colis.
- **États** : affichage immédiat depuis le cache puis rafraîchissement ; sans adresse → invitation « Ajoutez votre adresse pour voir les restaurants ».
- **Erreurs** : adresse hors zone → « Nous ne livrons pas encore ici » + changer d'adresse.
- **Stories** : ORD-01, TRK-01.

### C-02 · Restaurants
- **Objectif** : choisir un restaurant de sa zone.
- **Affiche** : champ de recherche ; cartes restaurant (photo, nom, catégorie, frais estimés, temps estimé, distance, pastille Ouvert / Fermé · ouvre à HH:MM) ; ouverts d'abord, fermés grisés.
- **Actions** : rechercher · ouvrir un restaurant (transition de l'image vers le détail ; menu préchargé au toucher).
- **États** : vide → « Aucun restaurant ouvert près de vous pour le moment » ; recherche vide → « Aucun résultat pour “…” ».
- **Stories** : ORD-02, ORD-03, RES-03.

### C-03 · Détail du restaurant et menu
- **Objectif** : consulter le restaurant et remplir son panier.
- **Affiche** : grande photo, nom, catégorie, quartier, horaires, statut, frais et temps estimés ; onglets de catégories qui défilent avec la liste ; produits (photo, nom, description courte, prix, bouton « + » / compteur).
- **Actions** : ajouter (retour haptique), ajuster la quantité ; barre basse « Voir le panier · 2 articles · 7 500 F ».
- **Validations** : restaurant fermé → boutons « + » désactivés + bandeau « Fermé · ouvre à 18:00 » ; produit indisponible grisé.
- **Erreurs** : panier d'un autre restaurant → feuille « Vider le panier et commencer ici ? » (Annuler / Vider et ajouter).
- **Stories** : ORD-04, ORD-05.

### C-04 · Panier
- **Affiche** : restaurant ; lignes produit (photo, nom, prix unitaire, compteur, total ligne) ; sous-total, frais de livraison, **total** ; adresse active.
- **Actions** : modifier les quantités · supprimer (glisser ou compteur à 0) · « Valider la commande ».
- **Validations** : frais = devis serveur ; hors ligne → « à confirmer », bouton désactivé.
- **États** : vide → « Votre panier est vide » + « Voir les restaurants ».
- **Erreurs** : produit devenu indisponible → ligne signalée « N'est plus disponible » + retirer.
- **Stories** : ORD-06.

### C-05 · Validation de la commande
- **Objectif** : vérifier et confirmer en toute confiance.
- **Affiche** : restaurant, produits et quantités, sous-total, frais, total ; adresse de livraison (modifiable) ; moyen de paiement (modifiable) ; mention espèces « À payer au livreur à la livraison ».
- **Actions** : changer l'adresse · changer le moyen (C-06) · « Commander · 8 800 F ».
- **Validations serveur** : restaurant ouvert, produits disponibles, prix inchangés, adresse dans la zone, au moins un livreur en ligne ; envoi protégé contre le double toucher.
- **Erreurs** : écart → détail précis + « Mettre à jour le panier » · « Aucun livreur disponible pour le moment. Réessayez dans quelques minutes. » · « Ce restaurant vient de fermer ».
- **Succès** : espèces → suivi (C-09) ; Mobile Money / carte → paiement (C-07).
- **Stories** : ORD-07, PAY-01.

### C-06 · Moyen de paiement (feuille)
- **Affiche** : moyens disponibles seulement — Espèces ; Mobile Money avec logos des opérateurs intégrés ; Carte bancaire (si Stripe actif) ; dernier moyen présélectionné.
- **Actions** : choisir · pour Mobile Money : opérateur + numéro (prérempli, modifiable).
- **Validations** : numéro valide pour l'opérateur.
- **Stories** : PAY-01.

### C-07 · Paiement en cours
- **Objectif** : payer sans jamais croire à tort que c'est payé.
- **Mobile Money** : montant, opérateur, instructions (« Composez … / validez la demande sur votre téléphone »), statut en direct « En attente de confirmation », compte à rebours 15 min.
- **Carte** : feuille de paiement Stripe native (3-D Secure si demandé), puis attente de la confirmation serveur.
- **Actions** : « Changer de moyen de paiement » · « Annuler la commande ».
- **États** : en attente · **réussi** (seulement après confirmation serveur) → suivi · échoué → message + « Réessayer » / « Changer de moyen » · expiré → « Commande annulée, aucun montant n'a été validé ».
- **Reprise** : en revenant sur l'app, le statut réel est relu.
- **Stories** : PAY-03, PAY-04, PAY-05.

### C-08 · Demande de colis (4 étapes)
- **Objectif** : envoyer un colis avec des formulaires courts.
- **Étape 1 — Départ** : mes adresses ou un point sur la carte + repère. **Étape 2 — Arrivée** : point sur la carte + repère + instructions. **Étape 3 — Colis** : nom et téléphone du destinataire, type (Documents · Petit colis ≤ 5 kg · Colis moyen ≤ 15 kg), description, instructions, case « Mon colis respecte la liste des objets autorisés » (lien vers la liste). **Étape 4 — Récapitulatif** : trajet sur la carte, distance de référence, frais, total, moyen de paiement (espèces : « À payer au livreur à la récupération »).
- **Actions** : suivant / précédent (indicateur « 2/4 ») · « Confirmer · 1 300 F ».
- **Validations** : les deux points dans la même zone ; téléphone destinataire valide ; case cochée ; livreurs en ligne.
- **Erreurs** : « Les livraisons entre villes ne sont pas disponibles » · « Cette adresse est hors de la zone desservie » · aucun livreur (comme C-05).
- **Succès** : identifiant « C-7K2P9 », code de livraison et bouton « Partager au destinataire » → suivi.
- **Stories** : PAR-01 à PAR-04.

### C-09 · Suivi de livraison
- **Objectif** : savoir à tout instant où en est la commande.
- **Affiche** : pastille de statut ; frise d'étapes (repas : Confirmée · En préparation · Livreur assigné · Récupérée · En route · Livrée ; colis : Confirmée · Recherche · Livreur assigné · Récupéré · En route · Livré) ; carte avec point de retrait, destination et livreur ; ETA ; carte livreur (photo, prénom, moyen, immatriculation, « Appeler ») ; **code de livraison** bien visible (+ « Partager » pour un colis) ; résumé commande et paiement.
- **Actions** : appeler le livreur · partager le code · annuler (si autorisé, feuille de confirmation) · « Contacter le support ».
- **États** : recherche de livreur (animation douce « Nous cherchons un livreur… ») ; après 10 min → choix « Continuer d'attendre » / « Annuler » ; position ancienne → marqueur grisé « il y a 3 min », ETA « indisponible » ; hors ligne → bandeau.
- **États finaux** : Livrée (heure, reçu) · Annulée / Refusée (motif + statut du remboursement) · Échec (motif + support).
- **Stories** : TRK-01 à TRK-03, DIS-03, ORD-11, PAR-04, PAR-05.

### C-10 · Commandes
- **Affiche** : section « En cours » (cartes compactes avec statut) puis historique paginé (date, type, restaurant ou trajet, total, statut).
- **Actions** : ouvrir le suivi ou le détail.
- **États** : vide → « Pas encore de commande » + « Commander un repas ».
- **Stories** : ORD-12.

### C-11 · Détail d'une commande
- **Affiche** : numéro, date, statut ; produits ou colis ; sous-total, frais, total ; adresse(s) ; moyen et statut de paiement ; chronologie horodatée ; livreur.
- **Actions** : voir le reçu · contacter le support.
- **Stories** : ORD-12, TRK-03, TRX-02.

### C-12 · Paiements
- **Affiche** : transactions groupées par date (Aujourd'hui, Hier, 5 oct.), icône du moyen, commande, montant coloré (payé / remboursé), statut ; détail d'une transaction : identifiant, commande, montant, devise, moyen, opérateur, date, statut, référence fournisseur ; **reçu** (numéro, date, détail des montants) partageable.
- **Actions** : filtrer (Tout · Réussies · Remboursements) · ouvrir · partager le reçu.
- **États** : vide → « Aucun paiement pour l'instant ».
- **Stories** : TRX-01, TRX-02, TRX-03.

### C-13 · Mes adresses
- **Affiche** : liste (libellé, quartier, repère, badge « Par défaut »).
- **Actions** : ajouter · modifier · supprimer (confirmation) · définir par défaut.
- **États** : vide → « Ajoutez votre première adresse ».
- **Stories** : ADR-04, ADR-05.

### C-14 · Éditeur d'adresse
- **Affiche** : carte plein écran avec épingle centrale fixe (on déplace la carte), bouton « Ma position » ; feuille basse : quartier, point de repère, instructions, libellé.
- **Actions** : ma position (explication puis autorisation système) · enregistrer.
- **Validations** : position dans une zone active ; quartier et repère obligatoires.
- **Erreurs** : localisation refusée → placement manuel + lien réglages · « Cette adresse est hors de la zone desservie » · GPS imprécis → « Précision faible, ajustez l'épingle ».
- **Stories** : ADR-01 à ADR-03.

### C-15 · Profil
- **Affiche** : prénom, nom, téléphone, email ou numéro de connexion, ville ; raccourcis : Mes adresses, Paiements, Support, CGU, Confidentialité.
- **Actions** : modifier (AUTH-07) · se déconnecter (confirmation) · supprimer mon compte (feuille expliquant la conséquence).
- **Erreurs** : suppression avec commande en cours → « Terminez ou annulez d'abord votre commande en cours ».
- **Stories** : AUTH-06, AUTH-07, AUTH-08.

---

## App Livreur

### L-01 · Profil livreur (inscription)
- **Affiche** : prénom, nom, téléphone, zone, moyen de transport (tuiles icône : moto, vélo, voiture, à pied), immatriculation (si moto / voiture), photo de profil.
- **Actions** : prendre une photo ou choisir dans la galerie · « Soumettre mon profil ».
- **Validations** : champs obligatoires ; immatriculation requise si motorisé ; photo obligatoire.
- **Stories** : COU-01, COU-02.

### L-02 · Statut de validation
- **Affiche** : statut illustré — En attente (« Nous vérifions votre profil ») · Refusé (motif) · Suspendu (motif) ; numéro du support.
- **Actions** : modifier et soumettre à nouveau (si refusé) · appeler le support.
- **Mise à jour** : en temps réel ; passage automatique au tableau de bord une fois approuvé.
- **Stories** : COU-02, COU-03.

### L-03 · Tableau de bord et disponibilité
- **Affiche** : **grand interrupteur En ligne / Hors ligne** ; mission en cours (carte) ; gains du jour ; espèces à reverser ; nombre de missions du jour.
- **Actions** : passer en ligne (explication + autorisation de localisation, notification permanente « Vous êtes en ligne ») · hors ligne · ouvrir la mission.
- **Validations** : hors ligne impossible pendant une mission ; en ligne impossible si non approuvé.
- **Erreurs** : localisation refusée → « La localisation est nécessaire pour recevoir des missions » + réglages · GPS désactivé → « Activez le GPS ».
- **Stories** : COU-05, MIS-01.

### L-04 · Nouvelle demande (offre de mission)
- **Objectif** : décider en quelques secondes.
- **Affiche** (plein écran, par-dessus tout) : type (Repas / Colis), **gain**, distance jusqu'au retrait, distance totale, quartier + repère du départ et de l'arrivée, montant à encaisser si espèces, **anneau de compte à rebours 45 s**.
- **Actions** : « Accepter » (bouton large) · « Refuser ».
- **États** : acceptation en cours · acceptée → L-05 · expirée → « Offre expirée » · déjà prise / annulée → « Cette mission n'est plus disponible ».
- **Stories** : DIS-02, NOT-02.

### L-05 · Mission (détail et livraison en cours)
- **Affiche** : étape courante en tête (Aller au retrait → Récupérer → Livrer) ; point de retrait (nom, quartier, repère, instructions, « Appeler ») ; destination (nom, quartier, repère, instructions, « Appeler ») ; contenu (produits ou type de colis) ; montant à encaisser.
- **Actions selon l'étape** : « Itinéraire » (L-06) · « Commande récupérée » (avec confirmation d'encaissement pour un colis en espèces) · « Je pars livrer » · « Arrivé — saisir le code » (L-07) · « Un problème ? » (L-08) · « Abandonner » (avant récupération, motif).
- **Validations** : récupération refusée si le repas n'est pas « Prête » ; chaque action est confirmée par le serveur avant changement d'écran.
- **États** : mission annulée par le client ou l'admin → écran « Mission annulée » + retour au tableau de bord.
- **Stories** : MIS-02, MIS-04, MIS-05, MIS-09.

### L-06 · Navigation et itinéraire
- **Affiche** : carte avec ma position et la prochaine étape, distance à vol d'oiseau.
- **Actions** : « Ouvrir dans Google Maps » / « Waze » · recentrer.
- **Stories** : MIS-03.

### L-07 · Confirmation par code
- **Affiche** : 4 grandes cases, rappel « Demandez le code au destinataire », essais restants.
- **Actions** : valider · « Le destinataire n'a pas de code » → appeler le support (procédure admin).
- **États** : code faux → secousse + « Code incorrect, 3 essais restants » · bloqué (5 erreurs) → « Saisie bloquée, contactez le support » · succès → **Encaisser** (si espèces : « Encaissez 7 500 F » → « J'ai reçu 7 500 F ») → écran « Livraison terminée · +1 100 F ».
- **Stories** : MIS-06, MIS-07, PAY-02.

### L-08 · Signaler un problème (feuille)
- **Affiche** : motifs (client injoignable, adresse introuvable, destinataire absent, autre + commentaire) ; boutons « Appeler le client », « Appeler le support ».
- **Actions** : signaler · « Déclarer l'échec de livraison » (après récupération, confirmation).
- **Stories** : MIS-08.

### L-09 · Historique et gains
- **Affiche** : total des gains (jour / semaine), missions (date, type, trajet, gain, statut), espèces encaissées et versées.
- **États** : vide → « Vos missions apparaîtront ici ».
- **Stories** : MIS-10, ADM-04.

### L-10 · Profil livreur
- **Affiche** : photo, identité, moyen de transport, immatriculation, statut du compte.
- **Actions** : modifier (re-validation par l'admin si moyen ou immatriculation change) · se déconnecter · supprimer le compte · support.
- **Stories** : COU-03, AUTH-06 à AUTH-08.

---

## Back-office — espace Restaurant (Android tablette / téléphone, navigateur)

### R-01 · Commandes
- **Objectif** : ne rater aucune commande.
- **Affiche** : colonnes ou onglets **Nouvelles** (compte à rebours 10 min, alerte sonore répétée) · **En préparation** · **Prêtes** (livreur assigné ou « recherche de livreur ») ; interrupteur « Fermé temporairement ».
- **Actions** : ouvrir une commande · accepter / refuser directement depuis la carte.
- **États** : vide → « Aucune commande pour le moment » ; hors ligne → bandeau rouge persistant « Hors ligne : vous ne recevez plus les commandes ».
- **Stories** : ORD-08, RES-03, NOT-03.

### R-02 · Détail d'une commande
- **Affiche** : numéro, heure, produits et quantités, sous-total, mode de paiement, livreur assigné (nom, photo, téléphone), chronologie.
- **Actions selon l'état** : Accepter · Refuser (motif obligatoire) · En préparation · Prête · Remise au livreur.
- **Erreurs** : action refusée par le serveur (déjà annulée) → « Cette commande a été annulée » et retour.
- **Stories** : ORD-09, ORD-10.

### R-03 · Menu
- **Affiche** : produits groupés par catégorie (photo, nom, prix, interrupteur Disponible).
- **Actions** : ajouter · modifier · basculer la disponibilité · archiver.
- **États** : vide → « Ajoutez votre premier produit ».
- **Stories** : RES-04, RES-05.

### R-04 · Éditeur de produit
- **Affiche** : photo (prise ou galerie, recadrage carré), nom, description, prix (F CFA), catégorie (existante ou nouvelle), disponible.
- **Validations** : nom et prix obligatoires, prix entier > 0.
- **Stories** : RES-04, RES-05.

### R-05 · Profil et horaires
- **Affiche** : photo de couverture, description, téléphone, temps de préparation moyen, horaires par jour (plages), commission (lecture seule).
- **Validations** : plages horaires cohérentes (ouverture < fermeture).
- **Stories** : RES-02, RES-03.

### R-06 · Historique
- **Affiche** : commandes par jour (heure, numéro, statut, montant) ; totaux du jour : ventes, commission, net à recevoir.
- **Actions** : changer de jour.
- **Stories** : ORD-13.

---

## Back-office — espace Admin (navigateur)

### A-01 · Tableau de bord
- **Affiche** : période (jour / semaine / mois) ; indicateurs : commandes par statut et type, chiffre d'affaires, frais, commissions, rémunération livreurs, espèces à rapprocher, livreurs en ligne ; bandeau d'alertes cliquables.
- **Stories** : ADM-06, ADM-03.

### A-02 · Commandes (supervision)
- **Affiche** : liste en temps réel filtrable (statut, type, zone, alertes) ; détail : contenu, montants séparés, acteurs, chronologie complète (acteur, date, motif), paiement.
- **Actions selon l'état** : attribuer / réattribuer (A-03) · annuler (motif) · confirmer la livraison sans code (motif) · marquer un remboursement effectué.
- **Stories** : ADM-03, MIS-07, TRX-03.

### A-03 · Attribution manuelle (feuille)
- **Affiche** : livreurs en ligne de la zone triés par distance du retrait (photo, moyen, statut, fraîcheur de la position).
- **Actions** : attribuer avec motif.
- **Erreurs** : « Ce livreur vient d'accepter une autre mission ».
- **Stories** : DIS-04.

### A-04 · Livreurs
- **Affiche** : onglets En attente · Approuvés · Refusés · Suspendus ; fiche : identité, photo, moyen, immatriculation, zone, missions, abandons, espèces dues.
- **Actions** : approuver · refuser (motif) · suspendre / réactiver (motif) · enregistrer un versement d'espèces.
- **Stories** : COU-04, ADM-04.

### A-05 · Restaurants
- **Affiche** : liste (statut, zone, commission) ; fiche complète.
- **Actions** : créer (A-05 formulaire : nom, description, photo, position sur la carte, quartier, repère, zone, téléphone, commission, email ou numéro du gérant) · modifier · activer / désactiver.
- **Stories** : RES-01.

### A-06 · Utilisateurs
- **Affiche** : recherche (nom, email, téléphone) ; fiche : rôles, statut, date d'inscription, commandes.
- **Actions** : suspendre / réactiver (motif) · modifier l'identifiant de connexion (tracé).
- **Stories** : ADM-02.

### A-07 · Transactions et espèces
- **Affiche** : liste filtrable (statut, moyen, opérateur, date, zone) ; détail ; onglet « Espèces » : solde dû par livreur, encaissements, versements.
- **Actions** : marquer « Remboursée » (référence) · enregistrer un versement.
- **Stories** : ADM-04, TRX-03.

### A-08 · Zones et tarifs
- **Affiche** : zones (carte avec cercles) ; pour chaque zone et service : base, prix/km, plancher, plafond, détour, rémunération livreur ; **simulateur** « distance → frais » pour vérifier une règle avant de l'enregistrer.
- **Actions** : créer / modifier / désactiver une zone · modifier les règles.
- **Validations** : valeurs ≥ 0, plancher ≤ plafond, rayon > 0.
- **Stories** : ADR-06, ADR-07.

### A-09 · Paramètres
- **Affiche** : délais (offre, réponse restaurant, expiration paiement, alerte / annulation de recherche), numéro du support, moyens de paiement et opérateurs actifs par pays.
- **Stories** : ADM-05, PAY-01.
