import 'package:core/core.dart';
import 'package:flutter/material.dart' show DateUtils;
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

/// Période du tableau de bord, en jours jusqu'à maintenant (1, 7 ou 30).
@riverpod
Future<Map<String, dynamic>> adminStats(Ref ref, int days) {
  final now = DateTime.now();
  final from = DateUtils.dateOnly(now).subtract(Duration(days: days - 1));
  return ref
      .watch(supervisionRepositoryProvider)
      .stats(from, now.add(const Duration(minutes: 1)));
}

@riverpod
Future<PlatformSettings> platformSettings(Ref ref) =>
    ref.watch(supervisionRepositoryProvider).settings();

/// Alertes du bandeau de supervision (ADM-03) : sans livreur après le délai d'alerte, restaurant silencieux
/// depuis la moitié de son délai de réponse, code de livraison bloqué, problème signalé ou échec.
/// Paiement à rembourser : Inc-13.
enum OrderAlert { noCourier, restaurantSilent, codeLocked, problem }

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
  if (order.codeLockedAt != null && !order.status.isClosed)
    OrderAlert.codeLocked,
  if (order.problemReportedAt != null &&
      (!order.status.isClosed || order.status == OrderStatus.failed))
    OrderAlert.problem,
};
