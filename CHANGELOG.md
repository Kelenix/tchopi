# Changelog

Format : [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/) · versions [SemVer](https://semver.org/lang/fr/).

## [Non publié]

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
