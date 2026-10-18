import 'package:core/src/auth/domain/login_identifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('identifiant de connexion', () {
    test('email normalisé en minuscules', () {
      final id = LoginIdentifier.parse('  Aicha.Kone@Exemple.CI ')!;
      expect(id.isEmail, isTrue);
      expect(id.value, 'aicha.kone@exemple.ci');
    });

    test('numéro ivoirien sans indicatif → format international', () {
      expect(LoginIdentifier.parse('07 00 00 00 01')!.value, '+2250700000001');
      expect(normalizePhone('05 44 18 31 08'), '+2250544183108');
    });

    test('numéro avec indicatif étranger accepté', () {
      expect(normalizePhone('+33 6 12 34 56 78'), '+33612345678');
    });

    test('saisies invalides refusées', () {
      expect(LoginIdentifier.parse('aicha@'), isNull);
      expect(LoginIdentifier.parse('12'), isNull);
      expect(LoginIdentifier.parse(''), isNull);
      expect(
        normalizePhone('27 22 00 00 00'),
        isNull,
        reason: 'fixe ivoirien : pas un mobile',
      );
    });

    test('masquage pour l\'affichage', () {
      expect(
        const LoginIdentifier.email('aicha@exemple.ci').masked,
        'a•••@exemple.ci',
      );
      expect(
        const LoginIdentifier.phone('+2250544183108').masked,
        '+•••••••••3108',
      );
    });
  });

  group('mot de passe', () {
    test('8 caractères, lettres et chiffres', () {
      expect(isValidPassword('motdepasse1'), isTrue);
      expect(isValidPassword('court1'), isFalse);
      expect(isValidPassword('sanschiffre'), isFalse);
      expect(isValidPassword('12345678'), isFalse);
    });
  });
}
