import 'package:freezed_annotation/freezed_annotation.dart';

import '../orders/models.dart';

part 'models.freezed.dart';
part 'models.g.dart';

enum TransactionStatus { pending, succeeded, failed, cancelled, refunded }

/// Moyen de paiement proposé dans un pays (PAY-01) ; seuls les moyens activés sont proposés.
@freezed
abstract class PaymentOption with _$PaymentOption {
  const factory PaymentOption({
    required String id,
    required String countryCode,
    required PaymentMethod method,
    String? operator,
    String? provider,
    required String label,
    required bool isEnabled,
    @Default(0) int position,
  }) = _PaymentOption;

  factory PaymentOption.fromJson(Map<String, dynamic> json) =>
      _$PaymentOptionFromJson(json);
}

/// Champ de la commande liée (`order:orders(...)`) : « order_number » lit « number », etc. (clés snake_case).
Object? _orderField(Map<dynamic, dynamic> json, String key) =>
    (json['order'] as Map<String, dynamic>?)?[key.substring('order_'.length)];

/// Transaction d'une commande (TRX-01) : montant égal au total, statut, moyen et référence du fournisseur.
@freezed
abstract class PaymentTransaction with _$PaymentTransaction {
  const factory PaymentTransaction({
    required String id,
    required String orderId,
    required int amount,
    @Default('XOF') String currency,
    required PaymentMethod method,
    String? operator,
    required TransactionStatus status,
    required DateTime createdAt,
    DateTime? succeededAt,
    @JsonKey(readValue: _orderField) String? orderNumber,
    @JsonKey(readValue: _orderField) OrderStatus? orderStatus,
    @JsonKey(readValue: _orderField) String? orderZoneId,
    @JsonKey(readValue: _orderField) OrderPaymentStatus? orderPaymentStatus,
    String? providerReference,
    String? refundReference,

    /// Mobile Money : refus de l'opérateur (« failed ») ou session annulée (« cancelled »).
    String? failureReason,

    /// Page de paiement du fournisseur (nyole, Stripe) à rouvrir pour payer ou réessayer.
    String? checkoutUrl,
  }) = _PaymentTransaction;

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) =>
      _$PaymentTransactionFromJson(json);
}

/// Espèces d'un livreur (ADM-04) : encaissées, versées, restant dues.
@freezed
abstract class CashBalance with _$CashBalance {
  const factory CashBalance({
    required String courierId,
    String? firstName,
    String? lastName,
    String? phone,
    required int collected,
    required int remitted,
    required int due,
  }) = _CashBalance;

  factory CashBalance.fromJson(Map<String, dynamic> json) =>
      _$CashBalanceFromJson(json);
}

/// Écriture du registre des espèces : encaissement d'une commande ou versement à la plateforme.
@freezed
abstract class CashEntry with _$CashEntry {
  const factory CashEntry({
    required int id,
    required String type,
    required int amount,
    String? reference,
    required DateTime createdAt,
    @JsonKey(readValue: _orderField) String? orderNumber,
  }) = _CashEntry;

  factory CashEntry.fromJson(Map<String, dynamic> json) =>
      _$CashEntryFromJson(json);
}
