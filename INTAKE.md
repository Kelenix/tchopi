# PROMPT — DÉVELOPPEMENT D'UNE APPLICATION MOBILE DE LIVRAISON (MVP)

## 1. CONTEXTE DU PROJET

Tu es un expert en conception de produits numériques, en analyse fonctionnelle, en expérience utilisateur et en développement d'applications mobiles.

Ta mission est de concevoir et développer le MVP d'une application mobile de livraison destinée principalement au marché africain.

L'application s'inspire du fonctionnement de Glovo et Bolt Food, mais ne doit pas reproduire toutes leurs fonctionnalités.

L'objectif est de construire une première version simple, moderne, intuitive et entièrement fonctionnelle, permettant de tester rapidement le produit auprès de véritables utilisateurs.

**Le MVP doit être construit autour de quatre fonctionnalités principales uniquement :**

1. Gestion des comptes et des adresses.
2. Commande de repas et livraison de colis.
3. Gestion et suivi des livraisons en temps réel.
4. Paiements et gestion des transactions.

Chaque fonctionnalité doit être développée de bout en bout, avec toutes les opérations nécessaires à son bon fonctionnement.

Ne développe aucune fonctionnalité supplémentaire qui ne contribue pas directement à ces quatre modules.

---

# 2. FONCTIONNALITÉ 1 — GESTION DES COMPTES ET DES ADRESSES

## Objectif

Permettre aux utilisateurs de créer un compte, de se connecter et de renseigner facilement leurs informations de livraison.

L'application doit prendre en charge trois catégories d'utilisateurs :

- **Client :** personne qui commande un repas ou demande une livraison.
- **Livreur :** personne chargée de récupérer et livrer les commandes.
- **Administrateur :** personne responsable de la supervision de la plateforme.

Les restaurants doivent également disposer d'un espace simplifié pour recevoir et gérer leurs commandes.

## 2.1. Inscription et connexion

L'utilisateur doit pouvoir :

- Créer un compte avec son numéro de téléphone.
- Confirmer son numéro avec un code OTP.
- Se connecter à son compte.
- Se déconnecter.
- Modifier ses informations personnelles.
- Récupérer l'accès à son compte.

Informations nécessaires :

- Nom et prénom.
- Numéro de téléphone.
- Mot de passe si ce mode d'authentification est retenu.
- Ville.
- Adresse principale.

L'authentification doit être simple et adaptée aux utilisateurs africains.

## 2.2. Gestion des adresses

Le client doit pouvoir :

- Autoriser l'application à accéder à sa position GPS.
- Sélectionner manuellement une position sur une carte.
- Enregistrer une adresse.
- Modifier ou supprimer une adresse.
- Choisir une adresse par défaut.

Chaque adresse doit pouvoir contenir :

- Ville.
- Quartier.
- Position GPS.
- Point de repère.
- Instructions supplémentaires.

**Exemple :**

Ville : Abidjan  
Quartier : Cocody  
Point de repère : Derrière la pharmacie centrale  
Instructions : Maison avec portail bleu.

Le client ne doit pas être obligé de connaître le nom exact de sa rue pour commander.

## 2.3. Gestion des profils livreurs

Un livreur doit pouvoir :

- Créer son compte.
- Renseigner ses informations personnelles.
- Indiquer son moyen de transport.
- Soumettre son profil à validation.
- Consulter le statut de validation de son compte.
- Activer ou désactiver sa disponibilité.

Seuls les livreurs approuvés par l'administrateur peuvent recevoir des livraisons.

---

# 3. FONCTIONNALITÉ 2 — COMMANDE DE REPAS ET LIVRAISON DE COLIS

## Objectif

Permettre aux clients d'effectuer deux types de demandes depuis une seule application :

1. Commander des repas auprès de restaurants partenaires.
2. Envoyer des colis d'un point à un autre.

L'écran d'accueil doit présenter clairement ces deux services.

## 3.1. Commande de repas

### Consultation des restaurants

Le client doit pouvoir :

- Voir les restaurants disponibles dans sa zone.
- Consulter les informations d'un restaurant.
- Visualiser les menus.
- Consulter les prix.
- Voir les photos des produits.
- Identifier les restaurants ouverts ou fermés.

Les restaurants affichés doivent correspondre à la zone de livraison du client.

### Gestion du panier

Le client doit pouvoir :

- Ajouter un produit au panier.
- Modifier les quantités.
- Supprimer un produit.
- Consulter le montant total.
- Voir les frais de livraison.
- Confirmer sa commande.

Pour le MVP, un panier doit contenir uniquement les produits d'un seul restaurant.

### Validation de la commande

Avant de confirmer, le client doit visualiser :

- Le restaurant sélectionné.
- Les produits commandés.
- Les quantités.
- Le sous-total.
- Les frais de livraison.
- Le montant total.
- L'adresse de livraison.
- Le moyen de paiement.

Après confirmation, la commande doit être transmise au restaurant.

### Gestion des commandes par le restaurant

Le restaurant doit disposer d'une interface simple permettant de :

- Recevoir une nouvelle commande.
- Consulter les produits commandés.
- Accepter ou refuser la commande.
- Indiquer que la préparation est en cours.
- Signaler que la commande est prête.
- Confirmer la remise au livreur.

L'interface doit également permettre au restaurant de gérer son catalogue :

- Ajouter un produit.
- Modifier un produit.
- Définir son prix.
- Ajouter une photo.
- Activer ou désactiver sa disponibilité.

## 3.2. Livraison de colis

Le client doit pouvoir demander une livraison sans passer par un restaurant.

### Création d'une demande

Le formulaire doit contenir :

- Adresse de récupération.
- Adresse de destination.
- Nom du destinataire.
- Numéro de téléphone du destinataire.
- Type de colis.
- Description du colis.
- Instructions particulières.

Le client doit pouvoir positionner les deux adresses sur une carte.

### Estimation des frais

Avant de confirmer, le système doit :

1. Identifier les positions de départ et d'arrivée.
2. Calculer une distance de référence.
3. Appliquer les règles tarifaires de la zone.
4. Afficher les frais estimés.
5. Présenter le montant total à payer.

Le montant doit être confirmé avant la validation de la demande.

### Confirmation

Après validation :

- La demande est enregistrée.
- Un identifiant unique est généré.
- Le système recherche un livreur disponible.
- Le client peut suivre l'évolution de sa demande.

Pour le MVP, les livraisons de colis doivent être limitées à des objets autorisés, transportables par les moyens de livraison disponibles.

---

# 4. FONCTIONNALITÉ 3 — GESTION ET SUIVI DES LIVRAISONS EN TEMPS RÉEL

## Objectif

Assurer le fonctionnement complet du processus de livraison, depuis l'attribution d'un livreur jusqu'à la confirmation de réception.

Cette fonctionnalité constitue le cœur opérationnel de l'application.

## 4.1. Attribution des livreurs

Lorsqu'une commande est prête à être prise en charge, le système doit :

1. Rechercher les livreurs disponibles dans la zone.
2. Identifier un livreur approprié.
3. Lui transmettre une proposition de livraison.
4. Attendre son acceptation.
5. Lui attribuer la livraison après confirmation.

Pour une commande de restaurant, l'attribution intervient lorsque la commande est acceptée et que sa préparation permet d'organiser la récupération.

Pour un colis, la recherche commence après validation de la demande et du paiement requis.

Si le livreur refuse ou ne répond pas, la livraison doit pouvoir être proposée à un autre livreur.

Si aucun livreur n'est disponible, le client doit recevoir une information claire.

L'administrateur doit pouvoir attribuer ou réattribuer manuellement une livraison.

## 4.2. Interface du livreur

Le livreur doit pouvoir :

- Consulter les nouvelles propositions.
- Accepter ou refuser une livraison.
- Voir l'adresse de récupération.
- Voir l'adresse de destination.
- Consulter les instructions.
- Contacter le client.
- Ouvrir l'itinéraire de navigation.
- Confirmer la récupération.
- Confirmer la livraison.

Le livreur ne doit pas recevoir simultanément plusieurs missions incompatibles.

## 4.3. Suivi en temps réel

Le client doit pouvoir consulter :

- Le statut de sa commande.
- Le livreur assigné.
- La position du livreur sur une carte.
- Une estimation du temps d'arrivée.
- Les changements d'état de la livraison.

La position GPS doit être actualisée automatiquement pendant une livraison active, sous réserve des autorisations nécessaires.

Le système doit gérer les interruptions temporaires de connexion sans afficher une ancienne position comme si elle était actuelle.

## 4.4. Statuts des commandes

Pour une commande de repas :

1. En attente de confirmation.
2. Acceptée par le restaurant.
3. En préparation.
4. Prête pour récupération.
5. Livreur assigné.
6. Récupérée.
7. En cours de livraison.
8. Livrée.

Pour une livraison de colis :

1. Demande confirmée.
2. Recherche de livreur.
3. Livreur assigné.
4. Colis récupéré.
5. En cours de livraison.
6. Colis livré.

Les deux services doivent également gérer les états exceptionnels :

- Annulée.
- Refusée.
- Échec de livraison.

Chaque changement de statut doit être enregistré et visible par les utilisateurs concernés.

## 4.5. Confirmation de livraison

À l'arrivée, le livreur doit demander au destinataire un code de confirmation.

Le système doit :

- Générer un code OTP associé à la livraison.
- Permettre au destinataire de recevoir ou consulter ce code.
- Vérifier le code saisi par le livreur.
- Confirmer la livraison uniquement après validation.
- Enregistrer la date et l'heure de livraison.

Une procédure administrateur doit permettre de traiter les situations où le destinataire ne peut pas communiquer son code.

## 4.6. Notifications

Le client doit recevoir des notifications lors des événements importants :

- Commande acceptée.
- Livreur assigné.
- Commande récupérée.
- Livreur en route.
- Livraison terminée.
- Commande annulée.

Le livreur doit recevoir une notification lorsqu'une nouvelle mission lui est proposée.

Le restaurant doit être informé de l'arrivée d'une nouvelle commande.

---

# 5. FONCTIONNALITÉ 4 — PAIEMENTS ET GESTION DES TRANSACTIONS

## Objectif

Permettre aux clients de payer leurs commandes facilement, en tenant compte des moyens de paiement utilisés sur les marchés africains.

Le MVP doit prévoir trois méthodes de paiement :

1. Mobile Money.
2. Carte bancaire via Stripe, uniquement dans les pays compatibles.
3. Espèces à la livraison.

## 5.1. Paiement Mobile Money

Le client doit pouvoir :

- Choisir Mobile Money.
- Sélectionner un opérateur disponible.
- Renseigner son numéro si nécessaire.
- Initier le paiement.
- Consulter le statut de la transaction.
- Recevoir une confirmation après validation effective du paiement.

Les opérateurs proposés doivent dépendre du pays de lancement.

Exemples :

- Orange Money.
- MTN Mobile Money.
- Wave.
- M-Pesa.

Seuls les opérateurs réellement intégrés et disponibles dans le pays doivent être affichés.

## 5.2. Paiement par carte bancaire

Le client doit pouvoir :

- Choisir le paiement par carte.
- Consulter le montant à payer.
- Effectuer un paiement sécurisé.
- Recevoir une confirmation.
- Retrouver la transaction dans son historique.

Stripe doit être utilisé uniquement lorsque la configuration commerciale et géographique du projet le permet.

## 5.3. Paiement en espèces

Le client doit pouvoir choisir de payer lors de la livraison.

Dans ce cas :

- La commande est enregistrée comme non payée.
- Le livreur est informé du montant à encaisser.
- Le livreur confirme la réception de l'argent.
- La transaction est enregistrée.
- Le statut du paiement est actualisé.

Le système doit distinguer une livraison terminée d'une transaction effectivement encaissée.

## 5.4. Gestion des transactions

Chaque transaction doit contenir :

- Identifiant unique.
- Référence de la commande.
- Montant.
- Devise.
- Moyen de paiement.
- Date.
- Statut.
- Référence du fournisseur de paiement, si applicable.

Statuts possibles :

- En attente.
- Réussie.
- Échouée.
- Annulée.
- Remboursée.

Une transaction ne doit jamais être considérée comme réussie uniquement parce que le client a quitté l'écran de paiement.

Les paiements doivent être confirmés par le système de paiement concerné.

## 5.5. Historique et reçus

Le client doit pouvoir :

- Consulter ses commandes précédentes.
- Voir les montants payés.
- Consulter les moyens de paiement utilisés.
- Accéder au détail d'une transaction.
- Obtenir un reçu simple.

## 5.6. Frais et commissions

Le système doit permettre à l'administrateur de définir :

- Les frais de livraison.
- La rémunération des livreurs.
- Les commissions applicables aux restaurants.

Pour chaque commande, les montants doivent être clairement séparés.

Le MVP doit également enregistrer les sommes collectées en espèces par les livreurs afin de permettre leur rapprochement avec les montants dus à la plateforme.

---

# 6. INTERFACES À DÉVELOPPER

Les quatre fonctionnalités précédentes doivent être accessibles à travers les interfaces suivantes.

## A. Application mobile Client

Écrans nécessaires :

1. Inscription / connexion.
2. Accueil avec les deux services.
3. Liste des restaurants.
4. Détails d'un restaurant.
5. Catalogue des produits.
6. Panier.
7. Validation de commande.
8. Demande de livraison de colis.
9. Choix du moyen de paiement.
10. Suivi de livraison.
11. Historique des commandes.
12. Détails d'une commande.
13. Gestion des adresses.
14. Profil utilisateur.

## B. Application mobile Livreur

Écrans nécessaires :

1. Inscription / connexion.
2. Profil et validation du compte.
3. Tableau de bord.
4. Disponibilité en ligne / hors ligne.
5. Nouvelles demandes.
6. Détails d'une mission.
7. Navigation et itinéraire.
8. Livraison en cours.
9. Confirmation par OTP.
10. Historique des livraisons.

## C. Espace Restaurant

Interface simple permettant :

1. Connexion.
2. Gestion du profil.
3. Gestion des produits.
4. Réception des commandes.
5. Mise à jour des statuts.
6. Historique des commandes.

## D. Dashboard Administrateur

Interface permettant :

1. Gestion des utilisateurs.
2. Validation des livreurs.
3. Gestion des restaurants.
4. Supervision des commandes.
5. Attribution manuelle des livreurs.
6. Gestion des transactions.
7. Configuration des frais de livraison.
8. Configuration des zones desservies.
9. Consultation des statistiques essentielles.

Le dashboard doit rester simple. Il n'est pas nécessaire de développer un système avancé d'analyse ou de reporting pour le MVP.

---

# 7. EXIGENCES FONCTIONNELLES TRANSVERSALES

## A. Adaptation au marché africain

L'application doit :

- Prendre en charge les numéros de téléphone avec indicatif international.
- Afficher les prix dans la devise du pays concerné.
- Permettre la sélection des adresses par GPS ou point de repère.
- Fonctionner correctement sur des appareils Android modestes.
- Limiter la consommation de données mobiles.
- Gérer les interruptions temporaires de connexion.
- Proposer une interface simple, en français dans un premier temps.

## B. Gestion des erreurs

Prévoir les situations suivantes :

- Paiement refusé.
- Connexion Internet interrompue.
- Restaurant indisponible.
- Produit indisponible.
- Aucun livreur disponible.
- Livreur qui annule une mission.
- Client injoignable.
- Adresse incorrecte.
- Commande annulée.
- Livraison échouée.

Chaque situation doit produire un message compréhensible et permettre une action appropriée.

## C. Cohérence des opérations

Le système doit garantir que :

- Une commande ne peut pas être livrée avant sa récupération.
- Un livreur non validé ne peut pas accepter une mission.
- Une commande annulée ne peut pas poursuivre normalement son traitement.
- Un paiement ne peut pas être enregistré deux fois pour la même opération.
- Les montants affichés restent cohérents entre le panier, la commande et la transaction.
- Un client ne peut consulter que ses propres commandes.
- Un livreur ne peut modifier que les missions qui lui sont attribuées.
- Un restaurant ne peut gérer que ses propres produits et commandes.

---

# 8. DESIGN ET EXPÉRIENCE UTILISATEUR

L'application doit posséder une interface moderne, professionnelle et particulièrement intuitive.

Principes à respecter :

- Design épuré.
- Navigation simple.
- Écrans lisibles.
- Boutons d'action clairement identifiables.
- Informations essentielles immédiatement visibles.
- Parcours de commande rapide.
- Formulaires courts.
- Messages d'erreur compréhensibles.
- États de chargement visibles.
- Confirmation claire des actions importantes.

L'interface doit inspirer confiance et être accessible à des utilisateurs peu habitués aux applications complexes.

Éviter les interfaces surchargées et les fonctionnalités décoratives inutiles.

---

# 9. FONCTIONNALITÉS EXCLUES DU MVP

Ne pas développer :

- Livraison de médicaments.
- Livraison Express comme service distinct.
- Programme de fidélité.
- Parrainage.
- Abonnements premium.
- Publicités sponsorisées.
- Portefeuille électronique interne.
- Messagerie instantanée avancée.
- Intelligence artificielle.
- Livraison internationale.
- Livraison entre plusieurs villes.
- Commandes groupées.
- Livraison multi-destinations.
- Système de promotions complexe.
- Analyses statistiques avancées.
- Gestion avancée des stocks.
- Système de réservation de livraison.

Ces fonctionnalités pourront être envisagées après validation du produit sur le marché.

---

# 10. MÉTHODE DE TRAVAIL ATTENDUE

Tu dois procéder de manière structurée.

### Étape 1 — Analyse fonctionnelle

Avant toute implémentation :

- Examiner les quatre fonctionnalités principales.
- Identifier les parcours utilisateurs.
- Identifier les règles métier.
- Définir les interactions entre les différents acteurs.
- Identifier les dépendances fonctionnelles.
- Signaler les ambiguïtés ou décisions indispensables.

Ne pas ajouter de fonctionnalités sans justification.

### Étape 2 — Organisation des interfaces

Définir les écrans nécessaires pour chaque acteur.

Pour chaque écran, préciser :

- Son objectif.
- Les informations affichées.
- Les actions disponibles.
- Les validations nécessaires.
- Les états possibles.
- Les messages d'erreur.

### Étape 3 — Implémentation progressive

Développer les fonctionnalités dans cet ordre :

**Phase 1 :** Comptes utilisateurs, rôles et adresses.

**Phase 2 :** Restaurants, produits, commandes de repas et demandes de livraison de colis.

**Phase 3 :** Gestion des livreurs, attribution des missions et suivi des livraisons.

**Phase 4 :** Paiements, transactions et finalisation des parcours.

Chaque phase doit être fonctionnelle avant de passer à la suivante.

### Étape 4 — Vérification des parcours

Tester obligatoirement les scénarios suivants :

**Scénario 1 — Commande de repas**

Un client se connecte, sélectionne un restaurant, ajoute des produits au panier, confirme sa commande, effectue le paiement, attend la préparation, suit le livreur et reçoit sa commande.

**Scénario 2 — Livraison de colis**

Un client renseigne les adresses de départ et d'arrivée, obtient un prix, confirme sa demande, un livreur accepte la mission, récupère le colis et le remet au destinataire après vérification du code OTP.

**Scénario 3 — Paiement Mobile Money**

Un client choisit Mobile Money, effectue le paiement et reçoit une confirmation uniquement lorsque la transaction est effectivement validée.

**Scénario 4 — Paiement en espèces**

Un client commande avec paiement à la livraison. Le livreur encaisse le montant, confirme la réception et le système enregistre la transaction.

**Scénario 5 — Aucun livreur disponible**

Un client effectue une demande alors qu'aucun livreur n'est disponible. Le système doit informer le client et proposer une issue cohérente sans laisser la commande bloquée indéfiniment.

**Scénario 6 — Annulation**

Une commande est annulée avant sa récupération. Le système met à jour son statut et traite correctement le paiement éventuel.

---

# 11. RÉSULTAT FINAL ATTENDU

À la fin du développement, le MVP doit permettre à un utilisateur réel de :

1. Créer un compte et renseigner son adresse.
2. Commander un repas ou demander une livraison de colis.
3. Payer sa commande avec un moyen de paiement disponible.
4. Suivre sa livraison et recevoir sa commande.

Un restaurant doit pouvoir recevoir et préparer une commande.

Un livreur doit pouvoir accepter une mission, récupérer une commande et effectuer la livraison.

Un administrateur doit pouvoir superviser les opérations essentielles.

**Le MVP doit être réellement utilisable et pas uniquement une démonstration visuelle.**

Toutes les actions principales doivent fonctionner de bout en bout, avec des données persistantes et des états cohérents.

Ne simule pas une fonctionnalité critique en la présentant comme opérationnelle.

Si une intégration externe nécessite des identifiants ou une configuration non disponibles, prépare le parcours nécessaire et indique clairement ce qui reste à connecter ou à valider.

# CONSIGNE FINALE

Concentre-toi exclusivement sur les quatre fonctionnalités principales définies.

Privilégie la simplicité, la fiabilité et l'expérience utilisateur.

N'ajoute pas de fonctionnalités secondaires.

Commence par présenter l'analyse fonctionnelle, les parcours utilisateurs et le plan de réalisation.

Attends ensuite ma validation avant de commencer l'implémentation.