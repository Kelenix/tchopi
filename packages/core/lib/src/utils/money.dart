import 'package:intl/intl.dart';

final _grouping = NumberFormat.decimalPattern('fr');

/// « 1 300 F » pour le franc CFA (sans décimales) ; code devise affiché pour les autres monnaies.
String formatMoney(int amount, {String currency = 'XOF'}) {
  final value = _grouping.format(amount).replaceAll(' ', ' ');
  return currency == 'XOF' ? '$value F' : '$value $currency';
}
