import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/courier/profile/presentation/courier_profile_screen.dart';
import 'package:mobile/features/courier/profile/presentation/courier_status_screen.dart';
import 'package:mobile/spaces/spaces.dart';

void main() {
  const client = AccountRoles();
  const courier = AccountRoles(courierStatus: CourierStatus.pending);
  const admin = AccountRoles(
    isAdmin: true,
    courierStatus: CourierStatus.approved,
  );

  test('espaces ouverts selon les rôles', () {
    expect(availableSpaces(client), [AppSpace.client]);
    expect(availableSpaces(courier), [AppSpace.client, AppSpace.courier]);
    expect(availableSpaces(admin), [
      AppSpace.client,
      AppSpace.courier,
      AppSpace.admin,
    ]);
  });

  test('retour au dernier espace utilisé, sinon espace Client', () {
    expect(spaceHome(admin, AppSpace.admin), AppSpace.admin.home);
    expect(
      spaceHome(client, AppSpace.admin),
      AppSpace.client.home,
      reason: 'droits admin retirés',
    );
    expect(spaceHome(courier, null), AppSpace.client.home);
  });

  test('écrans admin interdits sans droits admin', () {
    expect(guardSpaces('/admin/zones', client), SpaceRoutes.entry);
    expect(guardSpaces('/admin/zones', admin), isNull);
  });

  test('espace Livreur sans profil : inscription livreur', () {
    expect(
      guardSpaces(CourierStatusScreen.path, client),
      CourierProfileScreen.path,
    );
    expect(guardSpaces(CourierStatusScreen.path, courier), isNull);
    expect(guardSpaces(CourierProfileScreen.path, client), isNull);
  });
}
