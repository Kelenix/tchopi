import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Disponibilité, position, offres et missions du livreur connecté (COU-05, DIS-02, MIS-01 à MIS-10).
/// Chaque étape est validée par le serveur ; le code de livraison n'est jamais lisible ici.
class MissionRepository {
  MissionRepository(this._client);

  final SupabaseClient _client;

  Future<void> setOnline(bool online) => guardCall(
    () => _client.rpc<void>('set_courier_online', params: {'p_online': online}),
  );

  Future<void> reportLocation(double lat, double lng, double accuracyM) =>
      guardCall(
        () => _client.rpc<void>(
          'report_location',
          params: {'p_lat': lat, 'p_lng': lng, 'p_accuracy_m': accuracyM},
        ),
      );

  /// Commandes proposées au livreur, en attente de réponse, en temps réel (la RLS ne livre que les siennes).
  Stream<List<DeliveryOffer>> watchPendingOffers(String courierId) => _client
      .from('delivery_offers')
      .stream(primaryKey: ['id'])
      .eq('courier_id', courierId)
      .order('created_at')
      .limit(50)
      .map(
        (rows) => rows
            .map(DeliveryOffer.fromJson)
            .where((offer) => offer.status == OfferStatus.pending)
            .toList(),
      )
      .handleError((Object error) => throw toFailure(error));

  Future<void> respond(String offerId, {required bool accept}) => guardCall(
    () => _client.rpc<void>(
      'respond_to_offer',
      params: {'p_offer_id': offerId, 'p_accept': accept},
    ),
  );

  /// Mission en cours : commande attribuée et non close, en temps réel.
  Stream<Order?> watchMission(String courierId) => _client
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('courier_id', courierId)
      .order('created_at')
      .limit(10)
      .map(
        (rows) => rows
            .map((row) => Order.fromJson({...row, 'order_items': <Object>[]}))
            .where((order) => !order.status.isClosed)
            .firstOrNull,
      )
      .handleError((Object error) => throw toFailure(error));

  /// Une mission précise, en temps réel (lisible jusqu'à une heure après sa fin).
  Stream<Order?> watchOrder(String orderId) => _client
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('id', orderId)
      .map(
        (rows) => rows.isEmpty
            ? null
            : Order.fromJson({...rows.first, 'order_items': <Object>[]}),
      )
      .handleError((Object error) => throw toFailure(error));

  Future<void> _rpc(String name, Map<String, Object?> params) =>
      guardCall(() => _client.rpc<void>(name, params: params));

  /// Colis en espèces : [cashReceived] confirme le paiement de l'expéditeur (MIS-04).
  Future<void> confirmPickup(String orderId, {bool cashReceived = false}) =>
      _rpc('confirm_pickup', {
        'p_order_id': orderId,
        'p_cash_received': cashReceived,
      });

  Future<void> startDelivery(String orderId) =>
      _rpc('start_delivery', {'p_order_id': orderId});

  Future<CodeResult> confirmDelivery(String orderId, String code) =>
      guardCall(() async {
        final json = await _client.rpc<Map<String, dynamic>>(
          'confirm_delivery',
          params: {'p_order_id': orderId, 'p_code': code},
        );
        return CodeResult.fromJson(json);
      });

  Future<void> confirmCash(String orderId) =>
      _rpc('confirm_cash_collected', {'p_order_id': orderId});

  Future<void> reportProblem(String orderId, String kind, String? comment) =>
      _rpc('report_problem', {
        'p_order_id': orderId,
        'p_kind': kind,
        'p_comment': comment,
      });

  Future<void> declareFailure(String orderId, String reason) =>
      _rpc('declare_failure', {'p_order_id': orderId, 'p_reason': reason});

  Future<void> release(String orderId, String reason) =>
      _rpc('release_mission', {'p_order_id': orderId, 'p_reason': reason});

  Future<CourierSummary> summary() => guardCall(() async {
    final json = await _client.rpc<Map<String, dynamic>>('courier_summary');
    return CourierSummary.fromJson(json);
  });

  Future<List<MissionRecord>> history() => guardCall(() async {
    final rows = await _client.rpc<List<dynamic>>('courier_missions');
    return rows
        .cast<Map<String, dynamic>>()
        .map(MissionRecord.fromJson)
        .toList();
  });

  /// Numéro du support (paramètres de la plateforme), s'il est renseigné.
  Future<String?> supportPhone() => guardCall(() async {
    final row = await _client.from('settings').select('support_phone').single();
    return row['support_phone'] as String?;
  });

  /// Offres refusées des 7 derniers jours ; `reopenable` : la commande attend encore un livreur.
  Future<List<DeclinedOffer>> declinedOffers() => guardCall(() async {
    final rows = await _client.rpc<List<dynamic>>('courier_declined_offers');
    return [
      for (final r in rows.cast<Map<String, dynamic>>())
        (
          id: r['id'] as String,
          summary: OfferSummary.fromJson(r['summary'] as Map<String, dynamic>),
          respondedAt: DateTime.parse(r['responded_at'] as String),
          reopenable: r['reopenable'] as bool,
        ),
    ];
  });

  /// Revenir sur un refus : l'offre redevient en attente (acceptée ensuite comme les autres).
  Future<void> reconsider(String offerId) => guardCall(
    () => _client.rpc<void>(
      'courier_reconsider_offer',
      params: {'p_offer_id': offerId},
    ),
  );

  /// Livraisons du livreur sur une période, filtrées et paginées par le serveur (`courier_deliveries`).
  Future<DeliveryPage> deliveries({
    required DateTime from,
    required DateTime to,
    String? status,
    String? query,
    int offset = 0,
    int limit = 20,
  }) => guardCall(() async {
    final data = await _client.rpc<Map<String, dynamic>>(
      'courier_deliveries',
      params: {
        'p_from': from.toUtc().toIso8601String(),
        'p_to': to.toUtc().toIso8601String(),
        'p_status': status,
        'p_query': query,
        'p_limit': limit,
        'p_offset': offset,
      },
    );
    return DeliveryPage(
      summary: Map<String, num>.from(data['summary'] as Map),
      total: data['total'] as int,
      rows: [
        for (final row in data['rows'] as List)
          Map<String, dynamic>.from(row as Map),
      ],
    );
  });
}

typedef DeclinedOffer = ({
  String id,
  OfferSummary summary,
  DateTime respondedAt,
  bool reopenable,
});

/// Page de livraisons : résumé de la période, nombre filtré, lignes (champs de `courier_deliveries`).
class DeliveryPage {
  const DeliveryPage({
    required this.summary,
    required this.total,
    required this.rows,
  });

  final Map<String, num> summary;
  final int total;
  final List<Map<String, dynamic>> rows;
}
