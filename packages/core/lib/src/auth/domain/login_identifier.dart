import 'package:phone_numbers_parser/phone_numbers_parser.dart';

enum IdentifierKind { email, phone }

/// Identifiant de connexion normalisé : email en minuscules ou numéro mobile au format E.164.
class LoginIdentifier {
  const LoginIdentifier.email(String email)
    : kind = IdentifierKind.email,
      value = email;
  const LoginIdentifier.phone(String phone)
    : kind = IdentifierKind.phone,
      value = phone;

  final IdentifierKind kind;
  final String value;

  bool get isEmail => kind == IdentifierKind.email;

  /// Reconnaît un email (présence de « @ ») ou un numéro ; `null` si la saisie n'est pas valide.
  static LoginIdentifier? parse(String input) {
    final text = input.trim();
    if (text.contains('@')) {
      return isValidEmail(text)
          ? LoginIdentifier.email(text.toLowerCase())
          : null;
    }
    final phone = normalizePhone(text);
    return phone == null ? null : LoginIdentifier.phone(phone);
  }

  /// Version masquée pour l'affichage (« k•••@gmail.com », « +225 •• •• •• 31 08 »).
  String get masked {
    if (isEmail) {
      final at = value.indexOf('@');
      return '${value[0]}•••${value.substring(at)}';
    }
    return '${value.substring(0, value.length - 4).replaceAll(RegExp(r'\d'), '•')}'
        '${value.substring(value.length - 4)}';
  }
}

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');

bool isValidEmail(String input) => _emailPattern.hasMatch(input.trim());

/// Numéro mobile valide → format E.164 ; sans indicatif, la Côte d'Ivoire (+225) est supposée.
String? normalizePhone(String input) {
  if (input.trim().isEmpty) return null;
  try {
    final number = PhoneNumber.parse(input, callerCountry: IsoCode.CI);
    return number.isValid(type: PhoneNumberType.mobile)
        ? number.international
        : null;
  } on PhoneNumberException {
    return null;
  }
}

/// Règle commune à l'app et au serveur : 8 caractères minimum, lettres et chiffres.
bool isValidPassword(String input) =>
    input.length >= 8 &&
    input.contains(RegExp(r'[A-Za-z]')) &&
    input.contains(RegExp(r'\d'));
