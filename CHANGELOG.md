# Changelog

Format : [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/) · versions [SemVer](https://semver.org/lang/fr/).

## [Non publié]

### Ajouté
- Restaurant : prévenu quand le livreur a livré la commande au client (message sur l'écran des commandes,
  notification « Commande livrée » sur le téléphone une fois Firebase créé).

### Modifié
- Notifications : autorisation demandée dès l'ouverture de l'app, une fois connecté.
- Admin : « Commandes en cours » devient « Commandes à traiter » et ne liste plus que les commandes qui demandent
  une intervention (sans livreur, restaurant sans réponse, code bloqué, problème).

### Ajouté (Inc-11, ADR-028)
- Paiement **Mobile Money** par nyole (Orange Money, MTN MoMo, Wave, Moov Money) pour les repas et les colis : page
  de paiement sécurisée, statut en direct, « Réessayer » après un refus, « Changer de moyen de paiement » (panier
  restauré), annulation sans paiement sous 15 min ; la commande n'est transmise qu'après confirmation par nyole.
- Colis : choix du moyen de paiement (espèces au retrait ou Mobile Money).
- Admin : Mobile Money activable dans les Paramètres.
- Serveur : fonctions `payments-create` et `payments-webhook-nyole` (signature vérifiée, statut relu chez nyole,
  rejeu sans effet) ; paiement arrivé après l'annulation marqué « à rembourser ».

### Modifié (Inc-11)
- Le délai de réponse du restaurant part de la transmission de la commande (après paiement en ligne).

### Ajouté (Inc-13, ADR-027)
- Remboursements : commande payée puis annulée ou refusée marquée « À rembourser » ; après un échec de livraison,
  l'admin décide du remboursement (motif) puis le marque « Remboursée » avec une référence ; le client suit l'état
  sur sa commande, dans la chronologie et par notification.
- Client : Paiements groupés par jour (Aujourd'hui, Hier…), filtres Tout / Réussies / Remboursements, reçu détaillé
  partageable (WhatsApp, SMS, copie).
- Admin : tableau de bord en accueil (jour, 7 jours, 30 jours : commandes par statut et par type, chiffre
  d'affaires, frais, commissions, rémunération des livreurs, part de la plateforme, espèces à rapprocher,
  remboursements en attente, livreurs en ligne) ; transactions filtrables par statut, moyen, période et zone.

### Corrigé (Inc-13)
- Suivi en direct : l'état du paiement et la chronologie se mettent à jour sans recharger.
- Admin : sous-total masqué pour un colis.

### Ajouté (Inc-10, ADR-026)
- Moyens de paiement par pays, activables par l'admin (Paramètres) ; seuls les moyens actifs sont proposés à la
  validation, le dernier choisi est retenu ; Mobile Money et carte affichés « Bientôt ».
- Transactions : une par commande, en attente puis réussie à l'encaissement des espèces, annulée si la commande
  l'est avant ; écran Paiements du client avec le statut de chaque transaction.
- Admin : écran « Transactions et espèces » (transactions, « livrée · non encaissée », espèces dues par livreur,
  historique des encaissements et versements, enregistrement d'un versement).

### Ajouté (Inc-9, ADR-025)
- Client : carte du livreur en temps réel sur le suivi, estimation d'arrivée, position ancienne grisée avec son âge,
  photo du livreur, bandeau « Connexion perdue — reconnexion… », rappel si les notifications sont refusées.
- Notifications push (Firebase) à chaque étape pour le client, offres et missions pour le livreur, nouvelles
  commandes et annulations pour le restaurant ; autorisation demandée une fois, après explication ; toucher → écran
  concerné. Actives dès que le projet Firebase est configuré (tâche manuelle n° 8).
- Restaurant : bip sonore des nouvelles commandes dans le navigateur, chronologie d'une commande (toucher l'en-tête).
- Livreur : son à l'arrivée d'une offre, chronologie dans l'écran de mission.

### Ajouté (Inc-8, ADR-024)
- Livreur : écran de mission (étape, carte, itinéraire Google Maps / Waze, retrait et destination avec appel,
  contenu, espèces) ; « Commande récupérée » (colis en espèces : encaissement confirmé d'abord), « Je pars livrer »,
  saisie du code à 4 chiffres (essais limités, blocage après 5 erreurs), encaissement des espèces, « Un problème ? »
  (signalement, échec de livraison), abandon avant récupération ; gains et livraisons du jour, espèces à reverser ;
  historique et gains (jour, 7 jours).
- Restaurant : nom du livreur attribué, « Remise au livreur ».
- Admin : alertes « code bloqué » et « problème signalé », commandes en échec visibles, confirmation de livraison
  sans code avec motif, statut d'encaissement.
- Client : « Votre livreur a dû annuler, nous en cherchons un autre » dans le suivi.

### Ajouté (Inc-7, ADR-023)
- Livreur : tableau de bord avec interrupteur En ligne / Hors ligne (explication puis autorisation de localisation,
  notification permanente sur Android), position partagée tant qu'il est en ligne, mission en cours ; offres en
  plein écran avec compte à rebours, gain, distances, repères et espèces à encaisser, acceptation ou refus.
- Attribution automatique au livreur éligible le plus proche, une offre à la fois ; offre suivante au refus ou à
  l'expiration ; alerte après 10 min et annulation après 30 min sans livreur (délais réglables).
- Client : livreur attribué (prénom, moyen, appel) sur le suivi, « Nous cherchons encore un livreur » avec choix
  d'attendre ou d'annuler ; commande impossible sans livreur en ligne, annoncé dès le devis ; types de colis selon
  les livreurs disponibles.
- Admin : Commandes en cours (temps réel, filtres statut / type / zone, alertes), détail avec montants séparés et
  chronologie complète, attribution et réattribution manuelles avec motif, annulation motivée ; Paramètres
  (délais, numéro du support).

### Ajouté (Inc-6)
- Livraison de colis : demande en 4 étapes (départ, arrivée, colis, récapitulatif), devis serveur, demande unique,
  code de livraison à 4 chiffres partageable (WhatsApp, SMS), annulation avant récupération (ADR-022).
- Départ et arrivée à moins de 100 m refusés (`same_location`), avec invitation à déplacer l'épingle.

### Corrigé
- Compte supprimé ou session refusée par le serveur : « Votre session a expiré… Reconnectez-vous » avec un bouton
  « Se reconnecter », au lieu de « Pas de connexion internet » et d'un « Réessayer » inutile.
- Distances et taux affichés avec une virgule (« 0,5 km », « 12,5 % ») au lieu d'un point.
- Texte d'annulation et libellé « Espèces » propres aux colis (ils parlaient du restaurant et de la livraison).

### Modifié (interface, ADR-021)
- Barre du haut visible partout (blanche, filet, ombre au défilement) ; accueil client conforme à la maquette :
  salutation et cloche, carte d'adresse, grande carte photo de la commande en cours avec progression, tuiles Repas /
  Colis illustrées, recherche et filtres par cuisine (ORD-03).
- Navigation basse Client : Accueil, Commandes, bouton central « + », Paiements (nouvel écran), Profil.
- Espace Restaurant : photo, nom et état d'ouverture dans la barre du haut, carte « Aujourd'hui » ; en-tête de profil.
- États vides illustrés et cohérents dans tous les espaces.

### Ajouté (Inc-5)
- Commande de repas : panier (un restaurant, conservé), validation avec devis serveur (frais selon la distance), paiement
  en espèces, commande unique même en cas de double envoi, suivi en direct et chronologie, annulation avant acceptation,
  « Mes commandes » et commande en cours sur l'accueil.
- Espace Restaurant : onglet Commandes en direct (nouvelles avec délai de 10 min, en cours, terminées), accepter / refuser
  avec motif, préparation, prête, totaux du jour (ventes, commission, net) ; refus automatique sans réponse.

### Modifié
- Refonte visuelle (ADR-019) : thème clair imposé, écran de bienvenue clair, vraie carte OpenStreetMap dans l'éditeur
  d'adresse (épingle animée), nouvel accueil client (adresse, services, restaurants) et fiche restaurant avec menu.
- Écran de bienvenue avec grande photo de plats ; photos des restaurants et produits de démonstration (local).

### Corrigé
- Listes triées à l'envers (catégories, produits, restaurants, zones, horaires) : tri croissant explicite.
- Débordements de l'écran de bienvenue sur les petits écrans et en grande police.

### Ajouté
- Inc-4 — restaurants et catalogue : création des restaurants par l'admin (zone, position, commission, activation)
  et invitation de leurs gérants ; espace Restaurant (menu par catégories, produits avec photo, disponibilité,
  archivage, profil, horaires, fermeture temporaire) ; ouverture calculée par le serveur.
- Scripts PowerShell à la racine : `run.ps1` (lancer l'app), `check.ps1` (mêmes contrôles que la CI),
  `dev-admin.ps1` (donner le rôle admin à un compte local).

- Inc-3 — espace Livreur (inscription avec photo, statut de validation), administration des livreurs (validation,
  refus motivé, suspension) et des comptes (recherche, suspension avec blocage de connexion, changement d'identifiant),
  journal d'audit.

- Inc-2 — zones desservies et tarifs (frais calculés par le serveur, simulateur admin), adresses client sans nom de
  rue (carte ou GPS, quartier, point de repère, instructions, adresse par défaut, refus hors zone), écran Zones et
  tarifs du back-office, liste des villes desservies dans le profil.
- Inc-1 — comptes : inscription et connexion par email ou téléphone avec mot de passe, codes de vérification
  (email, SMS), mot de passe oublié, profil obligatoire, écran Mon compte (modification, changement d'identifiant,
  déconnexion, suppression du compte), accès selon le rôle ; table profils + admins avec RLS testée ; fonction
  serveur account-delete ; documentation de l'API d'authentification (docs/api/README.md).
- Inc-0 — socle : espace de travail Dart (apps Client, Livreur, Back-office + package `core`), design system
  (jetons clair / sombre conformes AA, police Plus Jakarta Sans embarquée), textes français centralisés, navigation,
  initialisation Supabase avec session dans le stockage sécurisé, écran de bienvenue des 3 apps, projet Supabase local,
  première migration et son test pgTAP, intégration continue GitHub Actions, hooks Git (format, analyse).

### Modifié
- Une seule app mobile (`apps/mobile`) avec un espace par rôle et un écran « Changer d'espace », à la place des apps
  Client, Livreur et Back-office séparées.
