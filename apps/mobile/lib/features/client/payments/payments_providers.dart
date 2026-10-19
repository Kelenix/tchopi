import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/payment_repository.dart';

part 'payments_providers.g.dart';

@riverpod
PaymentRepository paymentRepository(Ref ref) =>
    PaymentRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<List<PaymentOption>> paymentOptions(Ref ref) =>
    ref.watch(paymentRepositoryProvider).options();

@riverpod
Future<List<PaymentTransaction>> myTransactions(Ref ref) =>
    ref.watch(paymentRepositoryProvider).mine();

/// PAY-01 : le dernier moyen choisi est proposé à la commande suivante.
@Riverpod(keepAlive: true)
class PreferredPayment extends _$PreferredPayment {
  static const _key = 'payment_method';

  @override
  Future<PaymentMethod?> build() async {
    final saved = await SharedPreferencesAsync().getString(_key);
    return PaymentMethod.values.where((m) => m.name == saved).firstOrNull;
  }

  Future<void> select(PaymentMethod method) async {
    state = AsyncData(method);
    await SharedPreferencesAsync().setString(_key, method.name);
  }
}

/// Moyen retenu : le préféré s'il est encore proposé, sinon le premier disponible.
PaymentMethod? chosenPayment(
  List<PaymentOption> options,
  PaymentMethod? preferred,
) => options.any((o) => o.method == preferred)
    ? preferred
    : options.firstOrNull?.method;
