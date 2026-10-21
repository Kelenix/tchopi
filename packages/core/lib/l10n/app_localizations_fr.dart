// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appBrand => 'tchopi';

  @override
  String get welcomeClientHeadline =>
      'Vos plats et vos colis, livrés partout dans votre ville.';

  @override
  String get welcomeClientSubtitle =>
      'Payez en Mobile Money, par carte ou en espèces.';

  @override
  String get featureRestaurants => 'Restaurants du quartier';

  @override
  String get featureParcels => 'Colis d\'un point à un autre';

  @override
  String get featureTracking => 'Suivi en direct';

  @override
  String get actionCreateAccount => 'Créer un compte';

  @override
  String get actionSignIn => 'Se connecter';

  @override
  String get actionContinue => 'Continuer';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionBack => 'Retour';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPhone => 'Téléphone';

  @override
  String get fieldPhoneHint => '+225 07 00 00 00 00';

  @override
  String get fieldIdentifier => 'Email ou téléphone';

  @override
  String get fieldPassword => 'Mot de passe';

  @override
  String get fieldNewPassword => 'Nouveau mot de passe';

  @override
  String get fieldPasswordRule =>
      '8 caractères minimum, avec des lettres et des chiffres.';

  @override
  String get fieldFirstName => 'Prénom';

  @override
  String get fieldLastName => 'Nom';

  @override
  String get fieldCity => 'Ville';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get errorEmail => 'Adresse email invalide.';

  @override
  String get errorPhone => 'Numéro de mobile invalide.';

  @override
  String get errorIdentifier =>
      'Saisissez un email ou un numéro de mobile valide.';

  @override
  String get errorPassword =>
      'Le mot de passe doit faire 8 caractères minimum, avec des lettres et des chiffres.';

  @override
  String get errorRequired => 'Ce champ est obligatoire.';

  @override
  String get signUpTitle => 'Créer votre compte';

  @override
  String get signUpSubtitle => 'Un code de confirmation vous sera envoyé.';

  @override
  String get signUpHaveAccount => 'J\'ai déjà un compte';

  @override
  String get signInTitle => 'Content de vous revoir';

  @override
  String get signInSubtitle =>
      'Connectez-vous avec votre email ou votre numéro.';

  @override
  String get signInForgot => 'Mot de passe oublié ?';

  @override
  String get signInNoAccount => 'Pas encore de compte ? Créer un compte';

  @override
  String get verifyTitle => 'Saisissez le code';

  @override
  String verifySubtitle(String destination) {
    return 'Un code à 6 chiffres a été envoyé à $destination.';
  }

  @override
  String get verifyResend => 'Renvoyer le code';

  @override
  String verifyResendIn(int seconds) {
    return 'Renvoyer le code dans $seconds s';
  }

  @override
  String get verifyResent => 'Nouveau code envoyé.';

  @override
  String get verifyChangeDestination => 'Modifier l\'email ou le numéro';

  @override
  String get verifyMissing =>
      'Cette vérification a expiré. Recommencez depuis la connexion.';

  @override
  String get resetTitle => 'Mot de passe oublié';

  @override
  String get resetSubtitle =>
      'Recevez un code pour choisir un nouveau mot de passe.';

  @override
  String resetCodeSubtitle(String destination) {
    return 'Si un compte existe pour $destination, un code vient d\'être envoyé.';
  }

  @override
  String get resetSubmit => 'Changer le mot de passe';

  @override
  String get resetDone => 'Mot de passe modifié.';

  @override
  String get profileSetupTitle => 'Faisons connaissance';

  @override
  String get profileSetupSubtitle =>
      'Ces informations permettent au livreur de vous joindre.';

  @override
  String get profileEditTitle => 'Mes informations';

  @override
  String get profileSaved => 'Informations enregistrées.';

  @override
  String get accountTitle => 'Mon compte';

  @override
  String get accountLogin => 'Identifiant de connexion';

  @override
  String get accountEdit => 'Modifier mes informations';

  @override
  String get accountChangeLogin => 'Changer d\'email ou de numéro de connexion';

  @override
  String get accountSignOut => 'Se déconnecter';

  @override
  String get accountDelete => 'Supprimer mon compte';

  @override
  String get placeSearchTooltip => 'Rechercher un lieu';

  @override
  String get placeSearchHint => 'Quartier, carrefour, pharmacie, marché…';

  @override
  String get placeSearchEmpty =>
      'Aucun lieu trouvé. Vous pouvez aussi déplacer la carte sous l\'épingle.';

  @override
  String get placeSearchError =>
      'Recherche indisponible pour le moment. Déplacez la carte sous l\'épingle.';

  @override
  String get cityPickerTitle => 'Choisir une ville';

  @override
  String get cityPickerSearch => 'Rechercher une ville';

  @override
  String get cityPickerEmpty => 'Aucune ville ne correspond.';

  @override
  String get cityServed => 'Livraisons disponibles';

  @override
  String get appearanceTitle => 'Apparence';

  @override
  String get appearanceSystem => 'Auto';

  @override
  String get appearanceLight => 'Clair';

  @override
  String get appearanceDark => 'Sombre';

  @override
  String get accountLicenses => 'Licences';

  @override
  String get signOutConfirmTitle => 'Se déconnecter ?';

  @override
  String get signOutConfirmBody =>
      'Vous devrez vous reconnecter pour commander ou suivre une livraison.';

  @override
  String get deleteConfirmTitle => 'Supprimer votre compte ?';

  @override
  String get deleteConfirmBody =>
      'Votre nom, votre téléphone et vos accès seront effacés. Cette action est définitive. L\'historique des commandes est conservé sans donnée vous identifiant.';

  @override
  String get deleteConfirmAction => 'Oui, supprimer';

  @override
  String get loginChangeTitle => 'Changer d\'identifiant';

  @override
  String get loginChangeSubtitle =>
      'Un code sera envoyé à la nouvelle adresse ou au nouveau numéro. L\'ancien reste valable tant que le code n\'est pas saisi.';

  @override
  String get loginChangeField => 'Nouvel email ou numéro';

  @override
  String get loginChangeDone => 'Identifiant de connexion modifié.';

  @override
  String get loadingAccount => 'Chargement de votre compte…';

  @override
  String get loadingAccountError => 'Impossible de charger votre compte.';

  @override
  String get failureNetwork =>
      'Pas de connexion internet. Vérifiez votre réseau puis réessayez.';

  @override
  String get failureInvalidCredentials =>
      'Email, numéro ou mot de passe incorrect.';

  @override
  String get failureUserExists => 'Un compte existe déjà avec cet identifiant.';

  @override
  String get failureCodeInvalid => 'Code incorrect ou expiré.';

  @override
  String get failureRateLimited =>
      'Trop de tentatives. Patientez une minute avant de réessayer.';

  @override
  String get failureEmailDisabled =>
      'La connexion par email n\'est pas encore disponible : utilisez votre numéro de téléphone.';

  @override
  String get failureSmsFailed =>
      'Impossible d\'envoyer le code par SMS à ce numéro. Vérifiez-le, ou demandez à l\'administrateur de l\'autoriser.';

  @override
  String get failureWeakPassword =>
      'Mot de passe trop faible : 8 caractères minimum, avec des lettres et des chiffres.';

  @override
  String get failureSamePassword =>
      'Choisissez un mot de passe différent de l\'actuel.';

  @override
  String get failureSuspended =>
      'Votre compte est suspendu. Contactez le support.';

  @override
  String get failureNotConfirmed =>
      'Votre compte n\'est pas encore confirmé. Un nouveau code vient d\'être envoyé.';

  @override
  String get failureUnknown =>
      'Une erreur est survenue. Réessayez dans un instant.';

  @override
  String get accountAddresses => 'Mes adresses';

  @override
  String get addressesTitle => 'Mes adresses';

  @override
  String get addressesEmpty => 'Ajoutez votre première adresse';

  @override
  String get addressesEmptyBody =>
      'Une position sur la carte, votre quartier et un point de repère suffisent : pas besoin du nom de la rue.';

  @override
  String get addressAdd => 'Ajouter une adresse';

  @override
  String get addressDefault => 'Par défaut';

  @override
  String get addressSetDefault => 'Définir par défaut';

  @override
  String get addressEdit => 'Modifier';

  @override
  String get addressDelete => 'Supprimer';

  @override
  String get addressDeleteTitle => 'Supprimer cette adresse ?';

  @override
  String get addressDeleteBody =>
      'Les commandes déjà passées gardent leur adresse d\'origine.';

  @override
  String get addressNewTitle => 'Nouvelle adresse';

  @override
  String get addressEditTitle => 'Modifier l\'adresse';

  @override
  String get addressSaved => 'Adresse enregistrée.';

  @override
  String get addressMoveMap =>
      'Déplacez la carte pour placer l\'épingle sur votre entrée.';

  @override
  String get addressMyPosition => 'Ma position';

  @override
  String get fieldLabel => 'Libellé';

  @override
  String get labelHome => 'Maison';

  @override
  String get labelWork => 'Bureau';

  @override
  String get labelOther => 'Autre';

  @override
  String get fieldDistrict => 'Quartier';

  @override
  String get fieldLandmark => 'Point de repère';

  @override
  String get fieldLandmarkHint => 'Ex. derrière la pharmacie centrale';

  @override
  String get fieldInstructions => 'Instructions (facultatif)';

  @override
  String get fieldInstructionsHint => 'Ex. maison avec portail bleu';

  @override
  String get locationRationaleTitle => 'Utiliser votre position ?';

  @override
  String get locationRationaleBody =>
      'Votre position sert uniquement à placer l\'adresse sur la carte. Vous pourrez ensuite l\'ajuster.';

  @override
  String get locationDenied =>
      'Localisation refusée : placez l\'épingle sur la carte.';

  @override
  String get locationDeniedForever =>
      'Localisation bloquée. Autorisez-la dans les réglages du téléphone.';

  @override
  String get locationOpenSettings => 'Réglages';

  @override
  String get locationOff => 'Activez la localisation (GPS) du téléphone.';

  @override
  String get locationLowAccuracy =>
      'Précision faible : ajustez l\'épingle sur la carte.';

  @override
  String get failureOutOfZone => 'Cette adresse est hors de la zone desservie.';

  @override
  String get failureForbidden => 'Action réservée aux administrateurs.';

  @override
  String get adminZones => 'Zones et tarifs';

  @override
  String get zonesEmpty => 'Aucune zone pour le moment';

  @override
  String get zoneAdd => 'Ajouter une zone';

  @override
  String get zoneNewTitle => 'Nouvelle zone';

  @override
  String get zoneEditTitle => 'Modifier la zone';

  @override
  String get zoneActive => 'Zone active';

  @override
  String get zoneInactive => 'Désactivée';

  @override
  String zoneRadius(String km) {
    return 'Rayon $km km';
  }

  @override
  String get zoneViewOnMap => 'Voir le centre sur une carte';

  @override
  String get zoneSaved => 'Zone et tarifs enregistrés.';

  @override
  String get fieldZoneName => 'Nom de la zone';

  @override
  String get fieldCenterLat => 'Latitude du centre';

  @override
  String get fieldCenterLng => 'Longitude du centre';

  @override
  String get fieldRadiusKm => 'Rayon (km)';

  @override
  String get pricingFood => 'Tarifs repas';

  @override
  String get pricingParcel => 'Tarifs colis';

  @override
  String get fieldBaseFee => 'Base (FCFA)';

  @override
  String get fieldPerKm => 'Prix par km (FCFA)';

  @override
  String get fieldMinFee => 'Plancher (FCFA)';

  @override
  String get fieldMaxFee => 'Plafond (FCFA)';

  @override
  String get fieldDetour => 'Coefficient de détour';

  @override
  String get fieldRounding => 'Arrondi (FCFA)';

  @override
  String get fieldCourierBase => 'Livreur : fixe (FCFA)';

  @override
  String get fieldCourierPerKm => 'Livreur : par km (FCFA)';

  @override
  String get simulatorTitle => 'Simulateur';

  @override
  String get simulatorDistance => 'Distance à vol d\'oiseau (km)';

  @override
  String get simulatorRun => 'Calculer';

  @override
  String simulatorResult(String distance, String fee, String earning) {
    return '$distance km de référence · frais $fee · livreur $earning';
  }

  @override
  String get simulatorSaveFirst =>
      'Enregistrez la zone pour simuler ses tarifs.';

  @override
  String get errorNumber => 'Nombre invalide.';

  @override
  String get errorMinMax =>
      'Le plancher doit être inférieur ou égal au plafond.';

  @override
  String get courierProfileTitle => 'Devenir livreur';

  @override
  String get courierProfileEditTitle => 'Mon dossier livreur';

  @override
  String get courierProfileSubtitle =>
      'Ces informations sont vérifiées par l\'équipe avant votre première mission.';

  @override
  String get fieldZone => 'Zone de travail';

  @override
  String get fieldVehicle => 'Moyen de transport';

  @override
  String get vehicleMotorbike => 'Moto';

  @override
  String get vehicleBicycle => 'Vélo';

  @override
  String get vehicleCar => 'Voiture';

  @override
  String get vehicleOnFoot => 'À pied';

  @override
  String get fieldPlate => 'Immatriculation';

  @override
  String get fieldPhoto => 'Photo de profil';

  @override
  String get photoHint =>
      'Visage bien visible : le client la voit pour vous reconnaître.';

  @override
  String get photoTake => 'Prendre une photo';

  @override
  String get photoChoose => 'Choisir dans la galerie';

  @override
  String get errorPhotoRequired => 'Ajoutez une photo de profil.';

  @override
  String get courierSubmit => 'Soumettre mon profil';

  @override
  String get courierStatusTitle => 'Mon compte livreur';

  @override
  String get courierPendingTitle => 'Nous vérifions votre profil';

  @override
  String get courierPendingBody =>
      'L\'équipe valide votre profil, généralement sous 48 heures. Revenez ici pour suivre son statut.';

  @override
  String get courierApprovedTitle => 'Compte approuvé';

  @override
  String get courierApprovedBody =>
      'Votre compte est validé : passez en ligne depuis l\'accueil pour recevoir des missions.';

  @override
  String get courierRejectedTitle => 'Profil refusé';

  @override
  String courierRejectedBody(String reason) {
    return 'Motif : $reason. Corrigez votre profil puis soumettez-le à nouveau.';
  }

  @override
  String get courierSuspendedTitle => 'Compte suspendu';

  @override
  String courierSuspendedBody(String reason) {
    return 'Motif : $reason. Contactez le support pour en savoir plus.';
  }

  @override
  String get courierEditProfile => 'Modifier mon profil';

  @override
  String get courierRefresh => 'Actualiser';

  @override
  String get failureZoneUnavailable =>
      'Cette zone n\'est plus desservie. Choisissez-en une autre.';

  @override
  String get failureCourierSuspended => 'Votre compte livreur est suspendu.';

  @override
  String get failureReasonRequired => 'Indiquez un motif.';

  @override
  String get failureNotFound => 'Élément introuvable. Actualisez la liste.';

  @override
  String get failureCannotTargetSelf =>
      'Vous ne pouvez pas appliquer cette action à votre propre compte.';

  @override
  String get failureInvalidIdentifier => 'Email ou numéro invalide.';

  @override
  String get adminCouriers => 'Livreurs';

  @override
  String get adminUsers => 'Utilisateurs';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusApproved => 'Approuvés';

  @override
  String get statusRejected => 'Refusés';

  @override
  String get statusSuspended => 'Suspendus';

  @override
  String get couriersEmpty => 'Aucun livreur dans cette catégorie';

  @override
  String get courierApprove => 'Approuver';

  @override
  String get courierReject => 'Refuser';

  @override
  String get courierSuspend => 'Suspendre';

  @override
  String get courierReactivate => 'Réactiver';

  @override
  String get courierDecisionDone => 'Décision enregistrée.';

  @override
  String get reasonTitleReject => 'Motif du refus';

  @override
  String get reasonTitleSuspend => 'Motif de la suspension';

  @override
  String get reasonField => 'Motif (transmis à la personne)';

  @override
  String get usersSearch => 'Rechercher par nom ou téléphone';

  @override
  String get usersEmpty => 'Aucun utilisateur trouvé';

  @override
  String get userSuspended => 'Suspendu';

  @override
  String get userSuspend => 'Suspendre le compte';

  @override
  String get userReactivate => 'Réactiver le compte';

  @override
  String get userChangeLogin => 'Modifier l\'identifiant de connexion';

  @override
  String get userChangeLoginField => 'Nouvel email ou numéro';

  @override
  String get userActionDone => 'Action enregistrée.';

  @override
  String get userNoName => 'Profil incomplet';

  @override
  String get spacesTitle => 'Changer d\'espace';

  @override
  String get spaceCurrent => 'Espace actuel';

  @override
  String get spaceClient => 'Client';

  @override
  String get spaceClientBody =>
      'Commander un repas, envoyer un colis, gérer mes adresses.';

  @override
  String get spaceCourier => 'Livreur';

  @override
  String get spaceCourierBody => 'Mon profil livreur et mes missions.';

  @override
  String get spaceBecomeCourier => 'Devenir livreur';

  @override
  String get spaceBecomeCourierBody =>
      'Livrez dans votre ville, à votre rythme. Votre profil est validé par l\'équipe.';

  @override
  String get spaceRestaurant => 'Restaurant';

  @override
  String get spaceRestaurantBody =>
      'Commandes reçues en direct, menu et horaires.';

  @override
  String get restaurantMenu => 'Menu';

  @override
  String get restaurantProfile => 'Profil et horaires';

  @override
  String get menuEmpty => 'Ajoutez votre premier produit';

  @override
  String get menuEmptyBody =>
      'Les clients voient votre menu dès qu\'un produit est disponible.';

  @override
  String get productAdd => 'Ajouter un produit';

  @override
  String get productNewTitle => 'Nouveau produit';

  @override
  String get productEditTitle => 'Modifier le produit';

  @override
  String get fieldProductName => 'Nom du produit';

  @override
  String get fieldDescription => 'Description';

  @override
  String get fieldPrice => 'Prix (F CFA)';

  @override
  String get fieldCategory => 'Catégorie';

  @override
  String get categoryNew => 'Nouvelle catégorie';

  @override
  String get categoryNone => 'Sans catégorie';

  @override
  String get productAvailable => 'Disponible';

  @override
  String get productUnavailable => 'Indisponible';

  @override
  String get productArchive => 'Retirer du menu';

  @override
  String get productArchiveTitle => 'Retirer ce produit du menu ?';

  @override
  String get productArchiveBody =>
      'Il disparaît pour les clients ; les commandes passées le gardent.';

  @override
  String get productSaved => 'Produit enregistré.';

  @override
  String get productPhoto => 'Photo du produit';

  @override
  String get photoChange => 'Changer la photo';

  @override
  String get fieldCategoryName => 'Nom de la catégorie';

  @override
  String get restaurantOpenNow => 'Ouvert';

  @override
  String get restaurantClosedNow => 'Fermé';

  @override
  String get restaurantTemporarilyClosed => 'Fermé temporairement';

  @override
  String get restaurantTemporarilyClosedBody =>
      'Ferme le restaurant tout de suite, quels que soient les horaires.';

  @override
  String get fieldPrepTime => 'Temps de préparation moyen (min)';

  @override
  String get fieldRestaurantCategory => 'Type de cuisine';

  @override
  String get fieldCommission => 'Commission (%)';

  @override
  String commissionReadOnly(String rate) {
    return 'Commission : $rate % (fixée par l\'équipe)';
  }

  @override
  String get coverPhoto => 'Photo de couverture';

  @override
  String get openingHours => 'Horaires d\'ouverture';

  @override
  String get hoursAdd => 'Ajouter une plage';

  @override
  String get hoursClosedDay => 'Fermé';

  @override
  String get hoursInvalid =>
      'L\'heure de fermeture doit suivre l\'heure d\'ouverture.';

  @override
  String get restaurantSaved => 'Restaurant enregistré.';

  @override
  String get weekday1 => 'Lundi';

  @override
  String get weekday2 => 'Mardi';

  @override
  String get weekday3 => 'Mercredi';

  @override
  String get weekday4 => 'Jeudi';

  @override
  String get weekday5 => 'Vendredi';

  @override
  String get weekday6 => 'Samedi';

  @override
  String get weekday7 => 'Dimanche';

  @override
  String get adminRestaurants => 'Restaurants';

  @override
  String get restaurantsEmpty => 'Aucun restaurant pour le moment';

  @override
  String get restaurantAdd => 'Ajouter un restaurant';

  @override
  String get restaurantNewTitle => 'Nouveau restaurant';

  @override
  String get restaurantEditTitle => 'Modifier le restaurant';

  @override
  String get fieldRestaurantName => 'Nom du restaurant';

  @override
  String get restaurantActive => 'Visible par les clients';

  @override
  String get restaurantInactive => 'Désactivé';

  @override
  String get managersTitle => 'Gérants';

  @override
  String get managersEmpty => 'Aucun gérant';

  @override
  String get managerInvite => 'Inviter un gérant';

  @override
  String get managerInviteField => 'Email ou numéro du gérant';

  @override
  String get managerPending => 'Invitation en attente d\'inscription';

  @override
  String get managerLinked => 'Compte relié';

  @override
  String get managerRemove => 'Retirer';

  @override
  String get managersSaveFirst =>
      'Enregistrez le restaurant pour inviter ses gérants.';

  @override
  String get fieldRestaurantZone => 'Zone';

  @override
  String get fieldLatitude => 'Latitude';

  @override
  String get fieldLongitude => 'Longitude';

  @override
  String get restaurantViewOnMap => 'Voir l\'emplacement sur une carte';

  @override
  String get homeGreetingAnonymous => 'Bonjour';

  @override
  String homeGreeting(String name) {
    return 'Bonjour $name';
  }

  @override
  String get homeHeadline => 'Que voulez-vous aujourd\'hui ?';

  @override
  String get homeServiceFood => 'Repas';

  @override
  String get homeServiceFoodBody => 'Restaurants ouverts près de vous';

  @override
  String get homeServiceParcel => 'Colis';

  @override
  String get homeServiceParcelBody => 'Envoyez d\'un point à un autre';

  @override
  String get homeSoon => 'Bientôt';

  @override
  String get homeFeaturedTitle => 'Ce soir, on mange quoi ?';

  @override
  String get homeRestaurants => 'Restaurants près de vous';

  @override
  String get homeRestaurantsEmpty =>
      'Aucun restaurant n\'est encore disponible dans votre zone.';

  @override
  String get homeDeliverTo => 'Livrer à';

  @override
  String get homeNoAddress => 'Ajouter une adresse';

  @override
  String restaurantPrepRange(int min, int max) {
    return '$min–$max min';
  }

  @override
  String get restaurantMenuSoon => 'Le menu de ce restaurant arrive bientôt.';

  @override
  String get menuOther => 'Autres';

  @override
  String get factPrep => 'Préparation';

  @override
  String get factNow => 'Maintenant';

  @override
  String get cartView => 'Voir le panier';

  @override
  String cartItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
    );
    return '$_temp0';
  }

  @override
  String get cartReplaceTitle => 'Commencer un nouveau panier ?';

  @override
  String cartReplaceBody(String restaurant) {
    return 'Votre panier contient des plats de $restaurant. Il sera vidé.';
  }

  @override
  String get cartReplaceConfirm => 'Vider et ajouter';

  @override
  String get optionsRequired => 'Obligatoire';

  @override
  String get optionsOptional => 'Facultatif';

  @override
  String optionsUpTo(int count) {
    return 'Jusqu\'à $count';
  }

  @override
  String optionsInCart(int count) {
    return '$count dans le panier';
  }

  @override
  String get productAddTooltip => 'Ajouter au panier';

  @override
  String get productCustomize => 'Personnaliser';

  @override
  String get checkoutTitle => 'Votre commande';

  @override
  String get checkoutDeliverTo => 'Livrer à';

  @override
  String get checkoutChangeAddress => 'Changer';

  @override
  String get checkoutPayment => 'Paiement';

  @override
  String get paymentCash => 'Espèces à la livraison';

  @override
  String get paymentMobileMoney => 'Mobile Money';

  @override
  String get paymentCard => 'Carte bancaire';

  @override
  String get paymentSoon => 'Bientôt';

  @override
  String get paymentMobileMoneyHint =>
      'Orange Money, MTN MoMo, Wave, Moov Money';

  @override
  String get paymentCardHint => 'Visa, Mastercard · page sécurisée Stripe';

  @override
  String get momoTitle => 'Paiement Mobile Money';

  @override
  String momoBody(String amount) {
    return 'Payez $amount sur la page sécurisée de nyole (Orange Money, MTN MoMo, Wave ou Moov Money), puis revenez ici : la commande part dès que l\'opérateur confirme le paiement.';
  }

  @override
  String onlinePay(String amount) {
    return 'Payer $amount';
  }

  @override
  String get momoWaiting =>
      'Validez le paiement sur votre téléphone. Nous attendons la confirmation de l\'opérateur…';

  @override
  String get onlineResume => 'Reprendre le paiement';

  @override
  String get onlineCheck => 'J\'ai payé : vérifier';

  @override
  String get onlineStillPending =>
      'Paiement pas encore confirmé. Si vous l\'avez validé, patientez quelques secondes.';

  @override
  String get momoFailed => 'Le paiement n\'a pas été validé par l\'opérateur.';

  @override
  String get cardTitle => 'Paiement par carte';

  @override
  String cardBody(String amount) {
    return 'Payez $amount sur la page sécurisée de Stripe (Visa, Mastercard ; validation de votre banque si elle la demande), puis revenez ici : la commande part dès que la banque confirme le paiement.';
  }

  @override
  String get cardWaiting =>
      'Terminez le paiement sur la page Stripe. Nous attendons la confirmation de votre banque…';

  @override
  String get cardFailed =>
      'Le paiement n\'a pas abouti. Réessayez ou choisissez un autre moyen de paiement.';

  @override
  String get onlineRetry => 'Réessayer';

  @override
  String onlineDeadline(String time) {
    return 'Sans paiement d\'ici $time, la commande est annulée.';
  }

  @override
  String get onlineChangeMethod => 'Changer de moyen de paiement';

  @override
  String get onlineChangeBody =>
      'Cette commande non payée sera annulée ; vous retrouverez votre demande pour choisir un autre moyen de paiement.';

  @override
  String get failurePaymentClosed =>
      'Le délai de paiement est dépassé : la commande a été annulée.';

  @override
  String get failureAlreadyPaid => 'Cette commande est déjà payée.';

  @override
  String get failurePaymentProvider =>
      'Le service de paiement ne répond pas. Réessayez dans un instant.';

  @override
  String get orderPaymentTimeout => 'Paiement non reçu à temps';

  @override
  String get orderLatePayment => 'Paiement reçu après l\'annulation';

  @override
  String get checkoutSubtotal => 'Sous-total';

  @override
  String get checkoutDeliveryFee => 'Frais de livraison';

  @override
  String get checkoutDistance => 'Distance par la route';

  @override
  String get checkoutTotal => 'Total';

  @override
  String get checkoutToConfirm => 'À confirmer';

  @override
  String checkoutConfirm(String total) {
    return 'Commander · $total';
  }

  @override
  String get checkoutNeedAddress =>
      'Ajoutez une adresse de livraison pour commander.';

  @override
  String get checkoutEmpty => 'Votre panier est vide';

  @override
  String get checkoutUpdateCart => 'Mettre à jour le panier';

  @override
  String get issueRestaurantClosed => 'Le restaurant est fermé pour le moment.';

  @override
  String issueProductUnavailable(String name) {
    return '« $name » n\'est plus disponible.';
  }

  @override
  String issueOptions(String name) {
    return '« $name » demande un choix d\'options : commandez-le sur tchopi.com.';
  }

  @override
  String get failurePriceChanged =>
      'Les prix ont changé : vérifiez le nouveau total.';

  @override
  String get failureCartChanged =>
      'Votre panier a changé : vérifiez-le avant de commander.';

  @override
  String get failurePaymentUnavailable =>
      'Ce moyen de paiement n\'est pas encore disponible.';

  @override
  String get failureInvalidPlate =>
      'Immatriculation non reconnue : format ivoirien attendu (ex. 1234 AB 01).';

  @override
  String get failureInvalidId =>
      'Numéro non reconnu pour cette pièce d\'identité.';

  @override
  String get failureCashDue => 'Reversez d\'abord les espèces encaissées.';

  @override
  String get fieldIdType => 'Pièce d\'identité';

  @override
  String get fieldIdNumber => 'Numéro de la pièce';

  @override
  String get courierPersonalInfo => 'Nom, téléphone et ville : dans Mon compte';

  @override
  String get courierIdHint =>
      'À pied ou à vélo, votre pièce d\'identité est vérifiée automatiquement.';

  @override
  String courierFormatExample(String example) {
    return 'Exemple : $example';
  }

  @override
  String get courierDeleteProfile => 'Supprimer mon profil livreur';

  @override
  String get courierDeleteTitle => 'Supprimer votre profil livreur ?';

  @override
  String get courierDeleteBody =>
      'Votre compte reste actif ; vos missions et gains passés sont conservés. Impossible avec une mission en cours ou des espèces à reverser.';

  @override
  String get courierDeleteConfirm => 'Supprimer';

  @override
  String get historyYesterday => 'Hier';

  @override
  String get historyMonth30 => '30 derniers jours';

  @override
  String get historyThisMonth => 'Ce mois-ci';

  @override
  String get historyCustom => 'Période…';

  @override
  String get historyAllStatuses => 'Tous';

  @override
  String get historyPending => 'En attente';

  @override
  String get historyInProgress => 'En cours';

  @override
  String get historyDelivered => 'Livrées';

  @override
  String get historyCancelled => 'Annulées';

  @override
  String get historySearch => 'N° de commande';

  @override
  String get historyLoadMore => 'Voir plus';

  @override
  String historySummary(int count, String earnings, String km) {
    return '$count livraison(s) · $earnings · $km km';
  }

  @override
  String get historyNone => 'Aucune livraison pour ces filtres';

  @override
  String get failureAccountBusy =>
      'Une commande est en cours : attendez qu\'elle soit terminée pour supprimer votre compte.';

  @override
  String get authWelcome => 'Bienvenue !';

  @override
  String get authPhonePrompt => 'Commençons par votre numéro de téléphone';

  @override
  String get authCountry => 'Indicatif';

  @override
  String get authPhone => 'Numéro';

  @override
  String get authPhoneInvalid => 'Saisissez un numéro de mobile valide';

  @override
  String get authBySms => 'SMS';

  @override
  String get authByWhatsapp => 'WhatsApp';

  @override
  String get authOr => 'ou avec';

  @override
  String get authGoogle => 'Continuer avec Google';

  @override
  String get authOtherMethods => 'Autres méthodes';

  @override
  String get authEmailSignIn => 'Se connecter avec un e-mail';

  @override
  String get authEmailSignUp => 'Créer un compte avec un e-mail';

  @override
  String get authPhoneUnavailable =>
      'La connexion par SMS arrive bientôt : utilisez Google ou un e-mail en attendant.';

  @override
  String get authTerms =>
      'En continuant, vous acceptez les conditions d\'utilisation et la politique de confidentialité de Tchopi.';

  @override
  String get splashTagline => 'Vos plats préférés, livrés chez vous';

  @override
  String get rateYourCourier => 'votre livreur';

  @override
  String rateTitle(String name) {
    return 'Comment était $name ?';
  }

  @override
  String get rateBody => 'Touchez une étoile pour noter la livraison.';

  @override
  String get rateThanks => 'Merci pour votre note !';

  @override
  String get rateThanksBody =>
      'Elle aide les livreurs à progresser et les restaurants à bien choisir.';

  @override
  String rateStars(int count) {
    return '$count étoile(s)';
  }

  @override
  String get rateComment => 'Un mot pour le livreur (facultatif)';

  @override
  String get rateSubmit => 'Envoyer ma note';

  @override
  String get rateTagFast => 'Rapide';

  @override
  String get rateTagFriendly => 'Aimable';

  @override
  String get rateTagCareful => 'Commande intacte';

  @override
  String get rateTagOnTime => 'À l\'heure';

  @override
  String get rateTagLate => 'En retard';

  @override
  String get rateTagDamaged => 'Commande abîmée';

  @override
  String get rateTagRude => 'Peu aimable';

  @override
  String get failureRatingClosed =>
      'Il n\'est plus possible de noter cette livraison.';

  @override
  String get failureAlreadyRated => 'Vous avez déjà noté cette livraison.';

  @override
  String get courierRatingLabel => 'Ma note';

  @override
  String get failureAlreadyAccepted =>
      'Le restaurant prépare déjà votre commande. Contactez le support.';

  @override
  String get failureInvalidTransition =>
      'Cette action n\'est plus possible : la commande a changé.';

  @override
  String get failureCartEmpty => 'Votre panier est vide.';

  @override
  String get ordersTitle => 'Mes commandes';

  @override
  String get ordersEmpty => 'Aucune commande pour le moment';

  @override
  String get ordersEmptyBody => 'Vos commandes de repas apparaîtront ici.';

  @override
  String get ordersActive => 'En cours';

  @override
  String get ordersPast => 'Historique';

  @override
  String orderNumber(String number) {
    return 'Commande $number';
  }

  @override
  String get orderItemsTitle => 'Articles';

  @override
  String get orderTimeline => 'Suivi';

  @override
  String get orderDeliveryTitle => 'Livraison';

  @override
  String get orderCancel => 'Annuler la commande';

  @override
  String get orderCancelTitle => 'Annuler cette commande ?';

  @override
  String get orderCancelBody =>
      'Le restaurant n\'a pas encore accepté : rien ne vous sera facturé.';

  @override
  String get orderCancelPaidBody =>
      'Le restaurant n\'a pas encore accepté : votre paiement vous sera remboursé intégralement.';

  @override
  String get orderCancelled => 'Commande annulée.';

  @override
  String orderReason(String reason) {
    return 'Motif : $reason';
  }

  @override
  String get orderNoResponse => 'Sans réponse du restaurant';

  @override
  String get orderCancelledByCustomer => 'Annulée par le client';

  @override
  String get homeActiveOrder => 'Commande en cours';

  @override
  String get restaurantOrders => 'Commandes';

  @override
  String get ordersNew => 'Nouvelles';

  @override
  String get ordersInProgress => 'En cours';

  @override
  String get ordersDone => 'Terminées';

  @override
  String get ordersNewEmpty => 'Aucune nouvelle commande';

  @override
  String get ordersInProgressEmpty => 'Aucune commande en cours';

  @override
  String get ordersDoneEmpty => 'Aucune commande terminée aujourd\'hui';

  @override
  String get orderAccept => 'Accepter';

  @override
  String get orderReject => 'Refuser';

  @override
  String get orderStartPreparing => 'Lancer la préparation';

  @override
  String get orderMarkReady => 'Commande prête';

  @override
  String orderAnswerWithin(int minutes) {
    return 'Répondre sous $minutes min';
  }

  @override
  String get orderWaitingCourier =>
      'Prête · proposée aux livreurs, en attente d\'acceptation';

  @override
  String get rejectTitle => 'Motif du refus';

  @override
  String get rejectUnavailable => 'Produit indisponible';

  @override
  String get rejectClosing => 'Fermeture du restaurant';

  @override
  String get rejectBusy => 'Trop de commandes';

  @override
  String get rejectOther => 'Autre motif';

  @override
  String get todaySales => 'Ventes du jour';

  @override
  String get todayCommission => 'Commission';

  @override
  String get todayNet => 'Net';

  @override
  String get newOrderAlert => 'Nouvelle commande !';

  @override
  String get orderStatusAwaitingPayment => 'Paiement en attente';

  @override
  String get orderStatusPending => 'En attente de confirmation';

  @override
  String get orderStatusAccepted => 'Acceptée';

  @override
  String get orderStatusPreparing => 'En préparation';

  @override
  String get orderStatusReady => 'Prête';

  @override
  String get orderStatusSearchingCourier => 'Recherche d\'un livreur';

  @override
  String get orderStatusCourierAssigned =>
      'Livreur en route vers le restaurant';

  @override
  String get orderStatusCourierToPickup => 'Livreur en route vers le retrait';

  @override
  String get orderStatusPickedUp => 'Récupérée';

  @override
  String get orderStatusInTransit => 'En route';

  @override
  String get orderStatusDelivered => 'Livrée';

  @override
  String get orderStatusRejected => 'Refusée';

  @override
  String get orderStatusCancelled => 'Annulée';

  @override
  String get orderStatusFailed => 'Échec de livraison';

  @override
  String get homeSearchHint => 'Rechercher un restaurant ou une cuisine';

  @override
  String get homeAllCuisines => 'Tous';

  @override
  String get homeNoMatch => 'Aucun restaurant ne correspond à votre recherche.';

  @override
  String get navHome => 'Accueil';

  @override
  String get navOrders => 'Commandes';

  @override
  String get navAccount => 'Profil';

  @override
  String get navPayments => 'Paiements';

  @override
  String get notificationsTooltip => 'Notifications';

  @override
  String orderStep(int step, int total) {
    return 'Étape $step sur $total';
  }

  @override
  String get newOrderFood => 'Commander un repas';

  @override
  String get paymentsTitle => 'Paiements';

  @override
  String get paymentsMethods => 'Moyens de paiement';

  @override
  String get paymentsHistory => 'Historique';

  @override
  String get paymentsEmpty => 'Aucun paiement pour le moment';

  @override
  String get paymentsEmptyBody =>
      'Vos paiements de commandes apparaîtront ici.';

  @override
  String get paymentDue => 'À payer à la livraison';

  @override
  String get paymentDone => 'Payé';

  @override
  String get paymentNone => 'Non facturé';

  @override
  String get ordersNewEmptyBody =>
      'Elles apparaissent ici en direct, avec une alerte.';

  @override
  String ordersTodayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commandes aujourd\'hui',
      one: '1 commande aujourd\'hui',
      zero: 'Aucune commande aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String get parcelTitle => 'Envoyer un colis';

  @override
  String get parcelStepPickup => 'Départ';

  @override
  String get parcelStepPickupBody => 'D\'où part le colis ?';

  @override
  String get parcelStepDropoff => 'Arrivée';

  @override
  String get parcelStepDropoffBody => 'Où faut-il le livrer ?';

  @override
  String get parcelStepDetails => 'Le colis';

  @override
  String get parcelStepDetailsBody => 'Le destinataire et le contenu.';

  @override
  String get parcelStepSummary => 'Récapitulatif';

  @override
  String get parcelStepSummaryBody => 'Vérifiez avant de confirmer.';

  @override
  String get parcelOtherPoint => 'Autre point sur la carte';

  @override
  String get parcelRecipientName => 'Nom du destinataire';

  @override
  String get parcelRecipientPhone => 'Téléphone du destinataire';

  @override
  String get parcelType => 'Type de colis';

  @override
  String get parcelDescription => 'Que contient le colis ?';

  @override
  String get parcelRulesAccept =>
      'Mon colis respecte la liste des objets autorisés';

  @override
  String get parcelRulesView => 'Voir la liste';

  @override
  String get parcelRulesTitle => 'Objets interdits';

  @override
  String get parcelRulesBody =>
      '• Argent liquide, bijoux et objets de valeur\n• Armes, munitions, produits explosifs ou inflammables\n• Drogues et médicaments sans ordonnance\n• Animaux vivants\n• Aliments périssables mal emballés\n• Tout objet illégal en Côte d\'Ivoire';

  @override
  String get parcelRulesRequired => 'Cochez la case pour continuer.';

  @override
  String get parcelDistance => 'Distance de référence';

  @override
  String parcelDistanceValue(String km) {
    return '$km km';
  }

  @override
  String get parcelPayCash => 'À payer au livreur à la récupération';

  @override
  String get parcelPaymentCash => 'Espèces';

  @override
  String get parcelCancelBody =>
      'Votre colis n\'a pas encore été récupéré : rien ne vous sera facturé.';

  @override
  String get parcelCancelPaidBody =>
      'Votre colis n\'a pas encore été récupéré : votre paiement vous sera remboursé intégralement.';

  @override
  String parcelConfirm(String total) {
    return 'Confirmer · $total';
  }

  @override
  String parcelOrderTitle(String district) {
    return 'Colis vers $district';
  }

  @override
  String get failureDifferentZones =>
      'Les livraisons entre villes ne sont pas disponibles.';

  @override
  String get failureSameLocation =>
      'Le point d\'arrivée est trop proche du départ : déplacez l\'épingle sur la carte.';

  @override
  String get failureRulesNotAccepted =>
      'Confirmez que votre colis respecte la liste des objets autorisés.';

  @override
  String get failureInvalidRecipient => 'Numéro du destinataire invalide.';

  @override
  String get failureInvalidAddress =>
      'Quartier et point de repère sont obligatoires.';

  @override
  String get failureAlreadyPickedUp =>
      'Le colis a déjà été récupéré. Contactez le support.';

  @override
  String get deliveryCodeTitle => 'Code de livraison';

  @override
  String get deliveryCodeFoodBody => 'À donner au livreur à la livraison.';

  @override
  String get deliveryCodeParcelBody =>
      'À transmettre au destinataire : il le donnera au livreur.';

  @override
  String get deliveryCodeShare => 'Partager au destinataire';

  @override
  String get shareWhatsApp => 'WhatsApp';

  @override
  String get shareSms => 'SMS';

  @override
  String deliveryCodeMessage(
    String number,
    String from,
    String to,
    String code,
  ) {
    return 'Tchopi : un colis arrive pour vous ($number), de $from à $to. Code à donner au livreur : $code.';
  }

  @override
  String get orderParcelTitle => 'Colis';

  @override
  String get orderPickupTitle => 'Départ';

  @override
  String get orderDropoffTitle => 'Arrivée';

  @override
  String get orderRecipient => 'Destinataire';

  @override
  String get failureNoCourier =>
      'Aucun livreur disponible pour le moment. Réessayez dans quelques minutes.';

  @override
  String get failureCourierNotApproved =>
      'Votre compte livreur doit être approuvé pour passer en ligne.';

  @override
  String get failureMissionInProgress =>
      'Terminez votre mission avant de passer hors ligne.';

  @override
  String get failureCourierOffline =>
      'Vous êtes hors ligne : passez en ligne pour partager votre position.';

  @override
  String get failureOfferUnavailable => 'Cette mission n\'est plus disponible.';

  @override
  String get failureCourierBusy =>
      'Ce livreur vient d\'accepter une autre mission.';

  @override
  String get failureCourierUnavailable => 'Ce livreur n\'est plus en ligne.';

  @override
  String get courierOnline => 'En ligne';

  @override
  String get courierOffline => 'Hors ligne';

  @override
  String get courierOnlineBody =>
      'Vous recevez des missions autour de vous. Votre position est partagée tant que vous êtes en ligne.';

  @override
  String get courierOfflineBody =>
      'Passez en ligne pour recevoir des missions.';

  @override
  String get courierLocationTitle => 'Partager votre position';

  @override
  String get courierLocationBody =>
      'En ligne, votre position sert uniquement à vous proposer les missions les plus proches. Elle n\'est plus partagée dès que vous passez hors ligne.';

  @override
  String get courierLocationDenied =>
      'La localisation est nécessaire pour recevoir des missions.';

  @override
  String get courierGpsOff => 'Activez le GPS pour passer en ligne.';

  @override
  String get courierOpenSettings => 'Ouvrir les réglages';

  @override
  String get courierNotificationTitle => 'Vous êtes en ligne';

  @override
  String get courierNotificationText =>
      'Votre position est partagée pour recevoir des missions.';

  @override
  String get courierWaitingTitle => 'En attente d\'une mission';

  @override
  String get courierWaitingBody =>
      'Restez en ligne : chaque nouvelle demande s\'affiche en plein écran.';

  @override
  String get courierMissionTitle => 'Mission en cours';

  @override
  String courierMissionEarning(String amount) {
    return 'Gain $amount';
  }

  @override
  String get offerFood => 'Nouvelle mission · Repas';

  @override
  String get offerParcel => 'Nouvelle mission · Colis';

  @override
  String offerTotalDistance(String km) {
    return '$km km au total';
  }

  @override
  String get offerSeconds => 'secondes';

  @override
  String get offerEarning => 'Votre gain';

  @override
  String offerPickup(String name) {
    return 'Retrait · $name';
  }

  @override
  String offerDropoff(String name) {
    return 'Livraison · $name';
  }

  @override
  String offerCash(String amount) {
    return 'Espèces à encaisser · $amount';
  }

  @override
  String get offerAccept => 'Accepter';

  @override
  String get courierAvailableTitle => 'Commandes à récupérer';

  @override
  String courierOfferLine(String km, String district) {
    return 'À $km km · vers $district';
  }

  @override
  String get offerDecline => 'Refuser';

  @override
  String get offerAcceptedTitle => 'Mission acceptée';

  @override
  String offerAcceptedBody(String place, String km) {
    return 'Direction $place, à $km km. Le client est prévenu.';
  }

  @override
  String get offerExpiredTitle => 'Offre expirée';

  @override
  String get offerDeclinedTitle => 'Offre refusée';

  @override
  String get offerDeclinedBody =>
      'Elle reste proposée aux autres livreurs. Restez en ligne pour la prochaine.';

  @override
  String get orderCourierTitle => 'Votre livreur';

  @override
  String get orderCourierCall => 'Appeler';

  @override
  String get dispatchAlertTitle => 'Nous cherchons encore un livreur';

  @override
  String get dispatchAlertBody =>
      'Aucun livreur n\'est disponible pour l\'instant. Vous pouvez continuer d\'attendre ou annuler sans frais.';

  @override
  String get dispatchKeepWaiting => 'Continuer d\'attendre';

  @override
  String get eventCourierAssigned => 'Livreur attribué';

  @override
  String get eventCourierReleased => 'Livreur retiré';

  @override
  String get eventDispatchAlert => 'Alerte : toujours sans livreur';

  @override
  String get orderNoCourier => 'Aucun livreur disponible';

  @override
  String get noCourierYet =>
      'Aucun livreur en ligne pour l\'instant : vous pouvez commander, un livreur prendra votre commande dès qu\'il sera disponible.';

  @override
  String get adminSupervision => 'Commandes à traiter';

  @override
  String get adminSettings => 'Paramètres';

  @override
  String get supervisionAll => 'Tous';

  @override
  String supervisionAlertNoCourier(int count) {
    return 'Sans livreur : $count';
  }

  @override
  String supervisionAlertRestaurant(int count) {
    return 'Restaurant sans réponse : $count';
  }

  @override
  String get supervisionEmpty => 'Aucune commande à traiter';

  @override
  String get supervisionEmptyBody =>
      'Seules les commandes qui demandent votre intervention apparaissent ici : sans livreur, restaurant sans réponse, code bloqué ou problème signalé.';

  @override
  String get adminOrderCustomer => 'Client';

  @override
  String get adminOrderCourier => 'Livreur';

  @override
  String get adminOrderNoCourier => 'Aucun livreur attribué';

  @override
  String get adminAssign => 'Attribuer un livreur';

  @override
  String get adminReassign => 'Changer de livreur';

  @override
  String get assignTitle => 'Livreurs en ligne';

  @override
  String get assignEmpty => 'Aucun livreur en ligne dans la zone.';

  @override
  String get candidateBusy => 'En mission';

  @override
  String get candidateOffer => 'Offre en cours';

  @override
  String get candidateFree => 'Disponible';

  @override
  String candidateDetails(String distance, String age) {
    return '$distance km · position il y a $age';
  }

  @override
  String get assignReason => 'Motif de l\'attribution';

  @override
  String get assignDone => 'Livreur attribué.';

  @override
  String get adminCancelReason => 'Motif de l\'annulation';

  @override
  String get actorCustomer => 'Client';

  @override
  String get actorRestaurant => 'Restaurant';

  @override
  String get actorCourier => 'Livreur';

  @override
  String get actorAdmin => 'Admin';

  @override
  String get actorSystem => 'Système';

  @override
  String get settingsDelaysTitle => 'Délais';

  @override
  String get settingsOfferTimeout => 'Délai d\'une offre (secondes)';

  @override
  String get settingsRestaurantTimeout =>
      'Délai de réponse du restaurant (minutes)';

  @override
  String get settingsPaymentTimeout => 'Expiration d\'un paiement (minutes)';

  @override
  String get settingsDispatchAlert =>
      'Alerte au restaurant sans livreur (minutes)';

  @override
  String get settingsDispatchCancel =>
      'Annulation d\'un colis sans livreur (minutes)';

  @override
  String get settingsSupportTitle => 'Support';

  @override
  String get settingsSupportPhone => 'Numéro du support';

  @override
  String settingsRange(int min, int max) {
    return 'Entre $min et $max.';
  }

  @override
  String get settingsCancelAfterAlert =>
      'L\'annulation doit venir après l\'alerte.';

  @override
  String get settingsSaved =>
      'Paramètres enregistrés : ils s\'appliquent aux nouvelles commandes.';

  @override
  String get courierOpenDashboard => 'Recevoir des missions';

  @override
  String get adminOrderCourierEarning => 'Rémunération du livreur';

  @override
  String get adminOrderPlatform => 'Part de la plateforme';

  @override
  String get adminOrderAmounts => 'Montants';

  @override
  String get supervisionAllStatuses => 'Tous les statuts';

  @override
  String get supervisionAllZones => 'Toutes les zones';

  @override
  String get failureSessionExpired =>
      'Votre session a expiré ou ce compte n\'existe plus. Reconnectez-vous pour continuer.';

  @override
  String get accountSignInAgain => 'Se reconnecter';

  @override
  String get failureNotReady =>
      'Le restaurant n\'a pas encore indiqué que la commande est prête.';

  @override
  String get failureCashConfirmation =>
      'Confirmez d\'abord l\'encaissement auprès de l\'expéditeur.';

  @override
  String get failureNoCourierAssigned =>
      'Aucun livreur n\'est encore attribué à cette commande.';

  @override
  String get missionStepPickup => 'Aller au retrait';

  @override
  String get missionStepDeliver => 'Livrer';

  @override
  String get missionPickupTitle => 'Retrait';

  @override
  String get missionDropoffTitle => 'Livraison';

  @override
  String get missionCall => 'Appeler';

  @override
  String get missionRoute => 'Itinéraire';

  @override
  String get missionNavigate => 'Ouvrir la navigation';

  @override
  String get missionGoogleMaps => 'Google Maps';

  @override
  String get missionWaze => 'Waze';

  @override
  String get missionContents => 'Contenu';

  @override
  String missionCashToCollect(String amount) {
    return 'À encaisser : $amount';
  }

  @override
  String get missionPickedUp => 'Commande récupérée';

  @override
  String missionCashFromSenderTitle(String amount) {
    return 'Encaisser $amount';
  }

  @override
  String get missionCashFromSenderBody =>
      'L\'expéditeur paie la livraison maintenant, en espèces.';

  @override
  String missionCashFromSender(String amount) {
    return 'J\'ai reçu $amount';
  }

  @override
  String get missionStart => 'Je pars livrer';

  @override
  String get missionEnterCode => 'Arrivé — saisir le code';

  @override
  String get missionRelease => 'Abandonner la mission';

  @override
  String get missionReleaseReason => 'Motif de l\'abandon';

  @override
  String get missionCancelledTitle => 'Mission annulée';

  @override
  String get missionCancelledBody =>
      'La commande a été annulée. Vous êtes de nouveau disponible pour d\'autres missions.';

  @override
  String get missionOpen => 'Ouvrir la mission';

  @override
  String get codeTitle => 'Demandez le code au destinataire';

  @override
  String codeAttemptsLeft(int count) {
    return 'Code incorrect : encore $count essai(s).';
  }

  @override
  String get codeLocked =>
      'Saisie bloquée après trop d\'erreurs. Contactez le support.';

  @override
  String get codeValidate => 'Valider';

  @override
  String get codeNoCode =>
      'Le destinataire n\'a pas de code ? Appeler le support';

  @override
  String cashCollectTitle(String amount) {
    return 'Encaissez $amount';
  }

  @override
  String get cashCollectBody => 'Le client paie maintenant, en espèces.';

  @override
  String cashCollectButton(String amount) {
    return 'J\'ai reçu $amount';
  }

  @override
  String get deliveryDoneTitle => 'Livraison terminée';

  @override
  String deliveryDoneBody(String amount) {
    return '+$amount pour cette mission.';
  }

  @override
  String get problemTitle => 'Un problème ?';

  @override
  String get problemCustomerUnreachable => 'Client injoignable';

  @override
  String get problemAddressNotFound => 'Adresse introuvable';

  @override
  String get problemRecipientAbsent => 'Destinataire absent';

  @override
  String get problemOther => 'Autre';

  @override
  String get problemComment => 'Précisez le problème';

  @override
  String get problemReport => 'Signaler à l\'équipe';

  @override
  String get problemReported => 'Problème signalé à l\'équipe.';

  @override
  String get problemCallCustomer => 'Appeler le client';

  @override
  String get problemCallSupport => 'Appeler le support';

  @override
  String get problemDeclareFailure => 'Déclarer l\'échec de livraison';

  @override
  String get problemFailureReason => 'Motif de l\'échec';

  @override
  String get kpiEarnings => 'Gains du jour';

  @override
  String get kpiDeliveries => 'Missions livrées';

  @override
  String get kpiCash => 'Espèces à reverser';

  @override
  String get declinedTitle => 'Offres refusées';

  @override
  String get declinedEmpty => 'Aucune offre refusée ces 7 derniers jours';

  @override
  String get declinedReconsider => 'Revenir sur mon refus';

  @override
  String get declinedTaken =>
      'Plus disponible : un autre livreur l\'a prise, ou elle est terminée.';

  @override
  String get declinedReopened =>
      'Offre de nouveau proposée : acceptez-la depuis l\'accueil.';

  @override
  String historyDeclinedCount(int count) {
    return '$count refusée(s)';
  }

  @override
  String get courierTabHome => 'Accueil';

  @override
  String get courierTabDeclined => 'Refusées';

  @override
  String get courierTabProfile => 'Mon dossier';

  @override
  String get courierReadyTitle => 'Prêt à livrer ?';

  @override
  String get courierReadyBody =>
      'Touchez la carte ci-dessus pour passer en ligne et recevoir des missions.';

  @override
  String get courierTodayTitle => 'Aujourd\'hui';

  @override
  String get courierHistory => 'Historique';

  @override
  String get historyTitle => 'Historique et gains';

  @override
  String get historyToday => 'Aujourd\'hui';

  @override
  String get historyWeek => '7 derniers jours';

  @override
  String get historyEmpty => 'Vos missions apparaîtront ici';

  @override
  String get restaurantHandover => 'Remise au livreur';

  @override
  String get affiliatedTitle => 'Livreurs affiliés';

  @override
  String get affiliatedHint =>
      'Ils reçoivent les commandes prêtes de ce restaurant. Sans livreur affilié, les livreurs de sa zone les reçoivent.';

  @override
  String get affiliatedEmpty => 'Aucun livreur validé pour l\'instant.';

  @override
  String get restaurantWaitingLong =>
      'Toujours sans livreur : l\'équipe est prévenue et la commande reste proposée.';

  @override
  String restaurantCourier(String name) {
    return 'Livreur : $name';
  }

  @override
  String restaurantOrderDelivered(String number) {
    return 'Commande $number livrée au client.';
  }

  @override
  String get adminConfirmWithoutCode => 'Confirmer la livraison sans code';

  @override
  String get adminConfirmReason => 'Motif de la confirmation';

  @override
  String get adminDelivered => 'Livraison confirmée.';

  @override
  String get adminPaymentPaid => 'Payée';

  @override
  String get adminPaymentUnpaid => 'Non encaissée';

  @override
  String supervisionAlertCodeLocked(int count) {
    return 'Code bloqué : $count';
  }

  @override
  String supervisionAlertProblem(int count) {
    return 'Problème signalé : $count';
  }

  @override
  String get eventCodeFailed => 'Code incorrect';

  @override
  String get eventCodeLocked => 'Code bloqué';

  @override
  String get eventProblemReported => 'Problème signalé';

  @override
  String get eventCourierChanged =>
      'Votre livreur a dû annuler, nous en cherchons un autre';

  @override
  String get missionFailedBody =>
      'L\'équipe est prévenue et décide de la suite avec le client.';

  @override
  String get pushReminder =>
      'Notifications désactivées : vous ne serez pas prévenu des étapes de la commande.';

  @override
  String get pushReminderAction => 'Activer';

  @override
  String trackingEta(int minutes) {
    return 'Arrivée estimée : environ $minutes min';
  }

  @override
  String trackingEtaUnavailable(String age) {
    return 'Position il y a $age · estimation indisponible';
  }

  @override
  String get trackingConnectionLost => 'Connexion perdue — reconnexion…';

  @override
  String get txPending => 'En attente';

  @override
  String get txSucceeded => 'Réussie';

  @override
  String get txFailed => 'Échouée';

  @override
  String get txCancelled => 'Annulée';

  @override
  String get txRefunded => 'Remboursée';

  @override
  String get txDeliveredUnpaid => 'Livrée · non encaissée';

  @override
  String get txEmpty => 'Aucune transaction pour l\'instant.';

  @override
  String get paymentNoneAvailable =>
      'Aucun moyen de paiement n\'est disponible pour le moment.';

  @override
  String get failureAmountExceedsDue =>
      'Le montant dépasse les espèces dues par ce livreur.';

  @override
  String get adminTransactions => 'Transactions et espèces';

  @override
  String get adminTabTransactions => 'Transactions';

  @override
  String get adminTabCash => 'Espèces';

  @override
  String cashCollectedLabel(String amount) {
    return 'Encaissé : $amount';
  }

  @override
  String cashRemittedLabel(String amount) {
    return 'Versé : $amount';
  }

  @override
  String get cashDueLabel => 'Dû';

  @override
  String get cashRecord => 'Enregistrer un versement';

  @override
  String get cashAmount => 'Montant versé (FCFA)';

  @override
  String get cashReference => 'Référence (reçu, note)';

  @override
  String get cashRecorded => 'Versement enregistré.';

  @override
  String get cashEmpty => 'Aucune espèce encaissée pour l\'instant.';

  @override
  String get cashHistory => 'Encaissements et versements';

  @override
  String cashEntryCollected(String number) {
    return 'Encaissement $number';
  }

  @override
  String get cashEntryRemitted => 'Versement';

  @override
  String get settingsPaymentsTitle => 'Moyens de paiement';

  @override
  String get payUnpaid => 'À payer';

  @override
  String get payPaid => 'Payée';

  @override
  String get payRefundPending => 'Remboursement en cours';

  @override
  String get payRefunded => 'Remboursée';

  @override
  String get eventRefundPending => 'Remboursement en cours';

  @override
  String get eventRefunded => 'Remboursement effectué';

  @override
  String get receiptTitle => 'Reçu';

  @override
  String get receiptShare => 'Partager le reçu';

  @override
  String get receiptCopy => 'Copier';

  @override
  String get receiptCopied => 'Reçu copié.';

  @override
  String get receiptView => 'Voir le reçu';

  @override
  String get filterAll => 'Tout';

  @override
  String get filterAnyPeriod => 'Toute période';

  @override
  String get filterAnyMethod => 'Tous les moyens';

  @override
  String get filterSucceeded => 'Réussies';

  @override
  String get filterRefunds => 'Remboursements';

  @override
  String get dayToday => 'Aujourd\'hui';

  @override
  String get dayYesterday => 'Hier';

  @override
  String get txOrder => 'Commande';

  @override
  String get txAmount => 'Montant';

  @override
  String get txMethod => 'Moyen de paiement';

  @override
  String get txDate => 'Date';

  @override
  String get txStatus => 'Statut';

  @override
  String get txReference => 'Référence';

  @override
  String get txRefundPending => 'À rembourser';

  @override
  String get adminRequestRefund => 'Rembourser le client';

  @override
  String get adminRefundReason => 'Motif du remboursement';

  @override
  String get adminMarkRefunded => 'Marquer remboursée';

  @override
  String get adminRefundReference => 'Référence du remboursement';

  @override
  String get adminRefundRequested => 'Remboursement à effectuer.';

  @override
  String get adminRefunded => 'Remboursement enregistré.';

  @override
  String get adminDashboard => 'Tableau de bord';

  @override
  String get periodDay => 'Aujourd\'hui';

  @override
  String get periodWeek => '7 jours';

  @override
  String get periodMonth => '30 jours';

  @override
  String get statOrders => 'Commandes';

  @override
  String get statRevenue => 'Chiffre d\'affaires';

  @override
  String get statFees => 'Frais de livraison';

  @override
  String get statCommissions => 'Commissions';

  @override
  String get statCourierEarnings => 'Rémunération des livreurs';

  @override
  String get statPlatform => 'Part de la plateforme';

  @override
  String get statCash => 'Espèces à rapprocher';

  @override
  String get statRefunds => 'Remboursements à effectuer';

  @override
  String get statCouriersOnline => 'Livreurs en ligne';

  @override
  String get statByStatus => 'Par statut';

  @override
  String get statByType => 'Par type';

  @override
  String get statDeliveredOnly =>
      'Montants des commandes livrées sur la période.';

  @override
  String receiptText(
    String number,
    String date,
    String lines,
    String total,
    String method,
    String status,
  ) {
    return 'Tchopi · Reçu $number\n$date\n$lines\nTotal : $total\nPaiement : $method · $status';
  }
}
