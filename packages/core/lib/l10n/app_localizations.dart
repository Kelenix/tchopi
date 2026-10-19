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

  /// No description provided for @courierProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Devenir livreur'**
  String get courierProfileTitle;

  /// No description provided for @courierProfileEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil livreur'**
  String get courierProfileEditTitle;

  /// No description provided for @courierProfileSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ces informations sont vérifiées par l\'équipe avant votre première mission.'**
  String get courierProfileSubtitle;

  /// No description provided for @fieldZone.
  ///
  /// In fr, this message translates to:
  /// **'Zone de travail'**
  String get fieldZone;

  /// No description provided for @fieldVehicle.
  ///
  /// In fr, this message translates to:
  /// **'Moyen de transport'**
  String get fieldVehicle;

  /// No description provided for @vehicleMotorbike.
  ///
  /// In fr, this message translates to:
  /// **'Moto'**
  String get vehicleMotorbike;

  /// No description provided for @vehicleBicycle.
  ///
  /// In fr, this message translates to:
  /// **'Vélo'**
  String get vehicleBicycle;

  /// No description provided for @vehicleCar.
  ///
  /// In fr, this message translates to:
  /// **'Voiture'**
  String get vehicleCar;

  /// No description provided for @vehicleOnFoot.
  ///
  /// In fr, this message translates to:
  /// **'À pied'**
  String get vehicleOnFoot;

  /// No description provided for @fieldPlate.
  ///
  /// In fr, this message translates to:
  /// **'Immatriculation'**
  String get fieldPlate;

  /// No description provided for @fieldPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photo de profil'**
  String get fieldPhoto;

  /// No description provided for @photoHint.
  ///
  /// In fr, this message translates to:
  /// **'Visage bien visible : le client la voit pour vous reconnaître.'**
  String get photoHint;

  /// No description provided for @photoTake.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get photoTake;

  /// No description provided for @photoChoose.
  ///
  /// In fr, this message translates to:
  /// **'Choisir dans la galerie'**
  String get photoChoose;

  /// No description provided for @errorPhotoRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez une photo de profil.'**
  String get errorPhotoRequired;

  /// No description provided for @courierSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Soumettre mon profil'**
  String get courierSubmit;

  /// No description provided for @courierStatusTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon compte livreur'**
  String get courierStatusTitle;

  /// No description provided for @courierPendingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nous vérifions votre profil'**
  String get courierPendingTitle;

  /// No description provided for @courierPendingBody.
  ///
  /// In fr, this message translates to:
  /// **'L\'équipe valide votre profil, généralement sous 48 heures. Revenez ici pour suivre son statut.'**
  String get courierPendingBody;

  /// No description provided for @courierApprovedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Compte approuvé'**
  String get courierApprovedTitle;

  /// No description provided for @courierApprovedBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre compte est validé : passez en ligne depuis l\'accueil pour recevoir des missions.'**
  String get courierApprovedBody;

  /// No description provided for @courierRejectedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil refusé'**
  String get courierRejectedTitle;

  /// No description provided for @courierRejectedBody.
  ///
  /// In fr, this message translates to:
  /// **'Motif : {reason}. Corrigez votre profil puis soumettez-le à nouveau.'**
  String courierRejectedBody(String reason);

  /// No description provided for @courierSuspendedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Compte suspendu'**
  String get courierSuspendedTitle;

  /// No description provided for @courierSuspendedBody.
  ///
  /// In fr, this message translates to:
  /// **'Motif : {reason}. Contactez le support pour en savoir plus.'**
  String courierSuspendedBody(String reason);

  /// No description provided for @courierEditProfile.
  ///
  /// In fr, this message translates to:
  /// **'Modifier mon profil'**
  String get courierEditProfile;

  /// No description provided for @courierRefresh.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get courierRefresh;

  /// No description provided for @failureZoneUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Cette zone n\'est plus desservie. Choisissez-en une autre.'**
  String get failureZoneUnavailable;

  /// No description provided for @failureCourierSuspended.
  ///
  /// In fr, this message translates to:
  /// **'Votre compte livreur est suspendu.'**
  String get failureCourierSuspended;

  /// No description provided for @failureReasonRequired.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez un motif.'**
  String get failureReasonRequired;

  /// No description provided for @failureNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Élément introuvable. Actualisez la liste.'**
  String get failureNotFound;

  /// No description provided for @failureCannotTargetSelf.
  ///
  /// In fr, this message translates to:
  /// **'Vous ne pouvez pas appliquer cette action à votre propre compte.'**
  String get failureCannotTargetSelf;

  /// No description provided for @failureInvalidIdentifier.
  ///
  /// In fr, this message translates to:
  /// **'Email ou numéro invalide.'**
  String get failureInvalidIdentifier;

  /// No description provided for @adminCouriers.
  ///
  /// In fr, this message translates to:
  /// **'Livreurs'**
  String get adminCouriers;

  /// No description provided for @adminUsers.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs'**
  String get adminUsers;

  /// No description provided for @statusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get statusPending;

  /// No description provided for @statusApproved.
  ///
  /// In fr, this message translates to:
  /// **'Approuvés'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In fr, this message translates to:
  /// **'Refusés'**
  String get statusRejected;

  /// No description provided for @statusSuspended.
  ///
  /// In fr, this message translates to:
  /// **'Suspendus'**
  String get statusSuspended;

  /// No description provided for @couriersEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livreur dans cette catégorie'**
  String get couriersEmpty;

  /// No description provided for @courierApprove.
  ///
  /// In fr, this message translates to:
  /// **'Approuver'**
  String get courierApprove;

  /// No description provided for @courierReject.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get courierReject;

  /// No description provided for @courierSuspend.
  ///
  /// In fr, this message translates to:
  /// **'Suspendre'**
  String get courierSuspend;

  /// No description provided for @courierReactivate.
  ///
  /// In fr, this message translates to:
  /// **'Réactiver'**
  String get courierReactivate;

  /// No description provided for @courierDecisionDone.
  ///
  /// In fr, this message translates to:
  /// **'Décision enregistrée.'**
  String get courierDecisionDone;

  /// No description provided for @reasonTitleReject.
  ///
  /// In fr, this message translates to:
  /// **'Motif du refus'**
  String get reasonTitleReject;

  /// No description provided for @reasonTitleSuspend.
  ///
  /// In fr, this message translates to:
  /// **'Motif de la suspension'**
  String get reasonTitleSuspend;

  /// No description provided for @reasonField.
  ///
  /// In fr, this message translates to:
  /// **'Motif (transmis à la personne)'**
  String get reasonField;

  /// No description provided for @usersSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher par nom ou téléphone'**
  String get usersSearch;

  /// No description provided for @usersEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun utilisateur trouvé'**
  String get usersEmpty;

  /// No description provided for @userSuspended.
  ///
  /// In fr, this message translates to:
  /// **'Suspendu'**
  String get userSuspended;

  /// No description provided for @userSuspend.
  ///
  /// In fr, this message translates to:
  /// **'Suspendre le compte'**
  String get userSuspend;

  /// No description provided for @userReactivate.
  ///
  /// In fr, this message translates to:
  /// **'Réactiver le compte'**
  String get userReactivate;

  /// No description provided for @userChangeLogin.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'identifiant de connexion'**
  String get userChangeLogin;

  /// No description provided for @userChangeLoginField.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel email ou numéro'**
  String get userChangeLoginField;

  /// No description provided for @userActionDone.
  ///
  /// In fr, this message translates to:
  /// **'Action enregistrée.'**
  String get userActionDone;

  /// No description provided for @userNoName.
  ///
  /// In fr, this message translates to:
  /// **'Profil incomplet'**
  String get userNoName;

  /// No description provided for @spacesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Changer d\'espace'**
  String get spacesTitle;

  /// No description provided for @spaceCurrent.
  ///
  /// In fr, this message translates to:
  /// **'Espace actuel'**
  String get spaceCurrent;

  /// No description provided for @spaceClient.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get spaceClient;

  /// No description provided for @spaceClientBody.
  ///
  /// In fr, this message translates to:
  /// **'Commander un repas, envoyer un colis, gérer mes adresses.'**
  String get spaceClientBody;

  /// No description provided for @spaceCourier.
  ///
  /// In fr, this message translates to:
  /// **'Livreur'**
  String get spaceCourier;

  /// No description provided for @spaceCourierBody.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil livreur et mes missions.'**
  String get spaceCourierBody;

  /// No description provided for @spaceBecomeCourier.
  ///
  /// In fr, this message translates to:
  /// **'Devenir livreur'**
  String get spaceBecomeCourier;

  /// No description provided for @spaceBecomeCourierBody.
  ///
  /// In fr, this message translates to:
  /// **'Livrez à Abidjan à votre rythme. Votre profil est validé par l\'équipe.'**
  String get spaceBecomeCourierBody;

  /// No description provided for @spaceRestaurant.
  ///
  /// In fr, this message translates to:
  /// **'Restaurant'**
  String get spaceRestaurant;

  /// No description provided for @spaceRestaurantBody.
  ///
  /// In fr, this message translates to:
  /// **'Commandes reçues en direct, menu et horaires.'**
  String get spaceRestaurantBody;

  /// No description provided for @restaurantMenu.
  ///
  /// In fr, this message translates to:
  /// **'Menu'**
  String get restaurantMenu;

  /// No description provided for @restaurantProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil et horaires'**
  String get restaurantProfile;

  /// No description provided for @menuEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez votre premier produit'**
  String get menuEmpty;

  /// No description provided for @menuEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Les clients voient votre menu dès qu\'un produit est disponible.'**
  String get menuEmptyBody;

  /// No description provided for @productAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un produit'**
  String get productAdd;

  /// No description provided for @productNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau produit'**
  String get productNewTitle;

  /// No description provided for @productEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le produit'**
  String get productEditTitle;

  /// No description provided for @fieldProductName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du produit'**
  String get fieldProductName;

  /// No description provided for @fieldDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get fieldDescription;

  /// No description provided for @fieldPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix (F CFA)'**
  String get fieldPrice;

  /// No description provided for @fieldCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get fieldCategory;

  /// No description provided for @categoryNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle catégorie'**
  String get categoryNew;

  /// No description provided for @categoryNone.
  ///
  /// In fr, this message translates to:
  /// **'Sans catégorie'**
  String get categoryNone;

  /// No description provided for @productAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Disponible'**
  String get productAvailable;

  /// No description provided for @productUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Indisponible'**
  String get productUnavailable;

  /// No description provided for @productArchive.
  ///
  /// In fr, this message translates to:
  /// **'Retirer du menu'**
  String get productArchive;

  /// No description provided for @productArchiveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Retirer ce produit du menu ?'**
  String get productArchiveTitle;

  /// No description provided for @productArchiveBody.
  ///
  /// In fr, this message translates to:
  /// **'Il disparaît pour les clients ; les commandes passées le gardent.'**
  String get productArchiveBody;

  /// No description provided for @productSaved.
  ///
  /// In fr, this message translates to:
  /// **'Produit enregistré.'**
  String get productSaved;

  /// No description provided for @productPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photo du produit'**
  String get productPhoto;

  /// No description provided for @photoChange.
  ///
  /// In fr, this message translates to:
  /// **'Changer la photo'**
  String get photoChange;

  /// No description provided for @fieldCategoryName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la catégorie'**
  String get fieldCategoryName;

  /// No description provided for @restaurantOpenNow.
  ///
  /// In fr, this message translates to:
  /// **'Ouvert'**
  String get restaurantOpenNow;

  /// No description provided for @restaurantClosedNow.
  ///
  /// In fr, this message translates to:
  /// **'Fermé'**
  String get restaurantClosedNow;

  /// No description provided for @restaurantTemporarilyClosed.
  ///
  /// In fr, this message translates to:
  /// **'Fermé temporairement'**
  String get restaurantTemporarilyClosed;

  /// No description provided for @restaurantTemporarilyClosedBody.
  ///
  /// In fr, this message translates to:
  /// **'Ferme le restaurant tout de suite, quels que soient les horaires.'**
  String get restaurantTemporarilyClosedBody;

  /// No description provided for @fieldPrepTime.
  ///
  /// In fr, this message translates to:
  /// **'Temps de préparation moyen (min)'**
  String get fieldPrepTime;

  /// No description provided for @fieldRestaurantCategory.
  ///
  /// In fr, this message translates to:
  /// **'Type de cuisine'**
  String get fieldRestaurantCategory;

  /// No description provided for @fieldCommission.
  ///
  /// In fr, this message translates to:
  /// **'Commission (%)'**
  String get fieldCommission;

  /// No description provided for @commissionReadOnly.
  ///
  /// In fr, this message translates to:
  /// **'Commission : {rate} % (fixée par l\'équipe)'**
  String commissionReadOnly(String rate);

  /// No description provided for @coverPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photo de couverture'**
  String get coverPhoto;

  /// No description provided for @openingHours.
  ///
  /// In fr, this message translates to:
  /// **'Horaires d\'ouverture'**
  String get openingHours;

  /// No description provided for @hoursAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une plage'**
  String get hoursAdd;

  /// No description provided for @hoursClosedDay.
  ///
  /// In fr, this message translates to:
  /// **'Fermé'**
  String get hoursClosedDay;

  /// No description provided for @hoursInvalid.
  ///
  /// In fr, this message translates to:
  /// **'L\'heure de fermeture doit suivre l\'heure d\'ouverture.'**
  String get hoursInvalid;

  /// No description provided for @restaurantSaved.
  ///
  /// In fr, this message translates to:
  /// **'Restaurant enregistré.'**
  String get restaurantSaved;

  /// No description provided for @weekday1.
  ///
  /// In fr, this message translates to:
  /// **'Lundi'**
  String get weekday1;

  /// No description provided for @weekday2.
  ///
  /// In fr, this message translates to:
  /// **'Mardi'**
  String get weekday2;

  /// No description provided for @weekday3.
  ///
  /// In fr, this message translates to:
  /// **'Mercredi'**
  String get weekday3;

  /// No description provided for @weekday4.
  ///
  /// In fr, this message translates to:
  /// **'Jeudi'**
  String get weekday4;

  /// No description provided for @weekday5.
  ///
  /// In fr, this message translates to:
  /// **'Vendredi'**
  String get weekday5;

  /// No description provided for @weekday6.
  ///
  /// In fr, this message translates to:
  /// **'Samedi'**
  String get weekday6;

  /// No description provided for @weekday7.
  ///
  /// In fr, this message translates to:
  /// **'Dimanche'**
  String get weekday7;

  /// No description provided for @adminRestaurants.
  ///
  /// In fr, this message translates to:
  /// **'Restaurants'**
  String get adminRestaurants;

  /// No description provided for @restaurantsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun restaurant pour le moment'**
  String get restaurantsEmpty;

  /// No description provided for @restaurantAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un restaurant'**
  String get restaurantAdd;

  /// No description provided for @restaurantNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau restaurant'**
  String get restaurantNewTitle;

  /// No description provided for @restaurantEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le restaurant'**
  String get restaurantEditTitle;

  /// No description provided for @fieldRestaurantName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du restaurant'**
  String get fieldRestaurantName;

  /// No description provided for @restaurantActive.
  ///
  /// In fr, this message translates to:
  /// **'Visible par les clients'**
  String get restaurantActive;

  /// No description provided for @restaurantInactive.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get restaurantInactive;

  /// No description provided for @managersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérants'**
  String get managersTitle;

  /// No description provided for @managersEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun gérant'**
  String get managersEmpty;

  /// No description provided for @managerInvite.
  ///
  /// In fr, this message translates to:
  /// **'Inviter un gérant'**
  String get managerInvite;

  /// No description provided for @managerInviteField.
  ///
  /// In fr, this message translates to:
  /// **'Email ou numéro du gérant'**
  String get managerInviteField;

  /// No description provided for @managerPending.
  ///
  /// In fr, this message translates to:
  /// **'Invitation en attente d\'inscription'**
  String get managerPending;

  /// No description provided for @managerLinked.
  ///
  /// In fr, this message translates to:
  /// **'Compte relié'**
  String get managerLinked;

  /// No description provided for @managerRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get managerRemove;

  /// No description provided for @managersSaveFirst.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez le restaurant pour inviter ses gérants.'**
  String get managersSaveFirst;

  /// No description provided for @fieldRestaurantZone.
  ///
  /// In fr, this message translates to:
  /// **'Zone'**
  String get fieldRestaurantZone;

  /// No description provided for @fieldLatitude.
  ///
  /// In fr, this message translates to:
  /// **'Latitude'**
  String get fieldLatitude;

  /// No description provided for @fieldLongitude.
  ///
  /// In fr, this message translates to:
  /// **'Longitude'**
  String get fieldLongitude;

  /// No description provided for @restaurantViewOnMap.
  ///
  /// In fr, this message translates to:
  /// **'Voir l\'emplacement sur une carte'**
  String get restaurantViewOnMap;

  /// No description provided for @homeGreetingAnonymous.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour'**
  String get homeGreetingAnonymous;

  /// No description provided for @homeGreeting.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeHeadline.
  ///
  /// In fr, this message translates to:
  /// **'Que voulez-vous aujourd\'hui ?'**
  String get homeHeadline;

  /// No description provided for @homeServiceFood.
  ///
  /// In fr, this message translates to:
  /// **'Repas'**
  String get homeServiceFood;

  /// No description provided for @homeServiceFoodBody.
  ///
  /// In fr, this message translates to:
  /// **'Restaurants ouverts près de vous'**
  String get homeServiceFoodBody;

  /// No description provided for @homeServiceParcel.
  ///
  /// In fr, this message translates to:
  /// **'Colis'**
  String get homeServiceParcel;

  /// No description provided for @homeServiceParcelBody.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez d\'un point à un autre'**
  String get homeServiceParcelBody;

  /// No description provided for @homeSoon.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt'**
  String get homeSoon;

  /// No description provided for @homeRestaurants.
  ///
  /// In fr, this message translates to:
  /// **'Restaurants près de vous'**
  String get homeRestaurants;

  /// No description provided for @homeRestaurantsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun restaurant n\'est encore disponible dans votre zone.'**
  String get homeRestaurantsEmpty;

  /// No description provided for @homeDeliverTo.
  ///
  /// In fr, this message translates to:
  /// **'Livrer à'**
  String get homeDeliverTo;

  /// No description provided for @homeNoAddress.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une adresse'**
  String get homeNoAddress;

  /// No description provided for @restaurantPrepRange.
  ///
  /// In fr, this message translates to:
  /// **'{min}–{max} min'**
  String restaurantPrepRange(int min, int max);

  /// No description provided for @restaurantMenuSoon.
  ///
  /// In fr, this message translates to:
  /// **'Le menu de ce restaurant arrive bientôt.'**
  String get restaurantMenuSoon;

  /// No description provided for @menuOther.
  ///
  /// In fr, this message translates to:
  /// **'Autres'**
  String get menuOther;

  /// No description provided for @factPrep.
  ///
  /// In fr, this message translates to:
  /// **'Préparation'**
  String get factPrep;

  /// No description provided for @factNow.
  ///
  /// In fr, this message translates to:
  /// **'Maintenant'**
  String get factNow;

  /// No description provided for @cartView.
  ///
  /// In fr, this message translates to:
  /// **'Voir le panier'**
  String get cartView;

  /// No description provided for @cartItems.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 article} other{{count} articles}}'**
  String cartItems(int count);

  /// No description provided for @cartReplaceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commencer un nouveau panier ?'**
  String get cartReplaceTitle;

  /// No description provided for @cartReplaceBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre panier contient des plats de {restaurant}. Il sera vidé.'**
  String cartReplaceBody(String restaurant);

  /// No description provided for @cartReplaceConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Vider et ajouter'**
  String get cartReplaceConfirm;

  /// No description provided for @productAddTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au panier'**
  String get productAddTooltip;

  /// No description provided for @checkoutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre commande'**
  String get checkoutTitle;

  /// No description provided for @checkoutDeliverTo.
  ///
  /// In fr, this message translates to:
  /// **'Livrer à'**
  String get checkoutDeliverTo;

  /// No description provided for @checkoutChangeAddress.
  ///
  /// In fr, this message translates to:
  /// **'Changer'**
  String get checkoutChangeAddress;

  /// No description provided for @checkoutPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get checkoutPayment;

  /// No description provided for @paymentCash.
  ///
  /// In fr, this message translates to:
  /// **'Espèces à la livraison'**
  String get paymentCash;

  /// No description provided for @paymentMobileMoney.
  ///
  /// In fr, this message translates to:
  /// **'Mobile Money'**
  String get paymentMobileMoney;

  /// No description provided for @paymentCard.
  ///
  /// In fr, this message translates to:
  /// **'Carte bancaire'**
  String get paymentCard;

  /// No description provided for @paymentSoon.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt'**
  String get paymentSoon;

  /// No description provided for @paymentMobileMoneyHint.
  ///
  /// In fr, this message translates to:
  /// **'Orange Money, MTN MoMo, Wave, Moov Money'**
  String get paymentMobileMoneyHint;

  /// No description provided for @paymentCardHint.
  ///
  /// In fr, this message translates to:
  /// **'Visa, Mastercard · page sécurisée Stripe'**
  String get paymentCardHint;

  /// No description provided for @momoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paiement Mobile Money'**
  String get momoTitle;

  /// No description provided for @momoBody.
  ///
  /// In fr, this message translates to:
  /// **'Payez {amount} sur la page sécurisée de nyole (Orange Money, MTN MoMo, Wave ou Moov Money), puis revenez ici : la commande part dès que l\'opérateur confirme le paiement.'**
  String momoBody(String amount);

  /// No description provided for @onlinePay.
  ///
  /// In fr, this message translates to:
  /// **'Payer {amount}'**
  String onlinePay(String amount);

  /// No description provided for @momoWaiting.
  ///
  /// In fr, this message translates to:
  /// **'Validez le paiement sur votre téléphone. Nous attendons la confirmation de l\'opérateur…'**
  String get momoWaiting;

  /// No description provided for @onlineResume.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre le paiement'**
  String get onlineResume;

  /// No description provided for @onlineCheck.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai payé : vérifier'**
  String get onlineCheck;

  /// No description provided for @onlineStillPending.
  ///
  /// In fr, this message translates to:
  /// **'Paiement pas encore confirmé. Si vous l\'avez validé, patientez quelques secondes.'**
  String get onlineStillPending;

  /// No description provided for @momoFailed.
  ///
  /// In fr, this message translates to:
  /// **'Le paiement n\'a pas été validé par l\'opérateur.'**
  String get momoFailed;

  /// No description provided for @cardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paiement par carte'**
  String get cardTitle;

  /// No description provided for @cardBody.
  ///
  /// In fr, this message translates to:
  /// **'Payez {amount} sur la page sécurisée de Stripe (Visa, Mastercard ; validation de votre banque si elle la demande), puis revenez ici : la commande part dès que la banque confirme le paiement.'**
  String cardBody(String amount);

  /// No description provided for @cardWaiting.
  ///
  /// In fr, this message translates to:
  /// **'Terminez le paiement sur la page Stripe. Nous attendons la confirmation de votre banque…'**
  String get cardWaiting;

  /// No description provided for @cardFailed.
  ///
  /// In fr, this message translates to:
  /// **'Le paiement n\'a pas abouti. Réessayez ou choisissez un autre moyen de paiement.'**
  String get cardFailed;

  /// No description provided for @onlineRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get onlineRetry;

  /// No description provided for @onlineDeadline.
  ///
  /// In fr, this message translates to:
  /// **'Sans paiement d\'ici {time}, la commande est annulée.'**
  String onlineDeadline(String time);

  /// No description provided for @onlineChangeMethod.
  ///
  /// In fr, this message translates to:
  /// **'Changer de moyen de paiement'**
  String get onlineChangeMethod;

  /// No description provided for @onlineChangeBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette commande non payée sera annulée ; vous retrouverez votre demande pour choisir un autre moyen de paiement.'**
  String get onlineChangeBody;

  /// No description provided for @failurePaymentClosed.
  ///
  /// In fr, this message translates to:
  /// **'Le délai de paiement est dépassé : la commande a été annulée.'**
  String get failurePaymentClosed;

  /// No description provided for @failureAlreadyPaid.
  ///
  /// In fr, this message translates to:
  /// **'Cette commande est déjà payée.'**
  String get failureAlreadyPaid;

  /// No description provided for @failurePaymentProvider.
  ///
  /// In fr, this message translates to:
  /// **'Le service de paiement ne répond pas. Réessayez dans un instant.'**
  String get failurePaymentProvider;

  /// No description provided for @orderPaymentTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Paiement non reçu à temps'**
  String get orderPaymentTimeout;

  /// No description provided for @orderLatePayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement reçu après l\'annulation'**
  String get orderLatePayment;

  /// No description provided for @checkoutSubtotal.
  ///
  /// In fr, this message translates to:
  /// **'Sous-total'**
  String get checkoutSubtotal;

  /// No description provided for @checkoutDeliveryFee.
  ///
  /// In fr, this message translates to:
  /// **'Frais de livraison'**
  String get checkoutDeliveryFee;

  /// No description provided for @checkoutTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get checkoutTotal;

  /// No description provided for @checkoutToConfirm.
  ///
  /// In fr, this message translates to:
  /// **'À confirmer'**
  String get checkoutToConfirm;

  /// No description provided for @checkoutConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Commander · {total}'**
  String checkoutConfirm(String total);

  /// No description provided for @checkoutNeedAddress.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez une adresse de livraison pour commander.'**
  String get checkoutNeedAddress;

  /// No description provided for @checkoutEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Votre panier est vide'**
  String get checkoutEmpty;

  /// No description provided for @checkoutUpdateCart.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour le panier'**
  String get checkoutUpdateCart;

  /// No description provided for @issueRestaurantClosed.
  ///
  /// In fr, this message translates to:
  /// **'Le restaurant est fermé pour le moment.'**
  String get issueRestaurantClosed;

  /// No description provided for @issueProductUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » n\'est plus disponible.'**
  String issueProductUnavailable(String name);

  /// No description provided for @failurePriceChanged.
  ///
  /// In fr, this message translates to:
  /// **'Les prix ont changé : vérifiez le nouveau total.'**
  String get failurePriceChanged;

  /// No description provided for @failureCartChanged.
  ///
  /// In fr, this message translates to:
  /// **'Votre panier a changé : vérifiez-le avant de commander.'**
  String get failureCartChanged;

  /// No description provided for @failurePaymentUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Ce moyen de paiement n\'est pas encore disponible.'**
  String get failurePaymentUnavailable;

  /// No description provided for @failureAlreadyAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Le restaurant prépare déjà votre commande. Contactez le support.'**
  String get failureAlreadyAccepted;

  /// No description provided for @failureInvalidTransition.
  ///
  /// In fr, this message translates to:
  /// **'Cette action n\'est plus possible : la commande a changé.'**
  String get failureInvalidTransition;

  /// No description provided for @failureCartEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Votre panier est vide.'**
  String get failureCartEmpty;

  /// No description provided for @ordersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes commandes'**
  String get ordersTitle;

  /// No description provided for @ordersEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune commande pour le moment'**
  String get ordersEmpty;

  /// No description provided for @ordersEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Vos commandes de repas apparaîtront ici.'**
  String get ordersEmptyBody;

  /// No description provided for @ordersActive.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get ordersActive;

  /// No description provided for @ordersPast.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get ordersPast;

  /// No description provided for @orderNumber.
  ///
  /// In fr, this message translates to:
  /// **'Commande {number}'**
  String orderNumber(String number);

  /// No description provided for @orderItemsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Articles'**
  String get orderItemsTitle;

  /// No description provided for @orderTimeline.
  ///
  /// In fr, this message translates to:
  /// **'Suivi'**
  String get orderTimeline;

  /// No description provided for @orderDeliveryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Livraison'**
  String get orderDeliveryTitle;

  /// No description provided for @orderCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la commande'**
  String get orderCancel;

  /// No description provided for @orderCancelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annuler cette commande ?'**
  String get orderCancelTitle;

  /// No description provided for @orderCancelBody.
  ///
  /// In fr, this message translates to:
  /// **'Le restaurant n\'a pas encore accepté : rien ne vous sera facturé.'**
  String get orderCancelBody;

  /// No description provided for @orderCancelPaidBody.
  ///
  /// In fr, this message translates to:
  /// **'Le restaurant n\'a pas encore accepté : votre paiement vous sera remboursé intégralement.'**
  String get orderCancelPaidBody;

  /// No description provided for @orderCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Commande annulée.'**
  String get orderCancelled;

  /// No description provided for @orderReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif : {reason}'**
  String orderReason(String reason);

  /// No description provided for @orderNoResponse.
  ///
  /// In fr, this message translates to:
  /// **'Sans réponse du restaurant'**
  String get orderNoResponse;

  /// No description provided for @orderCancelledByCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Annulée par le client'**
  String get orderCancelledByCustomer;

  /// No description provided for @homeActiveOrder.
  ///
  /// In fr, this message translates to:
  /// **'Commande en cours'**
  String get homeActiveOrder;

  /// No description provided for @restaurantOrders.
  ///
  /// In fr, this message translates to:
  /// **'Commandes'**
  String get restaurantOrders;

  /// No description provided for @ordersNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelles'**
  String get ordersNew;

  /// No description provided for @ordersInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get ordersInProgress;

  /// No description provided for @ordersDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminées'**
  String get ordersDone;

  /// No description provided for @ordersNewEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune nouvelle commande'**
  String get ordersNewEmpty;

  /// No description provided for @ordersInProgressEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune commande en cours'**
  String get ordersInProgressEmpty;

  /// No description provided for @ordersDoneEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune commande terminée aujourd\'hui'**
  String get ordersDoneEmpty;

  /// No description provided for @orderAccept.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get orderAccept;

  /// No description provided for @orderReject.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get orderReject;

  /// No description provided for @orderStartPreparing.
  ///
  /// In fr, this message translates to:
  /// **'Lancer la préparation'**
  String get orderStartPreparing;

  /// No description provided for @orderMarkReady.
  ///
  /// In fr, this message translates to:
  /// **'Commande prête'**
  String get orderMarkReady;

  /// No description provided for @orderAnswerWithin.
  ///
  /// In fr, this message translates to:
  /// **'Répondre sous {minutes} min'**
  String orderAnswerWithin(int minutes);

  /// No description provided for @orderWaitingCourier.
  ///
  /// In fr, this message translates to:
  /// **'En attente du livreur'**
  String get orderWaitingCourier;

  /// No description provided for @rejectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Motif du refus'**
  String get rejectTitle;

  /// No description provided for @rejectUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Produit indisponible'**
  String get rejectUnavailable;

  /// No description provided for @rejectClosing.
  ///
  /// In fr, this message translates to:
  /// **'Fermeture du restaurant'**
  String get rejectClosing;

  /// No description provided for @rejectBusy.
  ///
  /// In fr, this message translates to:
  /// **'Trop de commandes'**
  String get rejectBusy;

  /// No description provided for @rejectOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre motif'**
  String get rejectOther;

  /// No description provided for @todaySales.
  ///
  /// In fr, this message translates to:
  /// **'Ventes du jour'**
  String get todaySales;

  /// No description provided for @todayCommission.
  ///
  /// In fr, this message translates to:
  /// **'Commission'**
  String get todayCommission;

  /// No description provided for @todayNet.
  ///
  /// In fr, this message translates to:
  /// **'Net'**
  String get todayNet;

  /// No description provided for @newOrderAlert.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle commande !'**
  String get newOrderAlert;

  /// No description provided for @orderStatusAwaitingPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement en attente'**
  String get orderStatusAwaitingPayment;

  /// No description provided for @orderStatusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente de confirmation'**
  String get orderStatusPending;

  /// No description provided for @orderStatusAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Acceptée'**
  String get orderStatusAccepted;

  /// No description provided for @orderStatusPreparing.
  ///
  /// In fr, this message translates to:
  /// **'En préparation'**
  String get orderStatusPreparing;

  /// No description provided for @orderStatusReady.
  ///
  /// In fr, this message translates to:
  /// **'Prête'**
  String get orderStatusReady;

  /// No description provided for @orderStatusSearchingCourier.
  ///
  /// In fr, this message translates to:
  /// **'Recherche d\'un livreur'**
  String get orderStatusSearchingCourier;

  /// No description provided for @orderStatusCourierAssigned.
  ///
  /// In fr, this message translates to:
  /// **'Livreur assigné'**
  String get orderStatusCourierAssigned;

  /// No description provided for @orderStatusPickedUp.
  ///
  /// In fr, this message translates to:
  /// **'Récupérée'**
  String get orderStatusPickedUp;

  /// No description provided for @orderStatusInTransit.
  ///
  /// In fr, this message translates to:
  /// **'En route'**
  String get orderStatusInTransit;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In fr, this message translates to:
  /// **'Livrée'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusRejected.
  ///
  /// In fr, this message translates to:
  /// **'Refusée'**
  String get orderStatusRejected;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get orderStatusCancelled;

  /// No description provided for @orderStatusFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de livraison'**
  String get orderStatusFailed;

  /// No description provided for @homeSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un restaurant ou une cuisine'**
  String get homeSearchHint;

  /// No description provided for @homeAllCuisines.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get homeAllCuisines;

  /// No description provided for @homeNoMatch.
  ///
  /// In fr, this message translates to:
  /// **'Aucun restaurant ne correspond à votre recherche.'**
  String get homeNoMatch;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navOrders.
  ///
  /// In fr, this message translates to:
  /// **'Commandes'**
  String get navOrders;

  /// No description provided for @navAccount.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navAccount;

  /// No description provided for @navPayments.
  ///
  /// In fr, this message translates to:
  /// **'Paiements'**
  String get navPayments;

  /// No description provided for @notificationsTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notificationsTooltip;

  /// No description provided for @orderStep.
  ///
  /// In fr, this message translates to:
  /// **'Étape {step} sur {total}'**
  String orderStep(int step, int total);

  /// No description provided for @newOrderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Que voulez-vous faire ?'**
  String get newOrderTitle;

  /// No description provided for @newOrderFood.
  ///
  /// In fr, this message translates to:
  /// **'Commander un repas'**
  String get newOrderFood;

  /// No description provided for @newOrderFoodBody.
  ///
  /// In fr, this message translates to:
  /// **'Les restaurants ouverts près de vous'**
  String get newOrderFoodBody;

  /// No description provided for @newOrderParcel.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer un colis'**
  String get newOrderParcel;

  /// No description provided for @newOrderParcelBody.
  ///
  /// In fr, this message translates to:
  /// **'D\'un point à un autre, en ville'**
  String get newOrderParcelBody;

  /// No description provided for @paymentsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paiements'**
  String get paymentsTitle;

  /// No description provided for @paymentsMethods.
  ///
  /// In fr, this message translates to:
  /// **'Moyens de paiement'**
  String get paymentsMethods;

  /// No description provided for @paymentsHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get paymentsHistory;

  /// No description provided for @paymentsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun paiement pour le moment'**
  String get paymentsEmpty;

  /// No description provided for @paymentsEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Vos paiements de commandes apparaîtront ici.'**
  String get paymentsEmptyBody;

  /// No description provided for @paymentDue.
  ///
  /// In fr, this message translates to:
  /// **'À payer à la livraison'**
  String get paymentDue;

  /// No description provided for @paymentDone.
  ///
  /// In fr, this message translates to:
  /// **'Payé'**
  String get paymentDone;

  /// No description provided for @paymentNone.
  ///
  /// In fr, this message translates to:
  /// **'Non facturé'**
  String get paymentNone;

  /// No description provided for @ordersNewEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Elles apparaissent ici en direct, avec une alerte.'**
  String get ordersNewEmptyBody;

  /// No description provided for @ordersTodayCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune commande aujourd\'hui} =1{1 commande aujourd\'hui} other{{count} commandes aujourd\'hui}}'**
  String ordersTodayCount(int count);

  /// No description provided for @parcelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer un colis'**
  String get parcelTitle;

  /// No description provided for @parcelStepPickup.
  ///
  /// In fr, this message translates to:
  /// **'Départ'**
  String get parcelStepPickup;

  /// No description provided for @parcelStepPickupBody.
  ///
  /// In fr, this message translates to:
  /// **'D\'où part le colis ?'**
  String get parcelStepPickupBody;

  /// No description provided for @parcelStepDropoff.
  ///
  /// In fr, this message translates to:
  /// **'Arrivée'**
  String get parcelStepDropoff;

  /// No description provided for @parcelStepDropoffBody.
  ///
  /// In fr, this message translates to:
  /// **'Où faut-il le livrer ?'**
  String get parcelStepDropoffBody;

  /// No description provided for @parcelStepDetails.
  ///
  /// In fr, this message translates to:
  /// **'Le colis'**
  String get parcelStepDetails;

  /// No description provided for @parcelStepDetailsBody.
  ///
  /// In fr, this message translates to:
  /// **'Le destinataire et le contenu.'**
  String get parcelStepDetailsBody;

  /// No description provided for @parcelStepSummary.
  ///
  /// In fr, this message translates to:
  /// **'Récapitulatif'**
  String get parcelStepSummary;

  /// No description provided for @parcelStepSummaryBody.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez avant de confirmer.'**
  String get parcelStepSummaryBody;

  /// No description provided for @parcelOtherPoint.
  ///
  /// In fr, this message translates to:
  /// **'Autre point sur la carte'**
  String get parcelOtherPoint;

  /// No description provided for @parcelRecipientName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du destinataire'**
  String get parcelRecipientName;

  /// No description provided for @parcelRecipientPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone du destinataire'**
  String get parcelRecipientPhone;

  /// No description provided for @parcelType.
  ///
  /// In fr, this message translates to:
  /// **'Type de colis'**
  String get parcelType;

  /// No description provided for @parcelDescription.
  ///
  /// In fr, this message translates to:
  /// **'Que contient le colis ?'**
  String get parcelDescription;

  /// No description provided for @parcelRulesAccept.
  ///
  /// In fr, this message translates to:
  /// **'Mon colis respecte la liste des objets autorisés'**
  String get parcelRulesAccept;

  /// No description provided for @parcelRulesView.
  ///
  /// In fr, this message translates to:
  /// **'Voir la liste'**
  String get parcelRulesView;

  /// No description provided for @parcelRulesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Objets interdits'**
  String get parcelRulesTitle;

  /// No description provided for @parcelRulesBody.
  ///
  /// In fr, this message translates to:
  /// **'• Argent liquide, bijoux et objets de valeur\n• Armes, munitions, produits explosifs ou inflammables\n• Drogues et médicaments sans ordonnance\n• Animaux vivants\n• Aliments périssables mal emballés\n• Tout objet illégal en Côte d\'Ivoire'**
  String get parcelRulesBody;

  /// No description provided for @parcelRulesRequired.
  ///
  /// In fr, this message translates to:
  /// **'Cochez la case pour continuer.'**
  String get parcelRulesRequired;

  /// No description provided for @parcelDistance.
  ///
  /// In fr, this message translates to:
  /// **'Distance de référence'**
  String get parcelDistance;

  /// No description provided for @parcelDistanceValue.
  ///
  /// In fr, this message translates to:
  /// **'{km} km'**
  String parcelDistanceValue(String km);

  /// No description provided for @parcelPayCash.
  ///
  /// In fr, this message translates to:
  /// **'À payer au livreur à la récupération'**
  String get parcelPayCash;

  /// No description provided for @parcelPaymentCash.
  ///
  /// In fr, this message translates to:
  /// **'Espèces'**
  String get parcelPaymentCash;

  /// No description provided for @parcelCancelBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre colis n\'a pas encore été récupéré : rien ne vous sera facturé.'**
  String get parcelCancelBody;

  /// No description provided for @parcelCancelPaidBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre colis n\'a pas encore été récupéré : votre paiement vous sera remboursé intégralement.'**
  String get parcelCancelPaidBody;

  /// No description provided for @parcelConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer · {total}'**
  String parcelConfirm(String total);

  /// No description provided for @parcelOrderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Colis vers {district}'**
  String parcelOrderTitle(String district);

  /// No description provided for @failureDifferentZones.
  ///
  /// In fr, this message translates to:
  /// **'Les livraisons entre villes ne sont pas disponibles.'**
  String get failureDifferentZones;

  /// No description provided for @failureSameLocation.
  ///
  /// In fr, this message translates to:
  /// **'Le point d\'arrivée est trop proche du départ : déplacez l\'épingle sur la carte.'**
  String get failureSameLocation;

  /// No description provided for @failureRulesNotAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez que votre colis respecte la liste des objets autorisés.'**
  String get failureRulesNotAccepted;

  /// No description provided for @failureInvalidRecipient.
  ///
  /// In fr, this message translates to:
  /// **'Numéro du destinataire invalide.'**
  String get failureInvalidRecipient;

  /// No description provided for @failureInvalidAddress.
  ///
  /// In fr, this message translates to:
  /// **'Quartier et point de repère sont obligatoires.'**
  String get failureInvalidAddress;

  /// No description provided for @failureAlreadyPickedUp.
  ///
  /// In fr, this message translates to:
  /// **'Le colis a déjà été récupéré. Contactez le support.'**
  String get failureAlreadyPickedUp;

  /// No description provided for @deliveryCodeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Code de livraison'**
  String get deliveryCodeTitle;

  /// No description provided for @deliveryCodeFoodBody.
  ///
  /// In fr, this message translates to:
  /// **'À donner au livreur à la livraison.'**
  String get deliveryCodeFoodBody;

  /// No description provided for @deliveryCodeParcelBody.
  ///
  /// In fr, this message translates to:
  /// **'À transmettre au destinataire : il le donnera au livreur.'**
  String get deliveryCodeParcelBody;

  /// No description provided for @deliveryCodeShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager au destinataire'**
  String get deliveryCodeShare;

  /// No description provided for @shareWhatsApp.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp'**
  String get shareWhatsApp;

  /// No description provided for @shareSms.
  ///
  /// In fr, this message translates to:
  /// **'SMS'**
  String get shareSms;

  /// No description provided for @deliveryCodeMessage.
  ///
  /// In fr, this message translates to:
  /// **'Tchopi : un colis arrive pour vous ({number}), de {from} à {to}. Code à donner au livreur : {code}.'**
  String deliveryCodeMessage(
    String number,
    String from,
    String to,
    String code,
  );

  /// No description provided for @orderParcelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Colis'**
  String get orderParcelTitle;

  /// No description provided for @orderPickupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Départ'**
  String get orderPickupTitle;

  /// No description provided for @orderDropoffTitle.
  ///
  /// In fr, this message translates to:
  /// **'Arrivée'**
  String get orderDropoffTitle;

  /// No description provided for @orderRecipient.
  ///
  /// In fr, this message translates to:
  /// **'Destinataire'**
  String get orderRecipient;

  /// No description provided for @failureNoCourier.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livreur disponible pour le moment. Réessayez dans quelques minutes.'**
  String get failureNoCourier;

  /// No description provided for @failureCourierNotApproved.
  ///
  /// In fr, this message translates to:
  /// **'Votre compte livreur doit être approuvé pour passer en ligne.'**
  String get failureCourierNotApproved;

  /// No description provided for @failureMissionInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Terminez votre mission avant de passer hors ligne.'**
  String get failureMissionInProgress;

  /// No description provided for @failureCourierOffline.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes hors ligne : passez en ligne pour partager votre position.'**
  String get failureCourierOffline;

  /// No description provided for @failureOfferUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Cette mission n\'est plus disponible.'**
  String get failureOfferUnavailable;

  /// No description provided for @failureCourierBusy.
  ///
  /// In fr, this message translates to:
  /// **'Ce livreur vient d\'accepter une autre mission.'**
  String get failureCourierBusy;

  /// No description provided for @failureCourierUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Ce livreur n\'est plus en ligne.'**
  String get failureCourierUnavailable;

  /// No description provided for @courierOnline.
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get courierOnline;

  /// No description provided for @courierOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get courierOffline;

  /// No description provided for @courierOnlineBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous recevez des missions autour de vous. Votre position est partagée tant que vous êtes en ligne.'**
  String get courierOnlineBody;

  /// No description provided for @courierOfflineBody.
  ///
  /// In fr, this message translates to:
  /// **'Passez en ligne pour recevoir des missions.'**
  String get courierOfflineBody;

  /// No description provided for @courierLocationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Partager votre position'**
  String get courierLocationTitle;

  /// No description provided for @courierLocationBody.
  ///
  /// In fr, this message translates to:
  /// **'En ligne, votre position sert uniquement à vous proposer les missions les plus proches. Elle n\'est plus partagée dès que vous passez hors ligne.'**
  String get courierLocationBody;

  /// No description provided for @courierLocationDenied.
  ///
  /// In fr, this message translates to:
  /// **'La localisation est nécessaire pour recevoir des missions.'**
  String get courierLocationDenied;

  /// No description provided for @courierGpsOff.
  ///
  /// In fr, this message translates to:
  /// **'Activez le GPS pour passer en ligne.'**
  String get courierGpsOff;

  /// No description provided for @courierOpenSettings.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les réglages'**
  String get courierOpenSettings;

  /// No description provided for @courierNotificationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes en ligne'**
  String get courierNotificationTitle;

  /// No description provided for @courierNotificationText.
  ///
  /// In fr, this message translates to:
  /// **'Votre position est partagée pour recevoir des missions.'**
  String get courierNotificationText;

  /// No description provided for @courierWaitingTitle.
  ///
  /// In fr, this message translates to:
  /// **'En attente d\'une mission'**
  String get courierWaitingTitle;

  /// No description provided for @courierWaitingBody.
  ///
  /// In fr, this message translates to:
  /// **'Restez en ligne : chaque nouvelle demande s\'affiche en plein écran.'**
  String get courierWaitingBody;

  /// No description provided for @courierMissionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mission en cours'**
  String get courierMissionTitle;

  /// No description provided for @courierMissionEarning.
  ///
  /// In fr, this message translates to:
  /// **'Gain {amount}'**
  String courierMissionEarning(String amount);

  /// No description provided for @offerFood.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle mission · Repas'**
  String get offerFood;

  /// No description provided for @offerParcel.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle mission · Colis'**
  String get offerParcel;

  /// No description provided for @offerTotalDistance.
  ///
  /// In fr, this message translates to:
  /// **'{km} km au total'**
  String offerTotalDistance(String km);

  /// No description provided for @offerSeconds.
  ///
  /// In fr, this message translates to:
  /// **'secondes'**
  String get offerSeconds;

  /// No description provided for @offerEarning.
  ///
  /// In fr, this message translates to:
  /// **'Votre gain'**
  String get offerEarning;

  /// No description provided for @offerPickup.
  ///
  /// In fr, this message translates to:
  /// **'Retrait · {name}'**
  String offerPickup(String name);

  /// No description provided for @offerDropoff.
  ///
  /// In fr, this message translates to:
  /// **'Livraison · {name}'**
  String offerDropoff(String name);

  /// No description provided for @offerCash.
  ///
  /// In fr, this message translates to:
  /// **'Espèces à encaisser · {amount}'**
  String offerCash(String amount);

  /// No description provided for @offerAccept.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get offerAccept;

  /// No description provided for @offerDecline.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get offerDecline;

  /// No description provided for @offerAcceptedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mission acceptée'**
  String get offerAcceptedTitle;

  /// No description provided for @offerAcceptedBody.
  ///
  /// In fr, this message translates to:
  /// **'Direction {place}, à {km} km. Le client est prévenu.'**
  String offerAcceptedBody(String place, String km);

  /// No description provided for @offerExpiredTitle.
  ///
  /// In fr, this message translates to:
  /// **'Offre expirée'**
  String get offerExpiredTitle;

  /// No description provided for @offerDeclinedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Offre refusée'**
  String get offerDeclinedTitle;

  /// No description provided for @offerDeclinedBody.
  ///
  /// In fr, this message translates to:
  /// **'Elle est proposée à un autre livreur. Restez en ligne pour la prochaine.'**
  String get offerDeclinedBody;

  /// No description provided for @orderCourierTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre livreur'**
  String get orderCourierTitle;

  /// No description provided for @orderCourierCall.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get orderCourierCall;

  /// No description provided for @dispatchAlertTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nous cherchons encore un livreur'**
  String get dispatchAlertTitle;

  /// No description provided for @dispatchAlertBody.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livreur n\'est disponible pour l\'instant. Vous pouvez continuer d\'attendre ou annuler sans frais.'**
  String get dispatchAlertBody;

  /// No description provided for @dispatchKeepWaiting.
  ///
  /// In fr, this message translates to:
  /// **'Continuer d\'attendre'**
  String get dispatchKeepWaiting;

  /// No description provided for @eventCourierAssigned.
  ///
  /// In fr, this message translates to:
  /// **'Livreur assigné'**
  String get eventCourierAssigned;

  /// No description provided for @eventCourierReleased.
  ///
  /// In fr, this message translates to:
  /// **'Livreur retiré'**
  String get eventCourierReleased;

  /// No description provided for @eventDispatchAlert.
  ///
  /// In fr, this message translates to:
  /// **'Alerte : toujours sans livreur'**
  String get eventDispatchAlert;

  /// No description provided for @orderNoCourier.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livreur disponible'**
  String get orderNoCourier;

  /// No description provided for @adminSupervision.
  ///
  /// In fr, this message translates to:
  /// **'Commandes en cours'**
  String get adminSupervision;

  /// No description provided for @adminSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get adminSettings;

  /// No description provided for @supervisionAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get supervisionAll;

  /// No description provided for @supervisionAlertNoCourier.
  ///
  /// In fr, this message translates to:
  /// **'Sans livreur : {count}'**
  String supervisionAlertNoCourier(int count);

  /// No description provided for @supervisionAlertRestaurant.
  ///
  /// In fr, this message translates to:
  /// **'Restaurant sans réponse : {count}'**
  String supervisionAlertRestaurant(int count);

  /// No description provided for @supervisionEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune commande en cours'**
  String get supervisionEmpty;

  /// No description provided for @supervisionEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Les nouvelles commandes apparaissent ici en temps réel.'**
  String get supervisionEmptyBody;

  /// No description provided for @adminOrderCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get adminOrderCustomer;

  /// No description provided for @adminOrderCourier.
  ///
  /// In fr, this message translates to:
  /// **'Livreur'**
  String get adminOrderCourier;

  /// No description provided for @adminOrderNoCourier.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livreur attribué'**
  String get adminOrderNoCourier;

  /// No description provided for @adminAssign.
  ///
  /// In fr, this message translates to:
  /// **'Attribuer un livreur'**
  String get adminAssign;

  /// No description provided for @adminReassign.
  ///
  /// In fr, this message translates to:
  /// **'Changer de livreur'**
  String get adminReassign;

  /// No description provided for @assignTitle.
  ///
  /// In fr, this message translates to:
  /// **'Livreurs en ligne'**
  String get assignTitle;

  /// No description provided for @assignEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livreur en ligne dans la zone.'**
  String get assignEmpty;

  /// No description provided for @candidateBusy.
  ///
  /// In fr, this message translates to:
  /// **'En mission'**
  String get candidateBusy;

  /// No description provided for @candidateOffer.
  ///
  /// In fr, this message translates to:
  /// **'Offre en cours'**
  String get candidateOffer;

  /// No description provided for @candidateFree.
  ///
  /// In fr, this message translates to:
  /// **'Disponible'**
  String get candidateFree;

  /// No description provided for @candidateDetails.
  ///
  /// In fr, this message translates to:
  /// **'{distance} km · position il y a {age}'**
  String candidateDetails(String distance, String age);

  /// No description provided for @assignReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif de l\'attribution'**
  String get assignReason;

  /// No description provided for @assignDone.
  ///
  /// In fr, this message translates to:
  /// **'Livreur attribué.'**
  String get assignDone;

  /// No description provided for @adminCancelReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif de l\'annulation'**
  String get adminCancelReason;

  /// No description provided for @actorCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get actorCustomer;

  /// No description provided for @actorRestaurant.
  ///
  /// In fr, this message translates to:
  /// **'Restaurant'**
  String get actorRestaurant;

  /// No description provided for @actorCourier.
  ///
  /// In fr, this message translates to:
  /// **'Livreur'**
  String get actorCourier;

  /// No description provided for @actorAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Admin'**
  String get actorAdmin;

  /// No description provided for @actorSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get actorSystem;

  /// No description provided for @settingsDelaysTitle.
  ///
  /// In fr, this message translates to:
  /// **'Délais'**
  String get settingsDelaysTitle;

  /// No description provided for @settingsOfferTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Délai d\'une offre (secondes)'**
  String get settingsOfferTimeout;

  /// No description provided for @settingsRestaurantTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Délai de réponse du restaurant (minutes)'**
  String get settingsRestaurantTimeout;

  /// No description provided for @settingsPaymentTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Expiration d\'un paiement (minutes)'**
  String get settingsPaymentTimeout;

  /// No description provided for @settingsDispatchAlert.
  ///
  /// In fr, this message translates to:
  /// **'Alerte sans livreur (minutes)'**
  String get settingsDispatchAlert;

  /// No description provided for @settingsDispatchCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annulation sans livreur (minutes)'**
  String get settingsDispatchCancel;

  /// No description provided for @settingsSupportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Support'**
  String get settingsSupportTitle;

  /// No description provided for @settingsSupportPhone.
  ///
  /// In fr, this message translates to:
  /// **'Numéro du support'**
  String get settingsSupportPhone;

  /// No description provided for @settingsRange.
  ///
  /// In fr, this message translates to:
  /// **'Entre {min} et {max}.'**
  String settingsRange(int min, int max);

  /// No description provided for @settingsCancelAfterAlert.
  ///
  /// In fr, this message translates to:
  /// **'L\'annulation doit venir après l\'alerte.'**
  String get settingsCancelAfterAlert;

  /// No description provided for @settingsSaved.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres enregistrés : ils s\'appliquent aux nouvelles commandes.'**
  String get settingsSaved;

  /// No description provided for @courierOpenDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir des missions'**
  String get courierOpenDashboard;

  /// No description provided for @adminOrderCourierEarning.
  ///
  /// In fr, this message translates to:
  /// **'Rémunération du livreur'**
  String get adminOrderCourierEarning;

  /// No description provided for @adminOrderPlatform.
  ///
  /// In fr, this message translates to:
  /// **'Part de la plateforme'**
  String get adminOrderPlatform;

  /// No description provided for @adminOrderAmounts.
  ///
  /// In fr, this message translates to:
  /// **'Montants'**
  String get adminOrderAmounts;

  /// No description provided for @supervisionAllStatuses.
  ///
  /// In fr, this message translates to:
  /// **'Tous les statuts'**
  String get supervisionAllStatuses;

  /// No description provided for @supervisionAllZones.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les zones'**
  String get supervisionAllZones;

  /// No description provided for @failureSessionExpired.
  ///
  /// In fr, this message translates to:
  /// **'Votre session a expiré ou ce compte n\'existe plus. Reconnectez-vous pour continuer.'**
  String get failureSessionExpired;

  /// No description provided for @accountSignInAgain.
  ///
  /// In fr, this message translates to:
  /// **'Se reconnecter'**
  String get accountSignInAgain;

  /// No description provided for @failureNotReady.
  ///
  /// In fr, this message translates to:
  /// **'Le restaurant n\'a pas encore indiqué que la commande est prête.'**
  String get failureNotReady;

  /// No description provided for @failureCashConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez d\'abord l\'encaissement auprès de l\'expéditeur.'**
  String get failureCashConfirmation;

  /// No description provided for @failureNoCourierAssigned.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livreur n\'est encore attribué à cette commande.'**
  String get failureNoCourierAssigned;

  /// No description provided for @missionStepPickup.
  ///
  /// In fr, this message translates to:
  /// **'Aller au retrait'**
  String get missionStepPickup;

  /// No description provided for @missionStepDeliver.
  ///
  /// In fr, this message translates to:
  /// **'Livrer'**
  String get missionStepDeliver;

  /// No description provided for @missionPickupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Retrait'**
  String get missionPickupTitle;

  /// No description provided for @missionDropoffTitle.
  ///
  /// In fr, this message translates to:
  /// **'Livraison'**
  String get missionDropoffTitle;

  /// No description provided for @missionCall.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get missionCall;

  /// No description provided for @missionRoute.
  ///
  /// In fr, this message translates to:
  /// **'Itinéraire'**
  String get missionRoute;

  /// No description provided for @missionGoogleMaps.
  ///
  /// In fr, this message translates to:
  /// **'Google Maps'**
  String get missionGoogleMaps;

  /// No description provided for @missionWaze.
  ///
  /// In fr, this message translates to:
  /// **'Waze'**
  String get missionWaze;

  /// No description provided for @missionContents.
  ///
  /// In fr, this message translates to:
  /// **'Contenu'**
  String get missionContents;

  /// No description provided for @missionCashToCollect.
  ///
  /// In fr, this message translates to:
  /// **'À encaisser : {amount}'**
  String missionCashToCollect(String amount);

  /// No description provided for @missionPickedUp.
  ///
  /// In fr, this message translates to:
  /// **'Commande récupérée'**
  String get missionPickedUp;

  /// No description provided for @missionCashFromSenderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser {amount}'**
  String missionCashFromSenderTitle(String amount);

  /// No description provided for @missionCashFromSenderBody.
  ///
  /// In fr, this message translates to:
  /// **'L\'expéditeur paie la livraison maintenant, en espèces.'**
  String get missionCashFromSenderBody;

  /// No description provided for @missionCashFromSender.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai reçu {amount}'**
  String missionCashFromSender(String amount);

  /// No description provided for @missionStart.
  ///
  /// In fr, this message translates to:
  /// **'Je pars livrer'**
  String get missionStart;

  /// No description provided for @missionEnterCode.
  ///
  /// In fr, this message translates to:
  /// **'Arrivé — saisir le code'**
  String get missionEnterCode;

  /// No description provided for @missionRelease.
  ///
  /// In fr, this message translates to:
  /// **'Abandonner la mission'**
  String get missionRelease;

  /// No description provided for @missionReleaseReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif de l\'abandon'**
  String get missionReleaseReason;

  /// No description provided for @missionCancelledTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mission annulée'**
  String get missionCancelledTitle;

  /// No description provided for @missionCancelledBody.
  ///
  /// In fr, this message translates to:
  /// **'La commande a été annulée. Vous êtes de nouveau disponible pour d\'autres missions.'**
  String get missionCancelledBody;

  /// No description provided for @missionOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir la mission'**
  String get missionOpen;

  /// No description provided for @codeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Demandez le code au destinataire'**
  String get codeTitle;

  /// No description provided for @codeAttemptsLeft.
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect : encore {count} essai(s).'**
  String codeAttemptsLeft(int count);

  /// No description provided for @codeLocked.
  ///
  /// In fr, this message translates to:
  /// **'Saisie bloquée après trop d\'erreurs. Contactez le support.'**
  String get codeLocked;

  /// No description provided for @codeValidate.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get codeValidate;

  /// No description provided for @codeNoCode.
  ///
  /// In fr, this message translates to:
  /// **'Le destinataire n\'a pas de code ? Appeler le support'**
  String get codeNoCode;

  /// No description provided for @cashCollectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Encaissez {amount}'**
  String cashCollectTitle(String amount);

  /// No description provided for @cashCollectBody.
  ///
  /// In fr, this message translates to:
  /// **'Le client paie maintenant, en espèces.'**
  String get cashCollectBody;

  /// No description provided for @cashCollectButton.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai reçu {amount}'**
  String cashCollectButton(String amount);

  /// No description provided for @deliveryDoneTitle.
  ///
  /// In fr, this message translates to:
  /// **'Livraison terminée'**
  String get deliveryDoneTitle;

  /// No description provided for @deliveryDoneBody.
  ///
  /// In fr, this message translates to:
  /// **'+{amount} pour cette mission.'**
  String deliveryDoneBody(String amount);

  /// No description provided for @problemTitle.
  ///
  /// In fr, this message translates to:
  /// **'Un problème ?'**
  String get problemTitle;

  /// No description provided for @problemCustomerUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'Client injoignable'**
  String get problemCustomerUnreachable;

  /// No description provided for @problemAddressNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Adresse introuvable'**
  String get problemAddressNotFound;

  /// No description provided for @problemRecipientAbsent.
  ///
  /// In fr, this message translates to:
  /// **'Destinataire absent'**
  String get problemRecipientAbsent;

  /// No description provided for @problemOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get problemOther;

  /// No description provided for @problemComment.
  ///
  /// In fr, this message translates to:
  /// **'Précisez le problème'**
  String get problemComment;

  /// No description provided for @problemReport.
  ///
  /// In fr, this message translates to:
  /// **'Signaler à l\'équipe'**
  String get problemReport;

  /// No description provided for @problemReported.
  ///
  /// In fr, this message translates to:
  /// **'Problème signalé à l\'équipe.'**
  String get problemReported;

  /// No description provided for @problemCallCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Appeler le client'**
  String get problemCallCustomer;

  /// No description provided for @problemCallSupport.
  ///
  /// In fr, this message translates to:
  /// **'Appeler le support'**
  String get problemCallSupport;

  /// No description provided for @problemDeclareFailure.
  ///
  /// In fr, this message translates to:
  /// **'Déclarer l\'échec de livraison'**
  String get problemDeclareFailure;

  /// No description provided for @problemFailureReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif de l\'échec'**
  String get problemFailureReason;

  /// No description provided for @kpiEarnings.
  ///
  /// In fr, this message translates to:
  /// **'Gains du jour'**
  String get kpiEarnings;

  /// No description provided for @kpiDeliveries.
  ///
  /// In fr, this message translates to:
  /// **'Missions livrées'**
  String get kpiDeliveries;

  /// No description provided for @kpiCash.
  ///
  /// In fr, this message translates to:
  /// **'Espèces à reverser'**
  String get kpiCash;

  /// No description provided for @courierHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get courierHistory;

  /// No description provided for @historyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique et gains'**
  String get historyTitle;

  /// No description provided for @historyToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get historyToday;

  /// No description provided for @historyWeek.
  ///
  /// In fr, this message translates to:
  /// **'7 derniers jours'**
  String get historyWeek;

  /// No description provided for @historyEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Vos missions apparaîtront ici'**
  String get historyEmpty;

  /// No description provided for @restaurantHandover.
  ///
  /// In fr, this message translates to:
  /// **'Remise au livreur'**
  String get restaurantHandover;

  /// No description provided for @restaurantCourier.
  ///
  /// In fr, this message translates to:
  /// **'Livreur : {name}'**
  String restaurantCourier(String name);

  /// No description provided for @adminConfirmWithoutCode.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la livraison sans code'**
  String get adminConfirmWithoutCode;

  /// No description provided for @adminConfirmReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif de la confirmation'**
  String get adminConfirmReason;

  /// No description provided for @adminDelivered.
  ///
  /// In fr, this message translates to:
  /// **'Livraison confirmée.'**
  String get adminDelivered;

  /// No description provided for @adminPaymentPaid.
  ///
  /// In fr, this message translates to:
  /// **'Payée'**
  String get adminPaymentPaid;

  /// No description provided for @adminPaymentUnpaid.
  ///
  /// In fr, this message translates to:
  /// **'Non encaissée'**
  String get adminPaymentUnpaid;

  /// No description provided for @supervisionAlertCodeLocked.
  ///
  /// In fr, this message translates to:
  /// **'Code bloqué : {count}'**
  String supervisionAlertCodeLocked(int count);

  /// No description provided for @supervisionAlertProblem.
  ///
  /// In fr, this message translates to:
  /// **'Problème signalé : {count}'**
  String supervisionAlertProblem(int count);

  /// No description provided for @eventCodeFailed.
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect'**
  String get eventCodeFailed;

  /// No description provided for @eventCodeLocked.
  ///
  /// In fr, this message translates to:
  /// **'Code bloqué'**
  String get eventCodeLocked;

  /// No description provided for @eventProblemReported.
  ///
  /// In fr, this message translates to:
  /// **'Problème signalé'**
  String get eventProblemReported;

  /// No description provided for @eventCourierChanged.
  ///
  /// In fr, this message translates to:
  /// **'Votre livreur a dû annuler, nous en cherchons un autre'**
  String get eventCourierChanged;

  /// No description provided for @missionFailedBody.
  ///
  /// In fr, this message translates to:
  /// **'L\'équipe est prévenue et décide de la suite avec le client.'**
  String get missionFailedBody;

  /// No description provided for @pushTitle.
  ///
  /// In fr, this message translates to:
  /// **'Être prévenu'**
  String get pushTitle;

  /// No description provided for @pushEnable.
  ///
  /// In fr, this message translates to:
  /// **'Activer les notifications'**
  String get pushEnable;

  /// No description provided for @pushClientBody.
  ///
  /// In fr, this message translates to:
  /// **'Recevez une notification à chaque étape : commande acceptée, livreur en route, livraison.'**
  String get pushClientBody;

  /// No description provided for @pushCourierBody.
  ///
  /// In fr, this message translates to:
  /// **'Recevez les nouvelles missions même quand l\'app est fermée.'**
  String get pushCourierBody;

  /// No description provided for @pushRestaurantBody.
  ///
  /// In fr, this message translates to:
  /// **'Recevez les nouvelles commandes même quand l\'app est fermée.'**
  String get pushRestaurantBody;

  /// No description provided for @pushReminder.
  ///
  /// In fr, this message translates to:
  /// **'Notifications désactivées : vous ne serez pas prévenu des étapes de la commande.'**
  String get pushReminder;

  /// No description provided for @pushReminderAction.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get pushReminderAction;

  /// No description provided for @trackingEta.
  ///
  /// In fr, this message translates to:
  /// **'Arrivée estimée : environ {minutes} min'**
  String trackingEta(int minutes);

  /// No description provided for @trackingEtaUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Position il y a {age} · estimation indisponible'**
  String trackingEtaUnavailable(String age);

  /// No description provided for @trackingConnectionLost.
  ///
  /// In fr, this message translates to:
  /// **'Connexion perdue — reconnexion…'**
  String get trackingConnectionLost;

  /// No description provided for @txPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get txPending;

  /// No description provided for @txSucceeded.
  ///
  /// In fr, this message translates to:
  /// **'Réussie'**
  String get txSucceeded;

  /// No description provided for @txFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échouée'**
  String get txFailed;

  /// No description provided for @txCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get txCancelled;

  /// No description provided for @txRefunded.
  ///
  /// In fr, this message translates to:
  /// **'Remboursée'**
  String get txRefunded;

  /// No description provided for @txDeliveredUnpaid.
  ///
  /// In fr, this message translates to:
  /// **'Livrée · non encaissée'**
  String get txDeliveredUnpaid;

  /// No description provided for @txEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune transaction pour l\'instant.'**
  String get txEmpty;

  /// No description provided for @paymentNoneAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun moyen de paiement n\'est disponible pour le moment.'**
  String get paymentNoneAvailable;

  /// No description provided for @failureAmountExceedsDue.
  ///
  /// In fr, this message translates to:
  /// **'Le montant dépasse les espèces dues par ce livreur.'**
  String get failureAmountExceedsDue;

  /// No description provided for @adminTransactions.
  ///
  /// In fr, this message translates to:
  /// **'Transactions et espèces'**
  String get adminTransactions;

  /// No description provided for @adminTabTransactions.
  ///
  /// In fr, this message translates to:
  /// **'Transactions'**
  String get adminTabTransactions;

  /// No description provided for @adminTabCash.
  ///
  /// In fr, this message translates to:
  /// **'Espèces'**
  String get adminTabCash;

  /// No description provided for @cashCollectedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Encaissé : {amount}'**
  String cashCollectedLabel(String amount);

  /// No description provided for @cashRemittedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Versé : {amount}'**
  String cashRemittedLabel(String amount);

  /// No description provided for @cashDueLabel.
  ///
  /// In fr, this message translates to:
  /// **'Dû'**
  String get cashDueLabel;

  /// No description provided for @cashRecord.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer un versement'**
  String get cashRecord;

  /// No description provided for @cashAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant versé (F)'**
  String get cashAmount;

  /// No description provided for @cashReference.
  ///
  /// In fr, this message translates to:
  /// **'Référence (reçu, note)'**
  String get cashReference;

  /// No description provided for @cashRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Versement enregistré.'**
  String get cashRecorded;

  /// No description provided for @cashEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune espèce encaissée pour l\'instant.'**
  String get cashEmpty;

  /// No description provided for @cashHistory.
  ///
  /// In fr, this message translates to:
  /// **'Encaissements et versements'**
  String get cashHistory;

  /// No description provided for @cashEntryCollected.
  ///
  /// In fr, this message translates to:
  /// **'Encaissement {number}'**
  String cashEntryCollected(String number);

  /// No description provided for @cashEntryRemitted.
  ///
  /// In fr, this message translates to:
  /// **'Versement'**
  String get cashEntryRemitted;

  /// No description provided for @settingsPaymentsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Moyens de paiement'**
  String get settingsPaymentsTitle;

  /// No description provided for @payUnpaid.
  ///
  /// In fr, this message translates to:
  /// **'À payer'**
  String get payUnpaid;

  /// No description provided for @payPaid.
  ///
  /// In fr, this message translates to:
  /// **'Payée'**
  String get payPaid;

  /// No description provided for @payRefundPending.
  ///
  /// In fr, this message translates to:
  /// **'Remboursement en cours'**
  String get payRefundPending;

  /// No description provided for @payRefunded.
  ///
  /// In fr, this message translates to:
  /// **'Remboursée'**
  String get payRefunded;

  /// No description provided for @eventRefundPending.
  ///
  /// In fr, this message translates to:
  /// **'Remboursement en cours'**
  String get eventRefundPending;

  /// No description provided for @eventRefunded.
  ///
  /// In fr, this message translates to:
  /// **'Remboursement effectué'**
  String get eventRefunded;

  /// No description provided for @receiptTitle.
  ///
  /// In fr, this message translates to:
  /// **'Reçu'**
  String get receiptTitle;

  /// No description provided for @receiptShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager le reçu'**
  String get receiptShare;

  /// No description provided for @receiptCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get receiptCopy;

  /// No description provided for @receiptCopied.
  ///
  /// In fr, this message translates to:
  /// **'Reçu copié.'**
  String get receiptCopied;

  /// No description provided for @receiptView.
  ///
  /// In fr, this message translates to:
  /// **'Voir le reçu'**
  String get receiptView;

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get filterAll;

  /// No description provided for @filterAnyPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Toute période'**
  String get filterAnyPeriod;

  /// No description provided for @filterAnyMethod.
  ///
  /// In fr, this message translates to:
  /// **'Tous les moyens'**
  String get filterAnyMethod;

  /// No description provided for @filterSucceeded.
  ///
  /// In fr, this message translates to:
  /// **'Réussies'**
  String get filterSucceeded;

  /// No description provided for @filterRefunds.
  ///
  /// In fr, this message translates to:
  /// **'Remboursements'**
  String get filterRefunds;

  /// No description provided for @dayToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get dayToday;

  /// No description provided for @dayYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get dayYesterday;

  /// No description provided for @txOrder.
  ///
  /// In fr, this message translates to:
  /// **'Commande'**
  String get txOrder;

  /// No description provided for @txAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get txAmount;

  /// No description provided for @txMethod.
  ///
  /// In fr, this message translates to:
  /// **'Moyen de paiement'**
  String get txMethod;

  /// No description provided for @txDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get txDate;

  /// No description provided for @txStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get txStatus;

  /// No description provided for @txReference.
  ///
  /// In fr, this message translates to:
  /// **'Référence'**
  String get txReference;

  /// No description provided for @txRefundPending.
  ///
  /// In fr, this message translates to:
  /// **'À rembourser'**
  String get txRefundPending;

  /// No description provided for @adminRequestRefund.
  ///
  /// In fr, this message translates to:
  /// **'Rembourser le client'**
  String get adminRequestRefund;

  /// No description provided for @adminRefundReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif du remboursement'**
  String get adminRefundReason;

  /// No description provided for @adminMarkRefunded.
  ///
  /// In fr, this message translates to:
  /// **'Marquer remboursée'**
  String get adminMarkRefunded;

  /// No description provided for @adminRefundReference.
  ///
  /// In fr, this message translates to:
  /// **'Référence du remboursement'**
  String get adminRefundReference;

  /// No description provided for @adminRefundRequested.
  ///
  /// In fr, this message translates to:
  /// **'Remboursement à effectuer.'**
  String get adminRefundRequested;

  /// No description provided for @adminRefunded.
  ///
  /// In fr, this message translates to:
  /// **'Remboursement enregistré.'**
  String get adminRefunded;

  /// No description provided for @adminDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get adminDashboard;

  /// No description provided for @periodDay.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get periodDay;

  /// No description provided for @periodWeek.
  ///
  /// In fr, this message translates to:
  /// **'7 jours'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In fr, this message translates to:
  /// **'30 jours'**
  String get periodMonth;

  /// No description provided for @statOrders.
  ///
  /// In fr, this message translates to:
  /// **'Commandes'**
  String get statOrders;

  /// No description provided for @statRevenue.
  ///
  /// In fr, this message translates to:
  /// **'Chiffre d\'affaires'**
  String get statRevenue;

  /// No description provided for @statFees.
  ///
  /// In fr, this message translates to:
  /// **'Frais de livraison'**
  String get statFees;

  /// No description provided for @statCommissions.
  ///
  /// In fr, this message translates to:
  /// **'Commissions'**
  String get statCommissions;

  /// No description provided for @statCourierEarnings.
  ///
  /// In fr, this message translates to:
  /// **'Rémunération des livreurs'**
  String get statCourierEarnings;

  /// No description provided for @statPlatform.
  ///
  /// In fr, this message translates to:
  /// **'Part de la plateforme'**
  String get statPlatform;

  /// No description provided for @statCash.
  ///
  /// In fr, this message translates to:
  /// **'Espèces à rapprocher'**
  String get statCash;

  /// No description provided for @statRefunds.
  ///
  /// In fr, this message translates to:
  /// **'Remboursements à effectuer'**
  String get statRefunds;

  /// No description provided for @statCouriersOnline.
  ///
  /// In fr, this message translates to:
  /// **'Livreurs en ligne'**
  String get statCouriersOnline;

  /// No description provided for @statByStatus.
  ///
  /// In fr, this message translates to:
  /// **'Par statut'**
  String get statByStatus;

  /// No description provided for @statByType.
  ///
  /// In fr, this message translates to:
  /// **'Par type'**
  String get statByType;

  /// No description provided for @statDeliveredOnly.
  ///
  /// In fr, this message translates to:
  /// **'Montants des commandes livrées sur la période.'**
  String get statDeliveredOnly;

  /// No description provided for @receiptText.
  ///
  /// In fr, this message translates to:
  /// **'Tchopi · Reçu {number}\n{date}\n{lines}\nTotal : {total}\nPaiement : {method} · {status}'**
  String receiptText(
    String number,
    String date,
    String lines,
    String total,
    String method,
    String status,
  );
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
