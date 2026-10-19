@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tchopi/features/client/payments/data/payment_repository.dart';
import 'package:tchopi/features/courier/missions/data/mission_repository.dart';
import 'package:tchopi/features/orders/data/order_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Carte de bout en bout (PAY-04, PAY-05, TRX-03) : Edge Functions locales face à un Stripe simulé sur le poste
/// (supabase/functions/.env pointe vers lui), webhooks signés comme ceux de Stripe, remboursement automatique
/// déclenché par la base.
void main() {
  setUpAll(() => HttpOverrides.global = null);

  const mockUrl = 'http://host.docker.internal:54391';
  final functionsEnv = File('supabase/functions/.env');
  final settings = {
    if (functionsEnv.existsSync())
      for (final line in functionsEnv.readAsLinesSync())
        if (line.contains('=') && !line.startsWith('#'))
          line.split('=').first: line.substring(line.indexOf('=') + 1),
  };
  final simulated = settings['STRIPE_API_URL'] == mockUrl;
  final webhookSecret = settings['STRIPE_WEBHOOK_SECRET'] ?? '';

  final env =
      jsonDecode(File('env/local.json').readAsStringSync())
          as Map<String, dynamic>;
  final url = env['SUPABASE_URL'] as String;
  final anonKey = env['SUPABASE_ANON_KEY'] as String;
  final stamp = DateTime.now().microsecondsSinceEpoch;
  final emails = {
    for (final role in ['client', 'livreur']) role: '$role$stamp@carte.ci',
  };
  final ids = <String, String>{};
  late SupabaseClient service;
  late HttpServer stripe;

  // Stripe simulé : sessions et remboursements idempotents, statut de la session réglé par le test.
  final sessions = <String, Map<String, String>>{};
  final requests = <Map<String, String>>[];
  final refunds = <Map<String, String>>[];
  var sessionStatus = 'open';
  var paymentStatus = 'unpaid';

  Future<void> serve(HttpRequest request) async {
    final path = request.uri.path;
    Future<Map<String, String>> form() async => {
      ...Uri.splitQueryString(await utf8.decodeStream(request)),
      'key': request.headers.value('Idempotency-Key')!,
    };
    if (request.method == 'POST' && path == '/v1/checkout/sessions') {
      final body = await form();
      requests.add(body);
      final id =
          sessions.entries
              .where((e) => e.value['key'] == body['key'])
              .map((e) => e.key)
              .firstOrNull ??
          'cs_test_${sessions.length + 1}';
      sessions[id] = body;
      request.response.write(jsonEncode(session(id, body)));
    } else if (request.method == 'GET' &&
        path.startsWith('/v1/checkout/sessions/')) {
      final id = path.split('/').last;
      request.response.write(
        jsonEncode({
          ...session(id, sessions[id]!),
          'status': sessionStatus,
          'payment_status': paymentStatus,
          'payment_intent': paymentStatus == 'paid' ? 'pi_test_1' : null,
        }),
      );
    } else if (request.method == 'POST' && path == '/v1/refunds') {
      refunds.add(await form());
      request.response.write(
        jsonEncode({
          'id': 're_test_1',
          'object': 'refund',
          'status': 'succeeded',
        }),
      );
    } else {
      request.response.statusCode = 404;
    }
    await request.response.close();
  }

  Future<int> webhook(String type, String transactionId, {String? key}) async {
    final body = jsonEncode({
      'id': 'evt_$stamp',
      'type': type,
      'data': {
        'object': {
          'object': 'checkout.session',
          'metadata': {'transaction_id': transactionId},
        },
      },
    });
    final timestamp =
        DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    final signature = Hmac(
      sha256,
      utf8.encode(key ?? webhookSecret),
    ).convert(utf8.encode('$timestamp.$body'));
    final client = HttpClient();
    final request = await client.postUrl(
      Uri.parse('$url/functions/v1/payments-webhook-stripe'),
    );
    request.headers.set('Stripe-Signature', 't=$timestamp,v1=$signature');
    request.write(body);
    final response = await request.close();
    await response.drain<void>();
    client.close();
    return response.statusCode;
  }

  Future<SupabaseClient> signedIn(String role) async {
    final client = SupabaseClient(url, anonKey);
    await client.auth.signInWithPassword(
      email: emails[role]!,
      password: 'motdepasse1',
    );
    return client;
  }

  setUpAll(() async {
    if (!simulated) return;
    stripe = await HttpServer.bind(InternetAddress.anyIPv4, 54391);
    stripe.listen(serve);
    final status = await Process.run('supabase', [
      'status',
      '-o',
      'env',
    ], runInShell: true);
    final serviceKey = RegExp(
      r'^SERVICE_ROLE_KEY="?([^"\r\n]+)',
      multiLine: true,
    ).firstMatch(status.stdout as String)!.group(1)!;
    service = SupabaseClient(url, serviceKey);
    for (final MapEntry(key: role, value: email) in emails.entries) {
      ids[role] = (await service.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: 'motdepasse1',
          emailConfirm: true,
        ),
      )).user!.id;
    }
    await service
        .from('profiles')
        .update({'first_name': 'Awa', 'phone': '+2250700000045'})
        .eq('id', ids['client']!);
    await service
        .from('payment_options')
        .update({'is_enabled': true})
        .eq('method', 'card');
    final zoneId =
        (await service
                .from('zones')
                .select('id')
                .eq('is_active', true)
                .limit(1)
                .single())['id']
            as String;
    await service.from('couriers').insert({
      'user_id': ids['livreur'],
      'zone_id': zoneId,
      'vehicle_type': 'motorbike',
      'plate_number': 'CB-001-CI',
      'photo_path': '${ids['livreur']}/p.jpg',
      'status': 'approved',
    });
    final courier = await signedIn('livreur');
    await MissionRepository(courier).setOnline(true);
    await MissionRepository(courier).reportLocation(5.36, -3.97, 10);
    await courier.dispose();
  });

  tearDownAll(() async {
    if (!simulated) return;
    await service
        .from('payment_options')
        .update({'is_enabled': false})
        .eq('method', 'card');
    await service.from('orders').delete().eq('customer_id', ids['client']!);
    for (final id in ids.values) {
      await service.auth.admin.deleteUser(id);
    }
    await service.dispose();
    await stripe.close(force: true);
  });

  test(
    'colis payé par carte : page Stripe, confirmation signée, annulation remboursée automatiquement',
    () async {
      if (!simulated) {
        markTestSkipped(
          'Stripe simulé requis : copier supabase/functions/.env.example vers .env',
        );
        return;
      }
      final clientClient = await signedIn('client');
      final client = OrderRepository(clientClient);
      final payments = PaymentRepository(clientClient);
      final type = (await client.parcelTypes(
        5.37,
        -3.95,
      )).firstWhere((t) => t.code == 'small');
      const pickup = ParcelPoint(
        lat: 5.36,
        lng: -3.97,
        district: 'Cocody',
        landmark: 'Carrefour de la vie',
      );
      const dropoff = ParcelPoint(
        lat: 5.32,
        lng: -4.02,
        district: 'Plateau',
        landmark: 'Tour A',
      );
      final quote = await client.quoteParcel(pickup, dropoff, type.id);
      final order = await client.placeParcel(
        pickup: pickup,
        dropoff: dropoff,
        recipientName: 'Koffi',
        recipientPhone: '+2250700000022',
        parcelTypeId: type.id,
        description: 'Documents',
        rulesAccepted: true,
        method: PaymentMethod.card,
        expectedTotal: quote.total,
        idempotencyKey: '00000000-0000-4000-d000-$stamp'.substring(0, 36),
      );
      expect(order.status, OrderStatus.awaitingPayment);
      Future<PaymentTransaction> transaction() async =>
          (await payments.watchOrder(order.id).first)!;
      final txId = (await transaction()).id;

      // Page Stripe : montant en francs (sans décimales), transaction en métadonnées ; double toucher = même page.
      final page = await payments.startOnlinePayment(order.id);
      expect(page, 'https://checkout.stripe.com/c/pay/cs_test_1');
      expect(await payments.startOnlinePayment(order.id), page);
      expect(requests, hasLength(1));
      final sent = requests.single;
      expect(sent['line_items[0][price_data][unit_amount]'], '${order.total}');
      expect(sent['line_items[0][price_data][currency]'], 'xof');
      expect(sent['metadata[transaction_id]'], txId);
      expect(sent['payment_method_types[0]'], 'card');
      expect(sent['success_url'], endsWith('/functions/v1/payments-return'));
      expect(sent['key'], '$txId-0');

      // Webhook mal signé : refusé ; annoncé payé mais pas confirmé par Stripe : sans effet.
      expect(
        await webhook('checkout.session.completed', txId, key: 'autre'),
        400,
      );
      expect(await webhook('checkout.session.completed', txId), 200);
      expect(
        (await client.fetch(order.id)).status,
        OrderStatus.awaitingPayment,
      );

      // Confirmé par Stripe : commande transmise une seule fois, même si le webhook est rejoué.
      sessionStatus = 'complete';
      paymentStatus = 'paid';
      expect(await webhook('checkout.session.completed', txId), 200);
      expect(await webhook('checkout.session.completed', txId), 200);
      final paid = await client.fetch(order.id);
      expect(paid.status, OrderStatus.searchingCourier);
      expect(paid.paymentStatus, OrderPaymentStatus.paid);
      expect((await transaction()).providerReference, 'pi_test_1');

      // Annulée par le client : remboursée par Stripe sans intervention (tâche planifiée → payments-refund).
      await client.cancel(order.id);
      var refunded = await client.fetch(order.id);
      final deadline = DateTime.now().add(const Duration(seconds: 45));
      while (refunded.paymentStatus != OrderPaymentStatus.refunded &&
          DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(seconds: 1));
        refunded = await client.fetch(order.id);
      }
      expect(refunded.paymentStatus, OrderPaymentStatus.refunded);
      expect(refunds, hasLength(1));
      expect(refunds.single['payment_intent'], 'pi_test_1');
      expect(refunds.single['key'], 'refund-$txId');
      final done = await transaction();
      expect(done.status, TransactionStatus.refunded);
      expect(done.refundReference, 're_test_1');
      await clientClient.dispose();
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

Map<String, Object?> session(String id, Map<String, String> body) => {
  'id': id,
  'object': 'checkout.session',
  'url': 'https://checkout.stripe.com/c/pay/$id',
  'status': 'open',
  'payment_status': 'unpaid',
  'amount_total': int.parse(body['line_items[0][price_data][unit_amount]']!),
  'currency': body['line_items[0][price_data][currency]'],
  'payment_intent': null,
};
