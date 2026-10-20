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

/// Mobile Money de bout en bout (PAY-03, PAY-05) : Edge Functions locales face à un nyole simulé sur le poste
/// (supabase/functions/.env pointe vers lui), webhooks signés comme ceux de nyole.
void main() {
  setUpAll(() => HttpOverrides.global = null);

  const mockUrl = 'http://host.docker.internal:54390/api';
  final functionsEnv = File('supabase/functions/.env');
  final settings = {
    if (functionsEnv.existsSync())
      for (final line in functionsEnv.readAsLinesSync())
        if (line.contains('=') && !line.startsWith('#'))
          line.split('=').first: line.substring(line.indexOf('=') + 1),
  };
  final simulated = settings['NYOLE_API_URL'] == mockUrl;
  final secret = settings['NYOLE_SECRET_KEY'] ?? '';

  final env =
      jsonDecode(File('env/local.json').readAsStringSync())
          as Map<String, dynamic>;
  final url = env['SUPABASE_URL'] as String;
  final anonKey = env['SUPABASE_ANON_KEY'] as String;
  final stamp = DateTime.now().microsecondsSinceEpoch;
  final emails = {
    for (final role in ['client', 'livreur']) role: '$role$stamp@momo.ci',
  };
  final ids = <String, String>{};
  late SupabaseClient service;
  late HttpServer nyole;

  // nyole simulé : sessions idempotentes, statut réglé par le test.
  final sessions = <String, Map<String, dynamic>>{};
  final requests = <Map<String, dynamic>>[];
  var providerStatus = 'PENDING';

  Future<void> serve(HttpRequest request) async {
    final path = request.uri.path;
    if (request.method == 'POST' && path == '/api/v1/checkout/sessions') {
      final body =
          jsonDecode(await utf8.decodeStream(request)) as Map<String, dynamic>;
      final key = request.headers.value('Idempotency-Key')!;
      requests.add({...body, 'key': key});
      final id = sessions.entries
          .where((e) => e.value['key'] == key)
          .map((e) => e.key)
          .firstOrNull;
      final sessionId = id ?? 'sess_${sessions.length + 1}';
      sessions[sessionId] = {...body, 'key': key};
      request.response
        ..statusCode = id == null ? 201 : 200
        ..write(
          jsonEncode({
            'id': sessionId,
            'object': 'checkout.session',
            'url': 'https://app.nyole.com/checkout/$sessionId',
            'order_id': 'CS-TEST-$sessionId',
            'amount': body['amount'],
            'currency': body['currency'],
            'status': 'pending',
            'livemode': false,
          }),
        );
    } else if (request.method == 'GET' && path.endsWith('/status')) {
      final session = sessions[path.split('/')[5]]!;
      request.response.write(
        jsonEncode({
          'status': providerStatus,
          'paid': providerStatus == 'SUCCESS',
          'amount': session['amount'],
          'currency': session['currency'],
          'order_id': 'CS-TEST',
          'provider': 'sandbox',
        }),
      );
    } else {
      request.response.statusCode = 404;
    }
    await request.response.close();
  }

  Future<int> webhook(
    String event,
    String transactionId, {
    int? at,
    String? key,
  }) async {
    final body = jsonEncode({
      'event': event,
      'livemode': false,
      'data': {
        'metadata': {'transaction_id': transactionId},
      },
    });
    final timestamp =
        at ??
        DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    final signature = Hmac(
      sha256,
      utf8.encode(key ?? secret),
    ).convert(utf8.encode('$timestamp.$body'));
    final client = HttpClient();
    final request = await client.postUrl(
      Uri.parse('$url/functions/v1/payments-webhook-nyole'),
    );
    request.headers
      ..set('X-Afriflow-Timestamp', '$timestamp')
      ..set('X-Afriflow-Signature', 't=$timestamp,v1=$signature');
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
    nyole = await HttpServer.bind(InternetAddress.anyIPv4, 54390);
    nyole.listen(serve);
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
        .update({'first_name': 'Awa', 'phone': '+2250700000044'})
        .eq('id', ids['client']!);
    await service
        .from('payment_options')
        .update({'is_enabled': true})
        .eq('method', 'mobile_money');
    final zoneId =
        (await service
                .from('zones')
                .select('id')
                .eq('city', 'Abidjan')
                .limit(1)
                .single())['id']
            as String;
    await service.from('couriers').insert({
      'user_id': ids['livreur'],
      'zone_id': zoneId,
      'vehicle_type': 'motorbike',
      'plate_number': 'MM-001-CI',
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
        .eq('method', 'mobile_money');
    await service.from('orders').delete().eq('customer_id', ids['client']!);
    for (final id in ids.values) {
      await service.auth.admin.deleteUser(id);
    }
    await service.dispose();
    await nyole.close(force: true);
  });

  test(
    'colis payé par Mobile Money : page nyole, refus, nouvel essai, confirmation signée',
    () async {
      if (!simulated) {
        markTestSkipped(
          'nyole simulé requis : copier supabase/functions/.env.example vers .env',
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
        method: PaymentMethod.mobileMoney,
        expectedTotal: quote.total,
        idempotencyKey: '00000000-0000-4000-c000-$stamp'.substring(0, 36),
      );
      expect(order.status, OrderStatus.awaitingPayment);
      Future<PaymentTransaction> transaction() async =>
          (await payments.watchOrder(order.id).first)!;
      final txId = (await transaction()).id;

      // Page de paiement : montant de la commande, client prérempli ; double toucher = même session.
      final page = await payments.startOnlinePayment(order.id);
      expect(page, 'https://app.nyole.com/checkout/sess_1');
      expect(await payments.startOnlinePayment(order.id), page);
      expect(requests, hasLength(1));
      expect(requests.single['amount'], order.total);
      expect(requests.single['customer_phone'], '+2250700000044');
      expect(requests.single['metadata'], {
        'transaction_id': txId,
        'order_number': order.number,
      });
      expect(requests.single['key'], '$txId-0');

      // Webhooks non signés, mal signés ou trop anciens : refusés.
      expect(await webhook('payment.completed', txId, key: 'autre'), 400);
      expect(
        await webhook(
          'payment.completed',
          txId,
          at: DateTime.now().millisecondsSinceEpoch ~/ 1000 - 600,
        ),
        400,
      );

      // Refus de l'opérateur, puis nouvel essai sur la même page.
      providerStatus = 'FAILED';
      expect(await webhook('payment.failed', txId), 200);
      expect((await transaction()).status, TransactionStatus.failed);
      expect(await payments.startOnlinePayment(order.id), page);
      expect((await transaction()).status, TransactionStatus.pending);

      // Un webhook qui annonce un succès que nyole ne confirme pas ne change rien.
      providerStatus = 'PENDING';
      expect(await webhook('payment.completed', txId), 200);
      expect(
        (await client.fetch(order.id)).status,
        OrderStatus.awaitingPayment,
      );

      // Confirmé par nyole : commande transmise une seule fois, même si le webhook est rejoué.
      providerStatus = 'SUCCESS';
      expect(await webhook('payment.completed', txId), 200);
      expect(await webhook('payment.completed', txId), 200);
      final paid = await client.fetch(order.id);
      expect(paid.status, OrderStatus.searchingCourier);
      expect(paid.paymentStatus, OrderPaymentStatus.paid);
      final succeeded = await transaction();
      expect(succeeded.status, TransactionStatus.succeeded);
      expect(succeeded.providerReference, 'CS-TEST');
      await expectLater(
        payments.startOnlinePayment(order.id),
        throwsA(
          isA<AppFailure>().having((f) => f.code, 'code', 'already_paid'),
        ),
      );

      // ADR-039 : annulée après paiement, remboursée par l'équipe nyole (support) → « payment.updated » REFUNDED.
      await client.cancel(order.id);
      expect(
        (await client.fetch(order.id)).paymentStatus,
        OrderPaymentStatus.refundPending,
      );
      providerStatus = 'REFUNDED';
      expect(await webhook('payment.updated', txId), 200);
      expect(await webhook('payment.updated', txId), 200);
      expect(
        (await client.fetch(order.id)).paymentStatus,
        OrderPaymentStatus.refunded,
      );
      expect((await transaction()).status, TransactionStatus.refunded);
      await clientClient.dispose();
    },
  );
}
