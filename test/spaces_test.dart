import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tchopi/features/admin/supervision/presentation/dashboard_screen.dart';
import 'package:tchopi/features/courier/missions/presentation/courier_home_screen.dart';
import 'package:tchopi/features/courier/profile/presentation/courier_profile_screen.dart';
import 'package:tchopi/features/courier/profile/presentation/courier_status_screen.dart';
import 'package:tchopi/spaces/spaces.dart';

void main() {
  const client = AccountRoles();
  const courier = AccountRoles(courierStatus: CourierStatus.pending);
  const admin = AccountRoles(
    isAdmin: true,
    courierStatus: CourierStatus.approved,
  );

  test("espaces ouverts selon les rôles, jamais l'Admin", () {
    expect(availableSpaces(client), [AppSpace.client]);
    expect(availableSpaces(courier), [AppSpace.client, AppSpace.courier]);
    expect(availableSpaces(admin), [AppSpace.client, AppSpace.courier]);
  });

  test('retour au dernier espace utilisé, sinon espace Client', () {
    expect(spaceHome(courier, AppSpace.courier), AppSpace.courier.home);
    expect(
      spaceHome(client, AppSpace.courier),
      AppSpace.client.home,
      reason: 'profil livreur supprimé',
    );
    expect(spaceHome(courier, null), AppSpace.client.home);
  });

  test("un établissement n'a que ses espaces professionnels", () {
    const owner = AccountRoles(restaurantIds: ['r1']);
    expect(availableSpaces(owner), [AppSpace.restaurant]);
    expect(spaceHome(owner, AppSpace.client), AppSpace.restaurant.home);
    for (final location in ['/home', '/cart', '/orders/42', '/addresses']) {
      expect(
        guardSpaces(location, owner),
        AppSpace.restaurant.home,
        reason: location,
      );
    }
    expect(guardSpaces('/restaurant/menu', owner), isNull);
  });

  test("un compte admin arrive toujours dans l'Admin", () {
    expect(spaceHome(admin, AppSpace.client), DashboardScreen.path);
    expect(spaceHome(admin, null), DashboardScreen.path);
  });

  test('écrans admin interdits sans droits admin', () {
    expect(guardSpaces('/admin/zones', client), SpaceRoutes.entry);
    expect(guardSpaces('/admin/zones', admin), isNull);
  });

  test("un compte admin reste dans l'Admin et « Mon compte »", () {
    expect(guardSpaces(AppRoutes.account, admin), isNull);
    expect(guardSpaces('/account/edit', admin), isNull);
    for (final location in [
      AppSpace.client.home,
      CourierHomeScreen.path,
      '/restaurant/menu',
      '/spaces',
    ]) {
      expect(
        guardSpaces(location, admin),
        DashboardScreen.path,
        reason: location,
      );
    }
  });

  test('espace Restaurant réservé aux gérants', () {
    const manager = AccountRoles(restaurantIds: ['r1']);
    expect(availableSpaces(manager), [AppSpace.restaurant]);
    expect(spaceHome(manager, AppSpace.restaurant), AppSpace.restaurant.home);
    expect(guardSpaces('/restaurant/menu', client), SpaceRoutes.entry);
    expect(guardSpaces('/restaurant/menu', manager), isNull);
  });

  test('espace Livreur sans profil : inscription livreur', () {
    expect(
      guardSpaces(CourierStatusScreen.path, client),
      CourierProfileScreen.path,
    );
    expect(guardSpaces(CourierStatusScreen.path, courier), isNull);
    expect(guardSpaces(CourierProfileScreen.path, client), isNull);
  });

  test('tableau de bord livreur réservé aux livreurs approuvés', () {
    expect(
      guardSpaces(CourierHomeScreen.path, client),
      CourierProfileScreen.path,
    );
    expect(
      guardSpaces(CourierHomeScreen.path, courier),
      CourierStatusScreen.path,
    );
    expect(
      guardSpaces(
        CourierHomeScreen.path,
        const AccountRoles(courierStatus: CourierStatus.approved),
      ),
      isNull,
    );
  });
}
