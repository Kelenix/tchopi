import 'package:core/core.dart';
import 'package:core/src/auth/presentation/phone_auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app({required bool phone, required AuthEntryConfig config}) =>
    ProviderScope(
      overrides: [
        loginMethodsProvider.overrideWith(
          (ref) async => (email: true, phone: phone),
        ),
        authEntryConfigProvider.overrideWith((ref) async => config),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const PhoneAuthScreen(oauthRedirect: 'app://login-callback'),
      ),
    );

void main() {
  // Écran de téléphone courant (360 × 800 points).
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1080, 2400);
    view.devicePixelRatio = 3;
  });
  tearDown(
    () => TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
      ..resetPhysicalSize()
      ..resetDevicePixelRatio(),
  );

  testWidgets('bannière et WhatsApp affichés selon les réglages du serveur', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        phone: true,
        config: (
          bannerTitle: 'Livraison offerte',
          bannerBody: 'Sur votre première commande.',
          whatsapp: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Livraison offerte'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('SMS'), findsOneWidget);
  });

  testWidgets(
    'numéro invalide signalé avant tout envoi ; e-mail dans « Autres méthodes »',
    (tester) async {
      await tester.pumpWidget(
        app(
          phone: true,
          config: (bannerTitle: null, bannerBody: null, whatsapp: false),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('WhatsApp'), findsNothing);
      await tester.enterText(find.byType(TextField), '12');
      await tester.tap(find.text('SMS'));
      await tester.pumpAndSettle();
      expect(find.text('Saisissez un numéro de mobile valide'), findsOneWidget);

      expect(find.text('Se connecter avec un e-mail'), findsNothing);
      await tester.tap(find.text('Autres méthodes'));
      await tester.pumpAndSettle();
      expect(find.text('Se connecter avec un e-mail'), findsOneWidget);
    },
  );

  testWidgets('sans fournisseur SMS, le code par téléphone est indisponible', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        phone: false,
        config: (bannerTitle: null, bannerBody: null, whatsapp: false),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'SMS'))
          .onPressed,
      isNull,
    );
  });
}
