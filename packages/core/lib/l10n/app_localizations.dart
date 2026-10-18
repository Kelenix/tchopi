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
