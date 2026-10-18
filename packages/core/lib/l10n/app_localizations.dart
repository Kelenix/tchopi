import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('fr')];

  /// Nom de l'app (provisoire), affiché en logo texte.
  ///
  /// In fr, this message translates to:
  /// **'tchopi'**
  String get appBrand;

  /// No description provided for @welcomeClientHeadline.
  ///
  /// In fr, this message translates to:
  /// **'Vos plats et vos colis, livrés dans tout Abidjan.'**
  String get welcomeClientHeadline;

  /// No description provided for @welcomeClientSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Payez en Mobile Money, par carte ou en espèces.'**
  String get welcomeClientSubtitle;

  /// No description provided for @welcomeCourierHeadline.
  ///
  /// In fr, this message translates to:
  /// **'Livrez à Abidjan, à votre rythme.'**
  String get welcomeCourierHeadline;

  /// No description provided for @welcomeCourierSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Passez en ligne quand vous voulez et suivez vos gains au jour le jour.'**
  String get welcomeCourierSubtitle;

  /// No description provided for @welcomeBackofficeHeadline.
  ///
  /// In fr, this message translates to:
  /// **'L\'espace des restaurants partenaires et de l\'équipe.'**
  String get welcomeBackofficeHeadline;

  /// No description provided for @welcomeBackofficeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Recevez les commandes, tenez votre menu à jour, supervisez les livraisons.'**
  String get welcomeBackofficeSubtitle;

  /// No description provided for @featureRestaurants.
  ///
  /// In fr, this message translates to:
  /// **'Restaurants du quartier'**
  String get featureRestaurants;

  /// No description provided for @featureParcels.
  ///
  /// In fr, this message translates to:
  /// **'Colis d\'un point à un autre'**
  String get featureParcels;

  /// No description provided for @featureTracking.
  ///
  /// In fr, this message translates to:
  /// **'Suivi en direct'**
  String get featureTracking;

  /// No description provided for @featureNearbyMissions.
  ///
  /// In fr, this message translates to:
  /// **'Missions près de vous'**
  String get featureNearbyMissions;

  /// No description provided for @featureEarnings.
  ///
  /// In fr, this message translates to:
  /// **'Gains du jour visibles'**
  String get featureEarnings;

  /// No description provided for @featureDirections.
  ///
  /// In fr, this message translates to:
  /// **'Itinéraire en un geste'**
  String get featureDirections;

  /// No description provided for @featureLiveOrders.
  ///
  /// In fr, this message translates to:
  /// **'Commandes en temps réel'**
  String get featureLiveOrders;

  /// No description provided for @featureMenu.
  ///
  /// In fr, this message translates to:
  /// **'Menu toujours à jour'**
  String get featureMenu;

  /// No description provided for @featureSupervision.
  ///
  /// In fr, this message translates to:
  /// **'Supervision des livraisons'**
  String get featureSupervision;

  /// No description provided for @actionCreateAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get actionCreateAccount;

  /// No description provided for @actionSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get actionSignIn;

  /// No description provided for @actionContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get actionContinue;

  /// No description provided for @actionSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get actionSave;

  /// No description provided for @actionRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get actionRetry;

  /// No description provided for @actionCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get actionCancel;

  /// No description provided for @actionBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get actionBack;

  /// No description provided for @fieldEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get fieldPhone;

  /// No description provided for @fieldPhoneHint.
  ///
  /// In fr, this message translates to:
  /// **'+225 07 00 00 00 00'**
  String get fieldPhoneHint;

  /// No description provided for @fieldIdentifier.
  ///
  /// In fr, this message translates to:
  /// **'Email ou téléphone'**
  String get fieldIdentifier;

  /// No description provided for @fieldPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get fieldPassword;

  /// No description provided for @fieldNewPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get fieldNewPassword;

  /// No description provided for @fieldPasswordRule.
  ///
  /// In fr, this message translates to:
  /// **'8 caractères minimum, avec des lettres et des chiffres.'**
  String get fieldPasswordRule;

  /// No description provided for @fieldFirstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get fieldFirstName;

  /// No description provided for @fieldLastName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get fieldLastName;

  /// No description provided for @fieldCity.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get fieldCity;

  /// No description provided for @showPassword.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le mot de passe'**
  String get hidePassword;

  /// No description provided for @errorEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email invalide.'**
  String get errorEmail;

  /// No description provided for @errorPhone.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de mobile invalide.'**
  String get errorPhone;

  /// No description provided for @errorIdentifier.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez un email ou un numéro de mobile valide.'**
  String get errorIdentifier;

  /// No description provided for @errorPassword.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit faire 8 caractères minimum, avec des lettres et des chiffres.'**
  String get errorPassword;

  /// No description provided for @errorRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est obligatoire.'**
  String get errorRequired;

  /// No description provided for @signUpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer votre compte'**
  String get signUpTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Un code de confirmation vous sera envoyé.'**
  String get signUpSubtitle;

  /// No description provided for @signUpHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai déjà un compte'**
  String get signUpHaveAccount;

  /// No description provided for @signInTitle.
  ///
  /// In fr, this message translates to:
  /// **'Content de vous revoir'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous avec votre email ou votre numéro.'**
  String get signInSubtitle;

  /// No description provided for @signInForgot.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get signInForgot;

  /// No description provided for @signInNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ? Créer un compte'**
  String get signInNoAccount;

  /// No description provided for @verifyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez le code'**
  String get verifyTitle;

  /// No description provided for @verifySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Un code à 6 chiffres a été envoyé à {destination}.'**
  String verifySubtitle(String destination);

  /// No description provided for @verifyResend.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get verifyResend;

  /// No description provided for @verifyResendIn.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code dans {seconds} s'**
  String verifyResendIn(int seconds);

  /// No description provided for @verifyResent.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau code envoyé.'**
  String get verifyResent;

  /// No description provided for @verifyChangeDestination.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'email ou le numéro'**
  String get verifyChangeDestination;

  /// No description provided for @verifyMissing.
  ///
  /// In fr, this message translates to:
  /// **'Cette vérification a expiré. Recommencez depuis la connexion.'**
  String get verifyMissing;

  /// No description provided for @resetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get resetTitle;

  /// No description provided for @resetSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Recevez un code pour choisir un nouveau mot de passe.'**
  String get resetSubtitle;

  /// No description provided for @resetCodeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Si un compte existe pour {destination}, un code vient d\'être envoyé.'**
  String resetCodeSubtitle(String destination);

  /// No description provided for @resetSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get resetSubmit;

  /// No description provided for @resetDone.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe modifié.'**
  String get resetDone;

  /// No description provided for @profileSetupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Faisons connaissance'**
  String get profileSetupTitle;

  /// No description provided for @profileSetupSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ces informations permettent au livreur de vous joindre.'**
  String get profileSetupSubtitle;

  /// No description provided for @profileEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes informations'**
  String get profileEditTitle;

  /// No description provided for @profileSaved.
  ///
  /// In fr, this message translates to:
  /// **'Informations enregistrées.'**
  String get profileSaved;

  /// No description provided for @accountTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon compte'**
  String get accountTitle;

  /// No description provided for @accountLogin.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant de connexion'**
  String get accountLogin;

  /// No description provided for @accountEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier mes informations'**
  String get accountEdit;

  /// No description provided for @accountChangeLogin.
  ///
  /// In fr, this message translates to:
  /// **'Changer d\'email ou de numéro de connexion'**
  String get accountChangeLogin;

  /// No description provided for @accountSignOut.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get accountSignOut;

  /// No description provided for @accountDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte'**
  String get accountDelete;

  /// No description provided for @accountLicenses.
  ///
  /// In fr, this message translates to:
  /// **'Licences'**
  String get accountLicenses;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter ?'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous devrez vous reconnecter pour commander ou suivre une livraison.'**
  String get signOutConfirmBody;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer votre compte ?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre nom, votre téléphone et vos accès seront effacés. Cette action est définitive. L\'historique des commandes est conservé sans donnée vous identifiant.'**
  String get deleteConfirmBody;

  /// No description provided for @deleteConfirmAction.
  ///
  /// In fr, this message translates to:
  /// **'Oui, supprimer'**
  String get deleteConfirmAction;

  /// No description provided for @loginChangeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Changer d\'identifiant'**
  String get loginChangeTitle;

  /// No description provided for @loginChangeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Un code sera envoyé à la nouvelle adresse ou au nouveau numéro. L\'ancien reste valable tant que le code n\'est pas saisi.'**
  String get loginChangeSubtitle;

  /// No description provided for @loginChangeField.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel email ou numéro'**
  String get loginChangeField;

  /// No description provided for @loginChangeDone.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant de connexion modifié.'**
  String get loginChangeDone;

  /// No description provided for @restrictedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Accès réservé'**
  String get restrictedTitle;

  /// No description provided for @restrictedBody.
  ///
  /// In fr, this message translates to:
  /// **'Cet espace est réservé aux restaurants partenaires et à l\'équipe. Si vous gérez un restaurant partenaire, demandez votre accès à l\'équipe.'**
  String get restrictedBody;

  /// No description provided for @loadingAccount.
  ///
  /// In fr, this message translates to:
  /// **'Chargement de votre compte…'**
  String get loadingAccount;

  /// No description provided for @loadingAccountError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger votre compte.'**
  String get loadingAccountError;

  /// No description provided for @failureNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion internet. Vérifiez votre réseau puis réessayez.'**
  String get failureNetwork;

  /// No description provided for @failureInvalidCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Email, numéro ou mot de passe incorrect.'**
  String get failureInvalidCredentials;

  /// No description provided for @failureUserExists.
  ///
  /// In fr, this message translates to:
  /// **'Un compte existe déjà avec cet identifiant.'**
  String get failureUserExists;

  /// No description provided for @failureCodeInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect ou expiré.'**
  String get failureCodeInvalid;

  /// No description provided for @failureRateLimited.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives. Patientez une minute avant de réessayer.'**
  String get failureRateLimited;

  /// No description provided for @failureWeakPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe trop faible : 8 caractères minimum, avec des lettres et des chiffres.'**
  String get failureWeakPassword;

  /// No description provided for @failureSamePassword.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un mot de passe différent de l\'actuel.'**
  String get failureSamePassword;

  /// No description provided for @failureSuspended.
  ///
  /// In fr, this message translates to:
  /// **'Votre compte est suspendu. Contactez le support.'**
  String get failureSuspended;

  /// No description provided for @failureNotConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Votre compte n\'est pas encore confirmé. Un nouveau code vient d\'être envoyé.'**
  String get failureNotConfirmed;

  /// No description provided for @failureUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessayez dans un instant.'**
  String get failureUnknown;

  /// No description provided for @accountAddresses.
  ///
  /// In fr, this message translates to:
  /// **'Mes adresses'**
  String get accountAddresses;

  /// No description provided for @addressesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes adresses'**
  String get addressesTitle;

  /// No description provided for @addressesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez votre première adresse'**
  String get addressesEmpty;

  /// No description provided for @addressesEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Une position sur la carte, votre quartier et un point de repère suffisent : pas besoin du nom de la rue.'**
  String get addressesEmptyBody;

  /// No description provided for @addressAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une adresse'**
  String get addressAdd;

  /// No description provided for @addressDefault.
  ///
  /// In fr, this message translates to:
  /// **'Par défaut'**
  String get addressDefault;

  /// No description provided for @addressSetDefault.
  ///
  /// In fr, this message translates to:
  /// **'Définir par défaut'**
  String get addressSetDefault;

  /// No description provided for @addressEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get addressEdit;

  /// No description provided for @addressDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get addressDelete;

  /// No description provided for @addressDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette adresse ?'**
  String get addressDeleteTitle;

  /// No description provided for @addressDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'Les commandes déjà passées gardent leur adresse d\'origine.'**
  String get addressDeleteBody;

  /// No description provided for @addressNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle adresse'**
  String get addressNewTitle;

  /// No description provided for @addressEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'adresse'**
  String get addressEditTitle;

  /// No description provided for @addressSaved.
  ///
  /// In fr, this message translates to:
  /// **'Adresse enregistrée.'**
  String get addressSaved;

  /// No description provided for @addressMoveMap.
  ///
  /// In fr, this message translates to:
  /// **'Déplacez la carte pour placer l\'épingle sur votre entrée.'**
  String get addressMoveMap;

  /// No description provided for @addressMyPosition.
  ///
  /// In fr, this message translates to:
  /// **'Ma position'**
  String get addressMyPosition;

  /// No description provided for @mapUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Carte non configurée sur cet appareil. Utilisez « Ma position » pour placer l\'adresse.'**
  String get mapUnavailable;

  /// No description provided for @mapPosition.
  ///
  /// In fr, this message translates to:
  /// **'Position : {lat}, {lng}'**
  String mapPosition(String lat, String lng);

  /// No description provided for @fieldLabel.
  ///
  /// In fr, this message translates to:
  /// **'Libellé'**
  String get fieldLabel;

  /// No description provided for @labelHome.
  ///
  /// In fr, this message translates to:
  /// **'Maison'**
  String get labelHome;

  /// No description provided for @labelWork.
  ///
  /// In fr, this message translates to:
  /// **'Bureau'**
  String get labelWork;

  /// No description provided for @labelOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get labelOther;

  /// No description provided for @fieldDistrict.
  ///
  /// In fr, this message translates to:
  /// **'Quartier'**
  String get fieldDistrict;

  /// No description provided for @fieldLandmark.
  ///
  /// In fr, this message translates to:
  /// **'Point de repère'**
  String get fieldLandmark;

  /// No description provided for @fieldLandmarkHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. derrière la pharmacie centrale'**
  String get fieldLandmarkHint;

  /// No description provided for @fieldInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Instructions (facultatif)'**
  String get fieldInstructions;

  /// No description provided for @fieldInstructionsHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. maison avec portail bleu'**
  String get fieldInstructionsHint;

  /// No description provided for @locationRationaleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser votre position ?'**
  String get locationRationaleTitle;

  /// No description provided for @locationRationaleBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre position sert uniquement à placer l\'adresse sur la carte. Vous pourrez ensuite l\'ajuster.'**
  String get locationRationaleBody;

  /// No description provided for @locationDenied.
  ///
  /// In fr, this message translates to:
  /// **'Localisation refusée : placez l\'épingle sur la carte.'**
  String get locationDenied;

  /// No description provided for @locationDeniedForever.
  ///
  /// In fr, this message translates to:
  /// **'Localisation bloquée. Autorisez-la dans les réglages du téléphone.'**
  String get locationDeniedForever;

  /// No description provided for @locationOpenSettings.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get locationOpenSettings;

  /// No description provided for @locationOff.
  ///
  /// In fr, this message translates to:
  /// **'Activez la localisation (GPS) du téléphone.'**
  String get locationOff;

  /// No description provided for @locationLowAccuracy.
  ///
  /// In fr, this message translates to:
  /// **'Précision faible : ajustez l\'épingle sur la carte.'**
  String get locationLowAccuracy;

  /// No description provided for @failureOutOfZone.
  ///
  /// In fr, this message translates to:
  /// **'Cette adresse est hors de la zone desservie.'**
  String get failureOutOfZone;

  /// No description provided for @failureForbidden.
  ///
  /// In fr, this message translates to:
  /// **'Action réservée aux administrateurs.'**
  String get failureForbidden;

  /// No description provided for @adminZones.
  ///
  /// In fr, this message translates to:
  /// **'Zones et tarifs'**
  String get adminZones;

  /// No description provided for @zonesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune zone pour le moment'**
  String get zonesEmpty;

  /// No description provided for @zoneAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une zone'**
  String get zoneAdd;

  /// No description provided for @zoneNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle zone'**
  String get zoneNewTitle;

  /// No description provided for @zoneEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la zone'**
  String get zoneEditTitle;

  /// No description provided for @zoneActive.
  ///
  /// In fr, this message translates to:
  /// **'Zone active'**
  String get zoneActive;

  /// No description provided for @zoneInactive.
  ///
  /// In fr, this message translates to:
  /// **'Désactivée'**
  String get zoneInactive;

  /// No description provided for @zoneRadius.
  ///
  /// In fr, this message translates to:
  /// **'Rayon {km} km'**
  String zoneRadius(String km);

  /// No description provided for @zoneViewOnMap.
  ///
  /// In fr, this message translates to:
  /// **'Voir le centre sur une carte'**
  String get zoneViewOnMap;

  /// No description provided for @zoneSaved.
  ///
  /// In fr, this message translates to:
  /// **'Zone et tarifs enregistrés.'**
  String get zoneSaved;

  /// No description provided for @fieldZoneName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la zone'**
  String get fieldZoneName;

  /// No description provided for @fieldCenterLat.
  ///
  /// In fr, this message translates to:
  /// **'Latitude du centre'**
  String get fieldCenterLat;

  /// No description provided for @fieldCenterLng.
  ///
  /// In fr, this message translates to:
  /// **'Longitude du centre'**
  String get fieldCenterLng;

  /// No description provided for @fieldRadiusKm.
  ///
  /// In fr, this message translates to:
  /// **'Rayon (km)'**
  String get fieldRadiusKm;

  /// No description provided for @pricingFood.
  ///
  /// In fr, this message translates to:
  /// **'Tarifs repas'**
  String get pricingFood;

  /// No description provided for @pricingParcel.
  ///
  /// In fr, this message translates to:
  /// **'Tarifs colis'**
  String get pricingParcel;

  /// No description provided for @fieldBaseFee.
  ///
  /// In fr, this message translates to:
  /// **'Base (F)'**
  String get fieldBaseFee;

  /// No description provided for @fieldPerKm.
  ///
  /// In fr, this message translates to:
  /// **'Prix par km (F)'**
  String get fieldPerKm;

  /// No description provided for @fieldMinFee.
  ///
  /// In fr, this message translates to:
  /// **'Plancher (F)'**
  String get fieldMinFee;

  /// No description provided for @fieldMaxFee.
  ///
  /// In fr, this message translates to:
  /// **'Plafond (F)'**
  String get fieldMaxFee;

  /// No description provided for @fieldDetour.
  ///
  /// In fr, this message translates to:
  /// **'Coefficient de détour'**
  String get fieldDetour;

  /// No description provided for @fieldRounding.
  ///
  /// In fr, this message translates to:
  /// **'Arrondi (F)'**
  String get fieldRounding;

  /// No description provided for @fieldCourierBase.
  ///
  /// In fr, this message translates to:
  /// **'Livreur : fixe (F)'**
  String get fieldCourierBase;

  /// No description provided for @fieldCourierPerKm.
  ///
  /// In fr, this message translates to:
  /// **'Livreur : par km (F)'**
  String get fieldCourierPerKm;

  /// No description provided for @simulatorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Simulateur'**
  String get simulatorTitle;

  /// No description provided for @simulatorDistance.
  ///
  /// In fr, this message translates to:
  /// **'Distance à vol d\'oiseau (km)'**
  String get simulatorDistance;

  /// No description provided for @simulatorRun.
  ///
  /// In fr, this message translates to:
  /// **'Calculer'**
  String get simulatorRun;

  /// No description provided for @simulatorResult.
  ///
  /// In fr, this message translates to:
  /// **'{distance} km de référence · frais {fee} · livreur {earning}'**
  String simulatorResult(String distance, String fee, String earning);

  /// No description provided for @simulatorSaveFirst.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez la zone pour simuler ses tarifs.'**
  String get simulatorSaveFirst;

  /// No description provided for @errorNumber.
  ///
  /// In fr, this message translates to:
  /// **'Nombre invalide.'**
  String get errorNumber;

  /// No description provided for @errorMinMax.
  ///
  /// In fr, this message translates to:
  /// **'Le plancher doit être inférieur ou égal au plafond.'**
  String get errorMinMax;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
