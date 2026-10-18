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
  String get welcomeCourierHeadline => 'Livrez à Abidjan, à votre rythme.';

  @override
  String get welcomeCourierSubtitle =>
      'Passez en ligne quand vous voulez et suivez vos gains au jour le jour.';

  @override
  String get welcomeBackofficeHeadline =>
      'L\'espace des restaurants partenaires et de l\'équipe.';

  @override
  String get welcomeBackofficeSubtitle =>
      'Recevez les commandes, tenez votre menu à jour, supervisez les livraisons.';

  @override
  String get featureRestaurants => 'Restaurants du quartier';

  @override
  String get featureParcels => 'Colis d\'un point à un autre';

  @override
  String get featureTracking => 'Suivi en direct';

  @override
  String get featureNearbyMissions => 'Missions près de vous';

  @override
  String get featureEarnings => 'Gains du jour visibles';

  @override
  String get featureDirections => 'Itinéraire en un geste';

  @override
  String get featureLiveOrders => 'Commandes en temps réel';

  @override
  String get featureMenu => 'Menu toujours à jour';

  @override
  String get featureSupervision => 'Supervision des livraisons';

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
  String get restrictedTitle => 'Accès réservé';

  @override
  String get restrictedBody =>
      'Cet espace est réservé aux restaurants partenaires et à l\'équipe. Si vous gérez un restaurant partenaire, demandez votre accès à l\'équipe.';

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
}
