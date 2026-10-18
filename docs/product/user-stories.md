# User stories — MVP Livraison (repas + colis)

> Phase 1 (rôle : Product Owner). Source : `INTAKE.md` + décisions D-1 à D-7 et hypothèses H-01 à H-20
> (`docs/plan-de-realisation.md`). Chaque story trace vers une exigence ; la matrice de couverture est en fin de document.
>
> **Format** : `ID · Titre — Priorité · Taille · Incrément`. Priorité MoSCoW (Must / Should / Could / Won't).
> Taille relative S / M / L. Critères au format *Étant donné … quand … alors …*.
> Les montants d'exemple sont en XOF (« F CFA »), sans décimales.

## Personas et contextes d'usage

| Persona | Contexte mobile | Attentes |
|---------|-----------------|----------|
| **Aïcha, cliente** (Abidjan, Android d'entrée de gamme, forfait limité) | Commande depuis le bureau ou la maison, réseau 3G/4G variable | Commander vite, savoir où est sa commande, payer comme elle veut (Mobile Money surtout) |
| **Koffi, livreur** (moto, Android modeste, sur la route toute la journée) | Téléphone sur support, réseau qui coupe, batterie précieuse | Missions claires, adresses compréhensibles (repères), un appel en un geste, gains visibles |
| **Mariam, gérante de restaurant** (tablette ou téléphone Android au comptoir) | Coup de feu aux heures de repas, mains occupées | Ne rater aucune commande, statuts en un toucher, menu facile à tenir à jour |
| **Serge, administrateur** (ordinateur, navigateur) | Supervision continue des opérations | Voir les problèmes immédiatement, agir (attribuer, annuler, rembourser), régler les paramètres |
| *Destinataire d'un colis* (n'a pas forcément l'app) | Reçoit un appel du livreur | Recevoir le code de livraison de l'expéditeur, remettre le code au livreur |

---

## A. Comptes et accès — Inc-1

#### AUTH-01 · Inscription par email — Must · M · Inc-1
En tant que **client ou livreur**, je veux créer un compte avec mon email et un mot de passe afin de ne pas dépendre des SMS.
- Étant donné un email inutilisé et un mot de passe d'au moins 8 caractères (lettres et chiffres), quand je valide, alors un code à 6 chiffres est envoyé à cet email et l'écran de saisie du code s'ouvre.
- Étant donné le bon code saisi avant expiration (10 min), quand je valide, alors mon compte est vérifié et j'accède à la saisie du profil (AUTH-03).
- Étant donné un code faux ou expiré, quand je valide, alors « Code incorrect ou expiré » s'affiche et je peux demander un nouveau code (au plus une fois par minute).
- Étant donné un email déjà utilisé, quand je valide, alors « Un compte existe déjà avec cet email » s'affiche avec un lien « Se connecter ».

#### AUTH-02 · Inscription par téléphone — Must · M · Inc-1
En tant que **client ou livreur**, je veux créer un compte avec mon numéro et un mot de passe afin de ne pas avoir besoin d'email.
- Étant donné qu'un fournisseur SMS est configuré, quand j'ouvre l'inscription, alors l'option « Téléphone » est proposée ; sinon elle n'apparaît pas.
- Étant donné l'indicatif +225 présélectionné (modifiable) et un numéro valide pour ce pays, quand je valide, alors un code SMS est envoyé et l'écran de saisie du code s'ouvre.
- Étant donné un numéro invalide pour l'indicatif choisi, quand je saisis, alors « Numéro invalide » s'affiche avant tout envoi.
- Étant donné le bon code, quand je valide, alors le numéro est vérifié et j'accède à la saisie du profil.

#### AUTH-03 · Compléter mon profil — Must · S · Inc-1
En tant qu'**utilisateur**, je veux renseigner mes informations afin d'être joignable pour mes livraisons.
- Étant donné un compte vérifié sans profil, quand je me connecte, alors le formulaire prénom, nom, téléphone (obligatoire, prérempli s'il a servi à l'inscription), ville (parmi les villes desservies) s'affiche.
- Étant donné le profil complet, quand je valide, alors j'arrive à l'accueil ; dans l'app client, la création de l'adresse principale est proposée (ADR-02).

#### AUTH-04 · Se connecter — Must · S · Inc-1
En tant qu'**utilisateur**, je veux me connecter avec mon email ou mon numéro et mon mot de passe afin de retrouver mon compte.
- Étant donné des identifiants corrects, quand je valide, alors je suis connecté et je le reste au redémarrage de l'app (session renouvelée automatiquement, jetons dans le stockage sécurisé).
- Étant donné des identifiants incorrects, quand je valide, alors « Email, numéro ou mot de passe incorrect » s'affiche (sans préciser lequel).
- Étant donné trop de tentatives, quand je réessaie, alors l'attente imposée est indiquée.
- Étant donné un compte suspendu, quand je me connecte, alors « Votre compte est suspendu » s'affiche avec le bouton « Contacter le support ».

#### AUTH-05 · Récupérer l'accès à mon compte — Must · S · Inc-1
En tant qu'**utilisateur**, je veux réinitialiser mon mot de passe afin de récupérer mon compte.
- Étant donné mon email ou mon numéro, quand je demande la réinitialisation, alors un code m'est envoyé par le même canal (message identique que le compte existe ou non).
- Étant donné le bon code et un nouveau mot de passe valide, quand je valide, alors je suis connecté avec le nouveau mot de passe.
- Étant donné que j'ai perdu l'accès à mon email et à mon numéro, quand je contacte le support, alors l'admin peut modifier mon identifiant de connexion (ADM-02).

#### AUTH-06 · Se déconnecter — Must · S · Inc-1
- Étant donné une session ouverte, quand je choisis « Se déconnecter » et confirme, alors la session est révoquée, les données locales personnelles (cache, panier) sont effacées et j'arrive à l'écran de bienvenue.
- Étant donné un livreur en ligne, quand il se déconnecte, alors il passe d'abord hors ligne ; c'est refusé s'il a une mission en cours.

#### AUTH-07 · Modifier mes informations — Must · S · Inc-1
- Étant donné mon profil, quand je modifie prénom, nom, téléphone de contact ou ville et enregistre, alors les changements sont sauvegardés et confirmés.
- Étant donné que je modifie mon email ou mon numéro de connexion, quand j'enregistre, alors un code de vérification est envoyé au nouvel identifiant, qui ne remplace l'ancien qu'après validation.

#### AUTH-08 · Supprimer mon compte — Must · S · Inc-1
En tant qu'**utilisateur**, je veux supprimer mon compte afin que mes données personnelles ne soient plus conservées (exigence des stores).
- Étant donné aucune commande ni mission en cours, quand je confirme la suppression (feuille de confirmation expliquant la conséquence), alors je suis déconnecté et mes données personnelles sont anonymisées ; les commandes et transactions restent pour la comptabilité, sans donnée identifiante.
- Étant donné une commande ou une mission en cours, quand je demande la suppression, alors « Terminez ou annulez d'abord votre commande en cours » s'affiche.

#### AUTH-09 · Accès selon le rôle — Must · M · Inc-1
- Étant donné tout compte, quand il ouvre l'app Client, alors il y a accès.
- Étant donné un compte sans profil livreur, quand il ouvre l'app Livreur, alors il arrive sur l'inscription livreur (COU-01).
- Étant donné un compte qui n'est ni membre d'un restaurant ni admin, quand il se connecte au Back-office, alors « Accès réservé aux restaurants partenaires et à l'équipe » s'affiche.
- Étant donné un compte membre d'un restaurant, quand il se connecte au Back-office, alors il arrive dans l'espace Restaurant ; un admin arrive dans l'espace Admin.
- Les contrôles sont faits **côté serveur** : un écran forcé ne donne accès à aucune donnée non autorisée.

---

## B. Zones et adresses — Inc-2

#### ADR-01 · Autoriser la localisation — Must · S · Inc-2
- Étant donné que j'ajoute une adresse, quand l'app a besoin de ma position, alors une explication s'affiche **avant** la demande d'autorisation du système (jamais au lancement de l'app).
- Étant donné un refus, quand je continue, alors je place l'épingle manuellement sur la carte, sans blocage.
- Étant donné un refus définitif, quand je touche « Ma position », alors un lien vers les réglages du téléphone est proposé.

#### ADR-02 · Ajouter une adresse — Must · M · Inc-2
En tant que **client**, je veux enregistrer une adresse sans connaître le nom de ma rue afin d'être livré au bon endroit.
- Étant donné la carte centrée sur ma position (ou le centre de la ville), quand je déplace l'épingle, alors la position est mise à jour.
- Étant donné la position choisie, quand je renseigne quartier (prérempli si le téléphone le propose), point de repère (obligatoire), instructions (facultatif) et libellé (Maison, Bureau, Autre), alors je peux enregistrer.
- Exemple valide : Abidjan · Cocody · « Derrière la pharmacie centrale » · « Maison avec portail bleu ».
- Étant donné ma première adresse, quand je l'enregistre, alors elle devient l'adresse par défaut.

#### ADR-03 · Contrôle de la zone desservie — Must · S · Inc-2
- Étant donné une position hors de toute zone active, quand j'enregistre, alors « Cette adresse est hors de la zone desservie » s'affiche et l'adresse n'est pas enregistrée.
- La ville de l'adresse est celle de la zone qui contient la position (pas de saisie libre).

#### ADR-04 · Modifier ou supprimer une adresse — Must · S · Inc-2
- Étant donné une adresse, quand je la modifie, alors les commandes déjà passées gardent l'adresse d'origine (copie figée sur la commande).
- Étant donné une adresse, quand je la supprime (confirmation), alors elle disparaît ; si c'était l'adresse par défaut, la plus récente restante devient l'adresse par défaut.

#### ADR-05 · Choisir l'adresse par défaut — Must · S · Inc-2
- Étant donné plusieurs adresses, quand j'en choisis une par défaut, alors elle seule est marquée par défaut et sert à l'accueil et au panier.

#### ADR-06 · Gérer les zones desservies (admin) — Must · M · Inc-2
- Étant donné l'espace Admin, quand je crée une zone (nom, ville, pays, devise, centre sur la carte, rayon en km, active), alors elle devient disponible pour les adresses, restaurants et livreurs.
- Étant donné une zone désactivée, quand un client y place une adresse, alors l'adresse est refusée ; les commandes en cours ne sont pas affectées.

#### ADR-07 · Règles tarifaires par zone (admin) — Must · M · Inc-2
- Étant donné une zone, quand je définis pour chaque service (repas, colis) : base, prix par km, plancher, plafond, coefficient de détour, pas d'arrondi, rémunération livreur (fixe + par km), alors tout nouveau devis applique ces règles.
- Exemple : base 500 F, 150 F/km, plancher 500 F, plafond 3 000 F, détour 1,3, arrondi 25 F → 4 km à vol d'oiseau = 5,2 km → 500 + 780 = 1 280 F → arrondi supérieur **1 300 F** (montant payable en espèces).
- Étant donné une modification, quand une commande existe déjà, alors ses montants restent ceux figés à sa création.

---

## C. Livreurs — Inc-3

#### COU-01 · Créer mon profil livreur — Must · M · Inc-3
- Étant donné un compte connecté dans l'app Livreur, quand je renseigne prénom, nom, téléphone, zone, moyen de transport (moto, vélo, voiture, à pied), immatriculation (obligatoire si moto ou voiture) et photo de profil (prise ou galerie, compressée), alors je peux soumettre mon profil.
- La caméra n'est demandée que si je choisis « Prendre une photo ».

#### COU-02 · Soumettre mon profil à validation — Must · S · Inc-3
- Étant donné un profil complet, quand je le soumets, alors son statut passe à « En attente de validation » et l'admin le voit dans sa liste.
- Étant donné un profil refusé, quand je le corrige et le soumets à nouveau, alors il revient « En attente ».

#### COU-03 · Consulter le statut de mon compte — Must · S · Inc-3
- Étant donné mon profil, quand j'ouvre l'app, alors je vois son statut : En attente · Approuvé · Refusé (avec le motif) · Suspendu.
- Étant donné un statut autre qu'« Approuvé », quand je cherche à passer en ligne, alors c'est impossible et le motif est expliqué.

#### COU-04 · Valider ou refuser un livreur (admin) — Must · S · Inc-3
- Étant donné un profil en attente, quand je l'approuve, alors le livreur est notifié et peut passer en ligne.
- Étant donné un profil en attente, quand je le refuse, alors un motif est obligatoire et transmis au livreur.
- Étant donné un livreur approuvé, quand je le suspends (motif), alors il passe hors ligne, ne reçoit plus d'offre ; une mission en cours doit d'abord être réattribuée.

#### ADM-02 · Gérer les utilisateurs (admin) — Must · M · Inc-3
- Étant donné la liste des utilisateurs, quand je recherche par nom, email ou téléphone, alors je vois le compte, ses rôles et son statut.
- Étant donné un compte, quand je le suspends ou le réactive (motif), alors l'accès est bloqué ou rétabli immédiatement.
- Étant donné un utilisateur qui a perdu son identifiant, quand je modifie son email ou son numéro de connexion, alors l'action est tracée (auteur, date).

---

## D. Restaurants et catalogue — Inc-4

#### RES-01 · Créer un restaurant partenaire (admin) — Must · M · Inc-4
- Étant donné l'espace Admin, quand je crée un restaurant (nom, description, photo de couverture, position, quartier, repère, zone, téléphone, commission %) et indique l'email ou le numéro du gérant, alors le gérant obtient l'accès à l'espace Restaurant à sa connexion.
- Étant donné un restaurant, quand je le désactive, alors il disparaît des listes clients ; ses commandes en cours continuent.

#### RES-02 · Gérer le profil du restaurant — Must · S · Inc-4
- Étant donné l'espace Restaurant, quand je modifie description, photo, téléphone, horaires hebdomadaires ou temps de préparation moyen, alors les changements sont visibles des clients.
- La commission et la zone ne sont modifiables que par l'admin.

#### RES-03 · Ouvert / fermé — Must · S · Inc-4
- Étant donné les horaires, quand l'heure courante est hors horaires, alors le restaurant apparaît « Fermé · ouvre à 18:00 » et ne peut pas recevoir de commande.
- Étant donné l'interrupteur « Fermé temporairement », quand je l'active, alors le restaurant est fermé immédiatement, quels que soient les horaires.

#### RES-04 · Ajouter un produit — Must · S · Inc-4
- Étant donné le menu, quand j'ajoute un produit (nom, description, prix entier > 0, catégorie, photo, disponible), alors il apparaît dans le menu client.
- Étant donné une photo, quand je l'envoie, alors elle est réduite (≤ 800 px) avant l'envoi.

#### RES-05 · Modifier un produit et sa disponibilité — Must · S · Inc-4
- Étant donné un produit, quand je change son prix, alors le nouveau prix s'applique aux nouvelles commandes ; les commandes passées gardent leur prix.
- Étant donné un produit, quand je le marque indisponible, alors il apparaît grisé « Indisponible » chez le client et ne peut pas être ajouté au panier.
- Étant donné un produit déjà commandé, quand je le supprime, alors il est archivé (masqué) et l'historique reste intact.

---

## E. Commande de repas — Inc-5

#### ORD-01 · Accueil avec les deux services — Must · M · Inc-5
- Étant donné l'accueil, quand il s'affiche, alors je vois l'adresse de livraison active (modifiable), deux tuiles « Commander un repas » et « Envoyer un colis », et la carte de ma commande en cours s'il y en a une (statut, ETA).
- Étant donné une ouverture répétée, quand l'app démarre, alors l'accueil s'affiche immédiatement depuis le cache, puis se met à jour.

#### ORD-02 · Restaurants de ma zone — Must · M · Inc-5
- Étant donné mon adresse active, quand j'ouvre « Repas », alors je vois les restaurants actifs de sa zone : ouverts d'abord, fermés grisés avec l'heure d'ouverture ; chaque carte montre photo, nom, catégorie, frais de livraison estimés, temps estimé, distance.
- Étant donné aucun restaurant ouvert, quand la liste s'affiche, alors un état vide explique « Aucun restaurant ouvert près de vous pour le moment ».
- La liste est paginée et les images sont des vignettes légères.

#### ORD-03 · Rechercher un restaurant — Should · S · Inc-5
- Étant donné la liste, quand je tape un nom, alors la liste se filtre (insensible aux accents).

#### ORD-04 · Détail d'un restaurant et son menu — Must · M · Inc-5
- Étant donné un restaurant, quand je l'ouvre, alors je vois sa photo, sa description, son quartier, ses horaires, son statut, les frais et le temps estimés, puis le menu groupé par catégorie avec photo, nom, description et prix de chaque produit.
- Étant donné un produit indisponible, quand le menu s'affiche, alors il est grisé et non ajoutable.

#### ORD-05 · Ajouter au panier (un seul restaurant) — Must · S · Inc-5
- Étant donné un restaurant ouvert, quand je touche « + » sur un produit, alors il est ajouté instantanément (retour haptique) et la barre basse « Voir le panier · total » apparaît.
- Étant donné un panier d'un autre restaurant, quand j'ajoute un produit, alors une feuille propose « Vider le panier et commencer chez ce restaurant ? ».
- Étant donné une fermeture puis réouverture de l'app, quand je reviens, alors mon panier est conservé.

#### ORD-06 · Gérer le panier — Must · S · Inc-5
- Étant donné le panier, quand je change une quantité ou supprime un produit, alors sous-total, frais de livraison et total sont recalculés.
- Les frais viennent du **devis serveur** pour l'adresse active ; sans réseau, ils sont marqués « à confirmer » et la validation est désactivée.

#### ORD-07 · Valider la commande — Must · L · Inc-5 (paiements complétés en Inc-10 à 13)
- Étant donné le panier, quand j'ouvre la validation, alors je vois restaurant, produits, quantités, sous-total, frais, total, adresse de livraison (modifiable) et moyen de paiement (modifiable).
- Étant donné que je confirme, quand le serveur revérifie (restaurant ouvert, produits disponibles, prix, zone, livreurs en ligne), alors la commande est créée avec un numéro unique et des montants identiques à ceux affichés.
- Étant donné un écart (prix changé, produit devenu indisponible, restaurant fermé), quand je confirme, alors la commande n'est pas créée et l'écart précis est affiché avec l'action « Mettre à jour le panier ».
- Étant donné aucun livreur en ligne dans la zone, quand je confirme, alors « Aucun livreur disponible pour le moment. Réessayez dans quelques minutes. » s'affiche et rien n'est créé ni payé.
- Étant donné un double toucher ou une coupure réseau pendant la confirmation, quand je réessaie, alors une seule commande existe.
- Espèces : la commande est transmise au restaurant immédiatement. Mobile Money / carte : elle n'est transmise qu'après confirmation du paiement (PAY-03, PAY-04).

#### ORD-08 · Recevoir une nouvelle commande (restaurant) — Must · M · Inc-5
- Étant donné l'espace Restaurant ouvert, quand une commande arrive, alors elle apparaît en temps réel dans « Nouvelles » avec une alerte sonore répétée jusqu'à consultation, et un compte à rebours de réponse (10 min).
- Étant donné l'app en arrière-plan (Android), quand une commande arrive, alors une notification push est reçue (Inc-9).
- Étant donné le compte à rebours écoulé, quand personne n'a répondu, alors la commande est refusée automatiquement (« sans réponse du restaurant ») et le client est notifié et remboursé si nécessaire.

#### ORD-09 · Accepter ou refuser (restaurant) — Must · S · Inc-5
- Étant donné une nouvelle commande, quand je l'ouvre, alors je vois numéro, produits, quantités, sous-total et mode de paiement.
- Étant donné qu'elle est consultée, quand je l'accepte, alors le client est notifié « Commande acceptée ».
- Étant donné qu'elle est consultée, quand je la refuse, alors un motif est obligatoire (produit indisponible, fermeture, trop de commandes, autre) et le client est notifié.

#### ORD-10 · Préparer, prête, remise (restaurant) — Must · S · Inc-5 (remise en Inc-8)
- Étant donné une commande acceptée, quand je touche « En préparation », alors la recherche de livreur démarre (Inc-7).
- Étant donné une commande en préparation, quand je touche « Prête », alors le livreur assigné est notifié.
- Étant donné le livreur arrivé, quand je touche « Remise au livreur », alors la commande passe « Récupérée » (même effet que la confirmation par le livreur, MIS-04).

#### ORD-11 · Annuler ma commande de repas (client) — Must · S · Inc-5
- Étant donné une commande « En attente de confirmation », quand je l'annule (feuille de confirmation), alors elle passe « Annulée » et le restaurant est notifié ; un paiement déjà encaissé est remboursé (TRX-03).
- Étant donné une commande acceptée, quand je cherche à l'annuler, alors « Le restaurant prépare déjà votre commande. Contactez le support. » s'affiche avec le bouton d'appel.

#### ORD-12 · Historique et détail des commandes (client) — Must · M · Inc-5
- Étant donné mes commandes (repas et colis), quand j'ouvre « Commandes », alors je vois les commandes en cours en haut puis l'historique paginé (date, type, restaurant ou trajet, total, statut).
- Étant donné une commande, quand je l'ouvre, alors je vois le détail : produits ou colis, montants séparés, adresse(s), moyen et statut de paiement, chronologie des statuts.

#### ORD-13 · Historique des commandes (restaurant) — Must · S · Inc-5
- Étant donné l'espace Restaurant, quand j'ouvre l'historique, alors je vois les commandes par jour (statut, montant) et le total du jour (ventes, commission, net).

---

## F. Livraison de colis — Inc-6

#### PAR-01 · Demander une livraison de colis — Must · L · Inc-6
- Étant donné « Envoyer un colis », quand je suis les étapes, alors je renseigne : (1) départ — une adresse enregistrée ou un point sur la carte + repère ; (2) arrivée — point sur la carte + repère + instructions ; (3) destinataire (nom, téléphone avec indicatif), type de colis, description, instructions ; (4) récapitulatif.
- Étant donné l'étape 3, quand je continue, alors je dois cocher « Mon colis respecte la liste des objets autorisés » (liste consultable).
- Étant donné les types proposés (ex. Documents · Petit colis ≤ 5 kg · Colis moyen ≤ 15 kg), quand je choisis, alors seuls les types transportables par les moyens disponibles sont proposés.
- Étant donné les deux points, quand ils ne sont pas dans la même zone, alors « Les livraisons entre villes ne sont pas disponibles » s'affiche.

#### PAR-02 · Estimer les frais — Must · S · Inc-6
- Étant donné les deux positions, quand j'arrive au récapitulatif, alors je vois la distance de référence, les frais calculés par le serveur selon les règles de la zone (service colis) et le total à payer.
- Étant donné le récapitulatif, quand je confirme, alors le montant facturé est exactement celui affiché.

#### PAR-03 · Confirmer la demande — Must · M · Inc-6
- Étant donné le récapitulatif et des livreurs en ligne, quand je confirme, alors la demande est enregistrée avec un identifiant unique court (ex. « C-7K2P9 »), statut « Demande confirmée » puis « Recherche de livreur » (après paiement si Mobile Money / carte).
- Étant donné le paiement en espèces, quand je confirme, alors il est indiqué que je paierai le livreur **à la récupération**.
- Étant donné aucun livreur en ligne, quand je confirme, alors rien n'est créé (même message qu'ORD-07).

#### PAR-04 · Transmettre le code au destinataire — Must · S · Inc-6
- Étant donné une demande confirmée, quand j'ouvre son suivi, alors je vois le code de livraison à 4 chiffres et un bouton « Partager au destinataire » (WhatsApp, SMS… depuis mon téléphone) avec un message prêt : trajet, identifiant, code.

#### PAR-05 · Annuler une demande de colis — Must · S · Inc-6
- Étant donné une demande non encore récupérée, quand je l'annule (feuille de confirmation), alors elle passe « Annulée », l'offre ou la mission du livreur est retirée et il est notifié ; un paiement encaissé est remboursé.
- Étant donné un colis déjà récupéré, quand je cherche à annuler, alors c'est impossible et « Contacter le support » est proposé.

---

## G. Attribution des livreurs — Inc-7

#### COU-05 · Passer en ligne / hors ligne — Must · M · Inc-7
- Étant donné un livreur approuvé, quand il passe « En ligne », alors l'autorisation de localisation est demandée (explication préalable), une notification permanente « Vous êtes en ligne » s'affiche et il devient éligible aux offres.
- Étant donné un livreur en ligne, quand il passe « Hors ligne », alors sa position n'est plus envoyée ; c'est refusé pendant une mission.
- Étant donné un livreur en ligne sans position reçue depuis 2 min (réseau coupé), quand une attribution a lieu, alors il n'est pas sollicité.

#### DIS-01 · Rechercher un livreur automatiquement — Must · L · Inc-7
- Étant donné une commande de repas passée « En préparation » ou une demande de colis confirmée (et payée si nécessaire), quand la recherche démarre, alors le livreur éligible le plus proche du point de retrait (approuvé, en ligne, position < 2 min, dans la zone, sans mission ni offre en cours) reçoit une offre valable 45 s.
- Étant donné deux commandes simultanées, quand elles visent le même livreur, alors il ne reçoit qu'une seule offre à la fois.

#### DIS-02 · Recevoir une proposition de mission (livreur) — Must · M · Inc-7
- Étant donné une offre, quand elle arrive, alors une notification sonore et un écran plein s'affichent : type, gain pour la mission, distance jusqu'au retrait, distance totale, quartiers et repères de départ et d'arrivée, montant à encaisser si espèces, compte à rebours.
- Étant donné l'offre, quand je l'accepte avant la fin du compte à rebours, alors la mission m'est attribuée et le client est notifié « Livreur assigné ».
- Étant donné l'offre, quand je la refuse ou la laisse expirer, alors elle passe au livreur suivant et ne m'est plus reproposée.
- Étant donné un livreur non approuvé ou déjà en mission, quand il tente d'accepter, alors le serveur refuse.

#### DIS-03 · Aucun livreur disponible — Must · M · Inc-7
- Étant donné une recherche sans succès pendant 10 min, quand le délai est atteint, alors le client est informé « Nous cherchons encore un livreur » avec deux choix : « Continuer d'attendre » ou « Annuler » (remboursé), et l'admin reçoit une alerte.
- Étant donné une recherche sans succès pendant 30 min, quand le délai est atteint, alors la commande est annulée automatiquement, le restaurant et le client sont notifiés, et le paiement éventuel est remboursé.
- Les délais sont des paramètres admin (ADM-05).

#### DIS-04 · Attribuer ou réattribuer manuellement (admin) — Must · M · Inc-7
- Étant donné une commande sans livreur ou avec un livreur à remplacer, quand je choisis un livreur dans la liste des livreurs en ligne (triés par distance, avec leur statut), alors il est attribué, notifié, et l'ancien livreur éventuel est notifié du retrait ; un motif est enregistré.
- Étant donné un livreur déjà en mission, quand je tente de lui attribuer une autre commande, alors c'est refusé.

#### ADM-03 · Superviser les commandes (admin) — Must · L · Inc-7
- Étant donné le tableau de supervision, quand il s'affiche, alors je vois en temps réel les commandes en cours filtrables par statut, type et zone, avec un bandeau d'alertes : sans livreur, restaurant sans réponse, code de livraison bloqué, échec signalé, paiement à rembourser.
- Étant donné une commande, quand je l'ouvre, alors je vois son détail, sa chronologie complète (acteur, date, motif) et les actions possibles selon son état : attribuer, annuler (motif), confirmer la livraison sans code (motif).

---

## H. Mission du livreur — Inc-8

#### MIS-01 · Tableau de bord livreur — Must · S · Inc-8
- Étant donné l'app Livreur, quand je l'ouvre, alors je vois l'interrupteur En ligne / Hors ligne, ma mission en cours (si présente), mes gains du jour et le montant d'espèces à reverser.

#### MIS-02 · Détail de la mission — Must · M · Inc-8
- Étant donné une mission acceptée, quand je l'ouvre, alors je vois : point de retrait (nom du restaurant ou de l'expéditeur, quartier, repère, instructions), destination (quartier, repère, instructions), contenu (produits ou type de colis), montant à encaisser si espèces, et les boutons « Appeler » (restaurant, client, destinataire).
- Les numéros ne sont visibles que pendant la mission.

#### MIS-03 · Itinéraire — Must · S · Inc-8
- Étant donné la mission, quand j'ouvre la carte, alors je vois ma position et la prochaine étape ; « Ouvrir l'itinéraire » lance Google Maps ou Waze vers ce point.

#### MIS-04 · Confirmer la récupération — Must · S · Inc-8
- Étant donné une commande de repas « Prête » (ou remise confirmée par le restaurant), quand je touche « Commande récupérée », alors elle passe « Récupérée » et le client est notifié.
- Étant donné un colis payé en espèces, quand je confirme la récupération, alors je dois d'abord confirmer « J'ai reçu 1 300 F de l'expéditeur ».
- Étant donné une commande non prête, quand je touche « Récupérée », alors « Le restaurant n'a pas encore indiqué que la commande est prête » s'affiche.

#### MIS-05 · Démarrer la livraison — Must · S · Inc-8
- Étant donné une commande récupérée, quand je touche « Je pars livrer », alors elle passe « En cours de livraison » et le client est notifié « Votre livreur est en route ».

#### MIS-06 · Confirmer la livraison par code — Must · M · Inc-8
- Étant donné l'arrivée chez le destinataire, quand je saisis le code à 4 chiffres qu'il me donne, alors la livraison est confirmée si le code est juste, avec la date et l'heure enregistrées.
- Étant donné un code faux, quand je valide, alors le nombre d'essais restants s'affiche ; après 5 erreurs, la saisie est bloquée et l'admin est alerté.
- Étant donné un repas payé en espèces, quand la livraison est confirmée, alors l'écran « Encaisser 7 500 F » s'affiche et je confirme « J'ai reçu 7 500 F » (PAY-02).
- Le code n'est jamais visible dans l'app Livreur.

#### MIS-07 · Confirmation sans code (admin) — Must · S · Inc-8
- Étant donné un destinataire qui ne peut pas communiquer son code ou un code bloqué, quand l'admin confirme la livraison après vérification (appel), alors un motif est obligatoire et l'action est tracée.

#### MIS-08 · Signaler un problème, déclarer un échec — Must · M · Inc-8
- Étant donné une mission, quand je touche « Un problème ? », alors je choisis : client injoignable, adresse introuvable, destinataire absent, autre ; et je peux appeler le client ou le support.
- Étant donné une commande récupérée, quand je déclare l'échec (motif obligatoire), alors elle passe « Échec de livraison », le client et l'admin sont notifiés, et l'admin décide de la suite (remboursement).

#### MIS-09 · Abandonner une mission avant récupération — Must · S · Inc-8
- Étant donné une mission non récupérée, quand je l'abandonne (motif), alors elle repart en recherche, le client est informé « Votre livreur a dû annuler, nous en cherchons un autre » et l'abandon est visible par l'admin.

#### MIS-10 · Historique des livraisons — Must · S · Inc-8
- Étant donné l'historique, quand je l'ouvre, alors je vois mes missions (date, type, trajet, gain, statut) et le total des gains par jour et par semaine.

---

## I. Suivi en temps réel et notifications — Inc-9

#### TRK-01 · Suivre ma commande — Must · L · Inc-9
- Étant donné une commande en cours, quand j'ouvre le suivi, alors je vois le statut actuel, la frise des étapes, le livreur assigné (prénom, photo, moyen de transport, immatriculation, bouton d'appel), sa position sur la carte, l'estimation d'arrivée (« environ 12 min ») et le code de livraison.
- Étant donné un changement de statut ou de position, quand il se produit, alors l'écran se met à jour sans action de ma part.

#### TRK-02 · Ne jamais afficher une ancienne position comme actuelle — Must · M · Inc-9
- Étant donné une position datant de plus de 60 s, quand elle s'affiche, alors le marqueur est grisé avec « Position il y a 3 min » et l'estimation est marquée « indisponible ».
- Étant donné une perte de connexion, quand elle survient, alors le bandeau « Connexion perdue — reconnexion… » s'affiche ; au retour, l'écran se resynchronise.

#### TRK-03 · Chronologie des statuts — Must · S · Inc-9
- Étant donné une commande, quand un statut change, alors l'étape est horodatée et visible du client, du restaurant concerné, du livreur assigné et de l'admin, chacun selon ses droits.

#### NOT-01 · Notifications du client — Must · M · Inc-9
- Étant donné l'autorisation accordée, quand survient : paiement confirmé ou refusé, commande acceptée, refusée, livreur assigné, commande récupérée, livreur en route, livraison terminée, commande annulée, échec — alors je reçois une notification qui ouvre le suivi de la commande.

#### NOT-02 · Notifications du livreur — Must · S · Inc-9
- Étant donné un livreur en ligne, quand une mission lui est proposée ou attribuée par l'admin, ou qu'une mission est annulée, alors il reçoit une notification prioritaire et sonore.

#### NOT-03 · Notifications du restaurant — Must · S · Inc-9
- Étant donné l'app Back-office Android, quand une commande arrive ou est annulée, alors une notification sonore est reçue ; dans le navigateur, l'alerte sonore fonctionne tant que la page est ouverte.

#### NOT-04 · Autorisation des notifications — Must · S · Inc-9
- Étant donné le premier moment utile (après la première commande, ou au passage en ligne du livreur), quand l'app demande l'autorisation, alors une explication la précède ; en cas de refus, un rappel discret est affiché dans le suivi.

---

## J. Paiements et transactions — Inc-10 à Inc-13

#### PAY-01 · Choisir le moyen de paiement — Must · S · Inc-10
- Étant donné la validation d'une commande, quand j'ouvre le choix, alors je vois uniquement les moyens réellement disponibles dans le pays : Espèces, Mobile Money (opérateurs intégrés seulement), Carte bancaire (si Stripe est actif).
- Étant donné un moyen choisi, quand je reviens, alors il est mémorisé pour la commande suivante.

#### PAY-02 · Payer en espèces — Must · M · Inc-10
- Étant donné une commande en espèces, quand elle est créée, alors son paiement est « En attente » et le livreur voit le montant exact à encaisser.
- Étant donné la remise de l'argent, quand le livreur confirme le montant reçu, alors la transaction passe « Réussie », la commande « Payée », et le montant s'ajoute aux espèces dues par le livreur.
- Étant donné une livraison confirmée sans confirmation d'encaissement, quand l'admin consulte, alors la commande apparaît « Livrée · non encaissée ».
- Étant donné une commande annulée avant encaissement, quand elle est annulée, alors la transaction passe « Annulée ».

#### PAY-03 · Payer par Mobile Money — Must · L · Inc-11
- Étant donné Mobile Money, quand je choisis un opérateur et saisis mon numéro (prérempli), alors le paiement est initié et l'écran « Validez le paiement sur votre téléphone » s'affiche avec les instructions de l'opérateur et le statut en direct.
- Étant donné la validation chez l'opérateur, quand le fournisseur confirme au serveur (webhook signé, puis vérification auprès du fournisseur), alors seulement la transaction passe « Réussie » et la commande est transmise.
- Étant donné un refus ou une erreur, quand le fournisseur l'indique, alors « Le paiement n'a pas été validé par Orange Money » s'affiche avec « Réessayer » et « Changer de moyen de paiement ».
- Étant donné que je quitte l'écran ou ferme l'app, quand je reviens, alors le statut réel est affiché ; quitter l'écran ne valide jamais un paiement.
- Étant donné aucune confirmation sous 15 min, quand le délai expire, alors la commande est annulée et rien n'est transmis.

#### PAY-04 · Payer par carte (Stripe) — Must · M · Inc-12
- Étant donné Carte bancaire, quand je confirme, alors le montant s'affiche dans la feuille de paiement sécurisée Stripe (3-D Secure si demandé par la banque).
- Étant donné l'accord de la banque, quand Stripe confirme au serveur (webhook signé), alors la transaction passe « Réussie » et j'obtiens la confirmation.
- Étant donné un refus, quand Stripe l'indique, alors le motif compréhensible est affiché avec « Réessayer » ou « Changer de moyen ».

#### PAY-05 · Jamais deux paiements pour une même commande — Must · M · Inc-11
- Étant donné un double toucher, une reprise réseau ou un webhook reçu deux fois, quand le serveur traite, alors au plus une transaction réussie existe pour la commande.

#### TRX-01 · Enregistrer chaque transaction — Must · M · Inc-10
- Chaque transaction contient : identifiant unique, référence de la commande, montant, devise, moyen de paiement (et opérateur), date, statut (En attente, Réussie, Échouée, Annulée, Remboursée), référence du fournisseur si applicable.
- Le montant d'une transaction est toujours égal au total de la commande.

#### TRX-02 · Historique, détail et reçu (client) — Must · M · Inc-13
- Étant donné « Paiements », quand je l'ouvre, alors je vois mes transactions groupées par date (Aujourd'hui, Hier, …) avec commande, moyen, montant et statut.
- Étant donné une transaction, quand je l'ouvre, alors je vois son détail et un **reçu simple** (numéro, date, détail des montants, moyen, statut) que je peux partager.

#### TRX-03 · Annulation et remboursement — Must · M · Inc-13
- Étant donné une commande payée par carte puis annulée, refusée ou expirée en recherche, quand l'annulation est enregistrée, alors le remboursement Stripe est lancé automatiquement et la transaction passe « Remboursée » à sa confirmation.
- Étant donné une commande payée par Mobile Money puis annulée, quand le fournisseur permet le remboursement par API, alors il est automatique ; sinon la transaction est marquée « Remboursement à effectuer », traitée par l'admin, puis « Remboursée ».
- Étant donné une commande en espèces annulée avant encaissement, quand elle est annulée, alors aucun remboursement n'est nécessaire.
- Le client voit à chaque étape le statut de son remboursement.

#### PAY-06 · Montants séparés par commande — Must · S · Inc-10
- Chaque commande enregistre séparément : sous-total, frais de livraison, total, commission du restaurant, rémunération du livreur, part de la plateforme. Le client voit sous-total, frais et total ; l'admin voit tout.

#### ADM-04 · Transactions et rapprochement des espèces (admin) — Must · M · Inc-13 (espèces dès Inc-10)
- Étant donné la liste des transactions, quand je filtre (statut, moyen, date, zone), alors je vois chaque transaction et son détail.
- Étant donné un remboursement à effectuer, quand je l'ai réalisé hors application, alors je le marque « Remboursée » avec la référence.
- Étant donné un livreur, quand il me remet ses espèces, alors j'enregistre le versement et son solde dû diminue ; l'historique des encaissements et versements est consultable.

#### ADM-05 · Paramètres de la plateforme (admin) — Must · S · Inc-7
- Étant donné les paramètres, quand je modifie : délai d'une offre (45 s), délai de réponse restaurant (10 min), expiration du paiement (15 min), alerte et annulation de recherche (10 / 30 min), numéro du support, moyens de paiement actifs par pays, alors les nouvelles valeurs s'appliquent aux nouvelles commandes.

#### ADM-06 · Statistiques essentielles (admin) — Must · S · Inc-13
- Étant donné le tableau de bord, quand je choisis une période (jour, semaine, mois), alors je vois : nombre de commandes par statut et par type, chiffre d'affaires, frais de livraison, commissions, rémunération des livreurs, espèces à rapprocher, livreurs en ligne maintenant.

---

## K. Exigences transversales — tous les incréments

#### TRV-01 · Connexion intermittente — Must · M
- Étant donné une coupure réseau, quand je navigue, alors les données déjà chargées restent affichées, les actions qui exigent le serveur sont désactivées avec un bandeau explicite, et elles reprennent au retour du réseau sans double envoi.

#### TRV-02 · Rapidité et fluidité — Must · M
- Les budgets de `docs/design/direction.md` §5 sont mesurés en phase 5 sur un Android d'entrée de gamme : démarrage < 3 s, 60 i/s sur les parcours critiques, retour visuel < 100 ms, APK < 25 Mo par architecture.

#### TRV-03 · Design moderne et accessible — Must · M
- Chaque écran suit le design system (jetons, composants), possède ses états chargement (squelette) / vide / erreur avec « Réessayer » / succès, respecte des zones tactiles ≥ 48 dp, les contrastes AA, la taille de police du téléphone, le mode sombre et la réduction des animations.

#### TRV-04 · Adaptation locale — Must · S
- Numéros au format international avec indicatif ; montants dans la devise de la zone (« 7 500 F CFA ») ; dates et heures en français ; tous les textes en français, centralisés pour une traduction future.

#### TRV-05 · Messages d'erreur compréhensibles — Must · S
- Chaque situation de l'INTAKE §7.B produit le message et l'action définis dans le plan §3.4 ; aucune erreur technique brute n'est montrée à l'utilisateur.

#### TRV-06 · Sécurité des données — Must · M
- Chaque acteur n'accède qu'à ses données (RLS testée) ; aucune transition de statut ni montant n'est décidé par l'app ; les jetons sont dans le stockage sécurisé ; aucune clé secrète dans les apps.

#### TRV-07 · API réutilisable par l'app web — Must · S
- Toute action métier livrée est une action d'API documentée (`docs/api/`) avec ses entrées, sorties et erreurs, et couverte par un test.

---

## Won't (hors MVP, INTAKE §9)

Médicaments · express · fidélité · parrainage · premium · publicités · portefeuille interne · messagerie avancée · IA ·
international · inter-villes · commandes groupées · multi-destinations · promotions · analytique avancée · stocks avancés ·
réservation · **notes et avis** (non demandés).

---

## Matrice de couverture INTAKE → stories

| Exigence INTAKE | Stories |
|-----------------|---------|
| §2.1 Inscription et connexion | AUTH-01 à AUTH-09 |
| §2.2 Adresses | ADR-01 à ADR-05 |
| §2.3 Profils livreurs | COU-01 à COU-05 |
| §3 Écran d'accueil 2 services | ORD-01 |
| §3.1 Consultation des restaurants | ORD-02, ORD-03, ORD-04, RES-03 |
| §3.1 Panier | ORD-05, ORD-06 |
| §3.1 Validation de commande | ORD-07, PAY-01 |
| §3.1 Gestion des commandes par le restaurant | ORD-08, ORD-09, ORD-10, ORD-13 |
| §3.1 Catalogue du restaurant | RES-02, RES-04, RES-05 |
| §3.2 Livraison de colis | PAR-01 à PAR-05 |
| §4.1 Attribution | DIS-01 à DIS-04, ADM-05 |
| §4.2 Interface livreur | DIS-02, MIS-01 à MIS-05, MIS-08, MIS-09 |
| §4.3 Suivi temps réel | TRK-01, TRK-02 |
| §4.4 Statuts | TRK-03, ORD-10, MIS-04, MIS-05, MIS-06 |
| §4.5 Confirmation de livraison | MIS-06, MIS-07, PAR-04 |
| §4.6 Notifications | NOT-01 à NOT-04 |
| §5.1 Mobile Money | PAY-03, PAY-05 |
| §5.2 Carte bancaire | PAY-04 |
| §5.3 Espèces | PAY-02, ADM-04 |
| §5.4 Transactions | TRX-01, PAY-05 |
| §5.5 Historique et reçus | ORD-12, TRX-02 |
| §5.6 Frais et commissions | ADR-07, RES-01, PAY-06, ADM-04 |
| §6.D Dashboard admin | ADR-06, ADR-07, COU-04, ADM-02 à ADM-06, RES-01, DIS-04, MIS-07 |
| §7.A Marché africain | TRV-01, TRV-02, TRV-04, ADR-02 |
| §7.B Erreurs | TRV-05, ORD-07, PAY-03, DIS-03, MIS-08, MIS-09 |
| §7.C Cohérence | TRV-06, ORD-07, PAY-05, DIS-02, MIS-04, MIS-06 |
| §8 Design et UX | TRV-02, TRV-03 |
| §10 Scénarios S1 à S6 | S1 : ORD-01…ORD-10, DIS-01, DIS-02, MIS-04…MIS-06, TRK-01, PAY-03 · S2 : PAR-01…PAR-04, DIS-02, MIS-04…MIS-06 · S3 : PAY-03 · S4 : PAY-02 · S5 : ORD-07, PAR-03, DIS-03 · S6 : ORD-11, PAR-05, TRX-03 |
| D-2 API web | TRV-07 |
| Stores (ADR-008) | AUTH-08 |
