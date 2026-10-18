import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/courier/profile/courier_providers.dart';
import 'package:mobile/features/courier/profile/presentation/courier_status_screen.dart';

Courier courier(CourierStatus status, {String? reason}) => Courier(
  userId: 'u',
  zoneId: 'z',
  vehicleType: VehicleType.motorbike,
  plateNumber: '4821 HJ 01',
  photoPath: 'u/photo.jpg',
  status: status,
  statusReason: reason,
);

Widget app(Courier value) => ProviderScope(
  overrides: [myCourierProvider.overrideWith((ref) async => value)],
  child: MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: const CourierStatusScreen(),
  ),
);

void main() {
  testWidgets('en attente : le livreur sait que son profil est vérifié', (
    tester,
  ) async {
    await tester.pumpWidget(app(courier(CourierStatus.pending)));
    await tester.pumpAndSettle();
    expect(find.text('Nous vérifions votre profil'), findsOneWidget);
    expect(find.text('Modifier mon profil'), findsOneWidget);
  });

  testWidgets('refusé : le motif est affiché et le profil peut être corrigé', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(courier(CourierStatus.rejected, reason: 'Photo illisible')),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Photo illisible'), findsOneWidget);
    expect(find.text('Modifier mon profil'), findsOneWidget);
  });

  testWidgets('suspendu : motif affiché, modification impossible', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(courier(CourierStatus.suspended, reason: 'Fraude')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Compte suspendu'), findsOneWidget);
    expect(find.text('Modifier mon profil'), findsNothing);
  });
}
