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
}
