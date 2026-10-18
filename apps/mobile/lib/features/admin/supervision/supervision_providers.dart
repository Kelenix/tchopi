import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'data/supervision_repository.dart';

part 'supervision_providers.g.dart';

@riverpod
SupervisionRepository supervisionRepository(Ref ref) =>
    SupervisionRepository(ref.watch(supabaseClientProvider));

@riverpod
Stream<List<Order>> activeOrders(Ref ref) =>
    ref.watch(supervisionRepositoryProvider).watchActive();

@riverpod
Future<List<DispatchCandidate>> dispatchCandidates(Ref ref, String orderId) =>
    ref.watch(supervisionRepositoryProvider).candidates(orderId);

@riverpod
Future<PlatformSettings> platformSettings(Ref ref) =>
    ref.watch(supervisionRepositoryProvider).settings();

/// Alertes du bandeau de supervision (ADM-03) : sans livreur après le délai d'alerte, restaurant silencieux
/// depuis la moitié de son délai de réponse. Code bloqué, échec et remboursement arrivent aux Inc-8 et 13.
enum OrderAlert { noCourier, restaurantSilent }

Set<OrderAlert> orderAlerts(
  Order order,
  PlatformSettings? settings,
  DateTime now,
) => {
  if (order.dispatchAlertedAt != null && order.courierId == null)
    OrderAlert.noCourier,
  if (order.status == OrderStatus.pending &&
      now.difference(order.createdAt).inSeconds >
          (settings?.restaurantTimeoutS ?? 600) ~/ 2)
    OrderAlert.restaurantSilent,
};
