import 'package:intl/intl.dart';

final _grouping = NumberFormat.decimalPattern('fr');
final _oneDecimal = NumberFormat('#,##0.0', 'fr');

/// Espace fine (U+202F) d'intl remplacée par l'espace insécable (U+00A0), mieux rendue par la police.
String _spaces(String value) => value.replaceAll(' ', ' ');

/// « 1 300 FCFA » pour le franc CFA (sans décimales) ; code devise affiché pour les autres monnaies.
String formatMoney(int amount, {String currency = 'XOF'}) {
  final value = _spaces(_grouping.format(amount));
  return currency == 'XOF' ? '$value FCFA' : '$value $currency';
}

/// « 2,5 » : nombre à une décimale, virgule française (distances, taux).
String formatDecimal(num value) => _spaces(_oneDecimal.format(value));
