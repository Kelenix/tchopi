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
      'Vos plats et vos colis, livrés dans tout Abidjan.';

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
  String get fieldBaseFee => 'Base (F)';

  @override
  String get fieldPerKm => 'Prix par km (F)';

  @override
  String get fieldMinFee => 'Plancher (F)';

  @override
  String get fieldMaxFee => 'Plafond (F)';

  @override
  String get fieldDetour => 'Coefficient de détour';

  @override
  String get fieldRounding => 'Arrondi (F)';

  @override
  String get fieldCourierBase => 'Livreur : fixe (F)';

  @override
  String get fieldCourierPerKm => 'Livreur : par km (F)';

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
  String get courierProfileEditTitle => 'Mon profil livreur';

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
      'Votre compte est validé. Vous pourrez passer en ligne et recevoir des missions dès l\'ouverture des missions dans l\'app.';

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
  String get spaceAdmin => 'Administration';

  @override
  String get spaceAdminBody => 'Zones et tarifs, livreurs, utilisateurs.';

  @override
  String get spaceBecomeCourier => 'Devenir livreur';

  @override
  String get spaceBecomeCourierBody =>
      'Livrez à Abidjan à votre rythme. Votre profil est validé par l\'équipe.';

  @override
  String get spaceRestaurant => 'Restaurant';

  @override
  String get spaceRestaurantBody =>
      'Mon menu, mes horaires, puis les commandes reçues.';

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
  String get homeHeadline => 'Qu\'est-ce qui vous ferait plaisir ?';

  @override
  String get homeServiceFood => 'Repas';

  @override
  String get homeServiceFoodBody => 'Les restaurants d\'Abidjan';

  @override
  String get homeServiceParcel => 'Colis';

  @override
  String get homeServiceParcelBody => 'Un envoi en ville';

  @override
  String get homeSoon => 'Bientôt';

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
  String get restaurantOrderSoon => 'La commande en ligne ouvre très bientôt.';

  @override
  String get menuOther => 'Autres';

  @override
  String get factPrep => 'Préparation';

  @override
  String get factNow => 'Maintenant';
}
