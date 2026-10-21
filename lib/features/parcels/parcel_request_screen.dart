import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../../shared/pin_map.dart';
import '../client/addresses/application/addresses_providers.dart';
import '../client/payments/payments_providers.dart';
import '../client/payments/presentation/payment_choice.dart';
import '../orders/orders_providers.dart';
import '../orders/presentation/order_detail_screen.dart';
import '../orders/presentation/order_widgets.dart';

/// C-08 : demande de colis en 4 étapes — départ, arrivée, colis, récapitulatif (PAR-01 à PAR-03).
class ParcelRequestScreen extends ConsumerStatefulWidget {
  const ParcelRequestScreen({super.key});

  static const path = '/parcel/new';

  @override
  ConsumerState<ParcelRequestScreen> createState() =>
      _ParcelRequestScreenState();
}

class _ParcelRequestScreenState extends ConsumerState<ParcelRequestScreen> {
  static const _steps = 4;
  // Centre d'Abidjan, utilisé tant qu'aucune adresse n'est connue.
  static const _fallback = LatLng(5.3364, -4.0267);

  final _forms = List.generate(3, (_) => GlobalKey<FormState>());
  final _pickupMap = MapController();
  final _dropoffMap = MapController();
  final _pickupDistrict = TextEditingController();
  final _pickupLandmark = TextEditingController();
  final _dropoffDistrict = TextEditingController();
  final _dropoffLandmark = TextEditingController();
  final _dropoffInstructions = TextEditingController();
  final _recipientName = TextEditingController();
  final _recipientPhone = TextEditingController();
  final _description = TextEditingController();

  int _step = 0;

  /// Adresse enregistrée choisie comme départ ; null = point sur la carte.
  String? _pickupAddressId;
  bool _customPickup = false;
  LatLng? _pickupPoint;
  LatLng? _dropoffPoint;
  ParcelType? _type;
  bool _rulesAccepted = false;
  bool _rulesMissing = false;
  Future<FoodQuote>? _quote;
  String _idempotencyKey = const Uuid().v4();
  bool _placing = false;
  Object? _error;

  @override
  void dispose() {
    for (final controller in [
      _pickupDistrict,
      _pickupLandmark,
      _dropoffDistrict,
      _dropoffLandmark,
      _dropoffInstructions,
      _recipientName,
      _recipientPhone,
      _description,
    ]) {
      controller.dispose();
    }
    _pickupMap.dispose();
    _dropoffMap.dispose();
    super.dispose();
  }

  List<Address> get _addresses =>
      ref.read(addressesProvider).value ?? const <Address>[];

  Address? get _pickupAddress => _customPickup
      ? null
      : _addresses.where((a) => a.id == _pickupAddressId).firstOrNull ??
            _addresses.where((a) => a.isDefault).firstOrNull ??
            _addresses.firstOrNull;

  /// Ville de la zone desservie au point, pour les suggestions de quartiers.
  String? _cityOf(LatLng point) => cityAt(
    ref.read(activeZonesProvider).value ?? const [],
    point.latitude,
    point.longitude,
  );

  LatLng get _start {
    final address = _addresses.where((a) => a.isDefault).firstOrNull;
    return address == null
        ? _fallback
        : LatLng(address.latitude, address.longitude);
  }

  ParcelPoint get _pickup {
    final address = _pickupAddress;
    if (address != null) {
      return ParcelPoint(
        lat: address.latitude,
        lng: address.longitude,
        district: address.district,
        landmark: address.landmark,
        instructions: address.instructions,
      );
    }
    final point = _pickupPoint ?? _start;
    return ParcelPoint(
      lat: point.latitude,
      lng: point.longitude,
      district: _pickupDistrict.text,
      landmark: _pickupLandmark.text,
    );
  }

  ParcelPoint get _dropoff {
    final point = _dropoffPoint ?? _pickupPoint ?? _start;
    return ParcelPoint(
      lat: point.latitude,
      lng: point.longitude,
      district: _dropoffDistrict.text,
      landmark: _dropoffLandmark.text,
      instructions: _dropoffInstructions.text,
    );
  }

  void _next() {
    if (_step < 3 && !(_forms[_step].currentState?.validate() ?? true)) return;
    if (_step == 2) {
      if (!_rulesAccepted) {
        setState(() => _rulesMissing = true);
        return;
      }
      _quote = ref
          .read(orderRepositoryProvider)
          .quoteParcel(_pickup, _dropoff, _type!.id);
    }
    setState(() {
      _error = null;
      _step = (_step + 1).clamp(0, _steps - 1);
    });
  }

  void _back() {
    if (_step == 0) {
      context.pop();
    } else {
      setState(() {
        _error = null;
        _step--;
      });
    }
  }

  Future<void> _confirm(FoodQuote quote, PaymentMethod method) async {
    setState(() {
      _placing = true;
      _error = null;
    });
    try {
      final order = await ref
          .read(orderRepositoryProvider)
          .placeParcel(
            pickup: _pickup,
            dropoff: _dropoff,
            recipientName: _recipientName.text,
            recipientPhone: normalizePhone(_recipientPhone.text)!,
            parcelTypeId: _type!.id,
            description: _description.text,
            rulesAccepted: _rulesAccepted,
            method: method,
            expectedTotal: quote.total,
            idempotencyKey: _idempotencyKey,
          );
      ref.invalidate(myOrdersProvider);
      if (mounted) {
        context.pushReplacement(OrderDetailScreen.location(order.id));
      }
    } on AppFailure catch (failure) {
      if (!mounted) return;
      if (failure.code == 'price_changed') {
        _idempotencyKey = const Uuid().v4();
        _quote = ref
            .read(orderRepositoryProvider)
            .quoteParcel(_pickup, _dropoff, _type!.id);
      }
      setState(() => _error = failure);
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final titles = [
      (l10n.parcelStepPickup, l10n.parcelStepPickupBody),
      (l10n.parcelStepDropoff, l10n.parcelStepDropoffBody),
      (l10n.parcelStepDetails, l10n.parcelStepDetailsBody),
      (l10n.parcelStepSummary, l10n.parcelStepSummaryBody),
    ];
    final (title, subtitle) = titles[_step];

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.parcelTitle)),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    Space.screen,
                    Space.lg,
                    Space.screen,
                    Space.xxl,
                  ),
                  children: [
                    _StepDots(current: _step, total: _steps),
                    const SizedBox(height: Space.lg),
                    Text(title, style: text.displaySmall),
                    const SizedBox(height: Space.xs),
                    Text(
                      subtitle,
                      style: text.bodyLarge!.copyWith(color: tokens.muted),
                    ),
                    const SizedBox(height: Space.xl),
                    switch (_step) {
                      0 => _pickupStep(l10n),
                      1 => _dropoffStep(l10n),
                      2 => _detailsStep(l10n),
                      _ => _summaryStep(l10n),
                    },
                  ],
                ),
              ),
              _bottomBar(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomBar(AppLocalizations l10n) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.screen,
        Space.sm,
        Space.screen,
        Space.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null) ...[
            Text(
              failureMessage(l10n, _error),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(color: tokens.danger),
            ),
            const SizedBox(height: Space.md),
          ],
          if (_step < 3)
            FilledButton(
              onPressed: _step == 2 && _type == null ? null : _next,
              child: Text(l10n.actionContinue),
            )
          else
            FutureBuilder<FoodQuote>(
              future: _quote,
              builder: (context, snapshot) {
                final quote = snapshot.data;
                final method = chosenPayment(
                  ref.watch(paymentOptionsProvider).value ?? const [],
                  ref.watch(preferredPaymentProvider).value,
                );
                return FilledButton(
                  onPressed: quote == null || method == null || _placing
                      ? null
                      : () => _confirm(quote, method),
                  child: _placing
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Text(
                          quote == null
                              ? l10n.actionContinue
                              : l10n.parcelConfirm(formatMoney(quote.total)),
                        ),
                );
              },
            ),
        ],
      ),
    );
  }

  String? _required(String? value) => (value?.trim().length ?? 0) < 2
      ? AppLocalizations.of(context).errorRequired
      : null;

  Widget _mapBox(
    MapController controller,
    LatLng start,
    ValueChanged<LatLng> onMoved,
  ) => ClipRRect(
    borderRadius: BorderRadius.circular(Radii.card),
    child: SizedBox(
      height: 220,
      child: PinMap(
        controller: controller,
        initialCenter: start,
        onMoved: onMoved,
      ),
    ),
  );

  Widget _pickupStep(AppLocalizations l10n) {
    final tokens = context.tokens;
    final addresses = ref.watch(addressesProvider).value ?? const <Address>[];
    final selected = _pickupAddress;
    Widget choice({
      required bool active,
      required IconData icon,
      required String title,
      String? subtitle,
      required VoidCallback onTap,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: Space.md),
      child: Material(
        color: active ? tokens.primarySoft : tokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.field),
          side: BorderSide(
            color: active ? tokens.primary : tokens.border,
            width: active ? 1.6 : 1,
          ),
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.field),
          ),
          leading: Icon(icon, color: tokens.primary),
          title: Text(title),
          subtitle: subtitle == null ? null : Text(subtitle),
          trailing: Icon(
            active ? Icons.radio_button_checked : Icons.radio_button_off,
            color: tokens.primary,
          ),
          onTap: onTap,
        ),
      ),
    );
    return Form(
      key: _forms[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final address in addresses)
            choice(
              active: selected?.id == address.id,
              icon: Icons.place_outlined,
              title: '${address.district} · ${address.label}',
              subtitle: address.landmark,
              onTap: () => setState(() {
                _customPickup = false;
                _pickupAddressId = address.id;
              }),
            ),
          choice(
            active: selected == null,
            icon: Icons.map_outlined,
            title: l10n.parcelOtherPoint,
            onTap: () => setState(() => _customPickup = true),
          ),
          if (selected == null) ...[
            const SizedBox(height: Space.sm),
            _mapBox(
              _pickupMap,
              _pickupPoint ?? _start,
              (point) => _pickupPoint = point,
            ),
            const SizedBox(height: Space.lg),
            DistrictField(
              controller: _pickupDistrict,
              city: () => _cityOf(_pickupPoint ?? _start),
              validator: _required,
            ),
            const SizedBox(height: Space.md),
            TextFormField(
              controller: _pickupLandmark,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.fieldLandmark,
                hintText: l10n.fieldLandmarkHint,
                prefixIcon: const Icon(Icons.flag_outlined),
              ),
              validator: _required,
            ),
          ],
        ],
      ),
    );
  }

  Widget _dropoffStep(AppLocalizations l10n) => Form(
    key: _forms[1],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _mapBox(
          _dropoffMap,
          _dropoffPoint ?? LatLng(_pickup.lat, _pickup.lng),
          (point) => _dropoffPoint = point,
        ),
        const SizedBox(height: Space.sm),
        Text(
          l10n.addressMoveMap,
          style: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(color: context.tokens.muted),
        ),
        const SizedBox(height: Space.lg),
        DistrictField(
          controller: _dropoffDistrict,
          city: () =>
              _cityOf(_dropoffPoint ?? LatLng(_pickup.lat, _pickup.lng)),
          validator: _required,
        ),
        const SizedBox(height: Space.md),
        TextFormField(
          controller: _dropoffLandmark,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.fieldLandmark,
            hintText: l10n.fieldLandmarkHint,
            prefixIcon: const Icon(Icons.flag_outlined),
          ),
          validator: _required,
        ),
        const SizedBox(height: Space.md),
        TextFormField(
          controller: _dropoffInstructions,
          textCapitalization: TextCapitalization.sentences,
          minLines: 1,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: l10n.fieldInstructions,
            hintText: l10n.fieldInstructionsHint,
            prefixIcon: const Icon(Icons.notes_rounded),
          ),
        ),
      ],
    ),
  );

  Widget _detailsStep(AppLocalizations l10n) {
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final pickup = _pickup;
    final typesProvider = parcelTypesProvider(pickup.lat, pickup.lng);
    final types = ref.watch(typesProvider);
    return Form(
      key: _forms[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _recipientName,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.parcelRecipientName,
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
            validator: _required,
          ),
          const SizedBox(height: Space.md),
          TextFormField(
            controller: _recipientPhone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l10n.parcelRecipientPhone,
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            validator: (value) =>
                normalizePhone(value ?? '') == null ? l10n.errorPhone : null,
          ),
          const SizedBox(height: Space.xl),
          Text(l10n.parcelType, style: text.titleMedium),
          const SizedBox(height: Space.sm),
          for (final type in types.value ?? const <ParcelType>[])
            Padding(
              padding: const EdgeInsets.only(bottom: Space.sm),
              child: Material(
                color: _type?.id == type.id
                    ? tokens.primarySoft
                    : tokens.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Radii.field),
                  side: BorderSide(
                    color: _type?.id == type.id
                        ? tokens.primary
                        : tokens.border,
                  ),
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Radii.field),
                  ),
                  leading: Icon(switch (type.code) {
                    'documents' => Icons.description_outlined,
                    'small' => Icons.inventory_2_outlined,
                    _ => Icons.local_shipping_outlined,
                  }, color: tokens.primary),
                  title: Text(type.label),
                  trailing: Icon(
                    _type?.id == type.id
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: tokens.primary,
                  ),
                  onTap: () => setState(() => _type = type),
                ),
              ),
            ),
          const SizedBox(height: Space.md),
          TextFormField(
            controller: _description,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 300,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(labelText: l10n.parcelDescription),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _rulesAccepted,
            onChanged: (value) => setState(() {
              _rulesAccepted = value ?? false;
              _rulesMissing = false;
            }),
            title: Text(l10n.parcelRulesAccept),
            subtitle: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (context) => SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Space.screen,
                        0,
                        Space.screen,
                        Space.xxl,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.parcelRulesTitle, style: text.titleLarge),
                          const SizedBox(height: Space.md),
                          Text(l10n.parcelRulesBody, style: text.bodyLarge),
                        ],
                      ),
                    ),
                  ),
                ),
                child: Text(l10n.parcelRulesView),
              ),
            ),
          ),
          if (_rulesMissing)
            Text(
              l10n.parcelRulesRequired,
              style: text.labelLarge!.copyWith(color: tokens.danger),
            ),
        ],
      ),
    );
  }

  Widget _summaryStep(AppLocalizations l10n) {
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final pickup = _pickup;
    final dropoff = _dropoff;
    Widget point(Color color, String label, ParcelPoint p) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(Icons.circle, size: 12, color: color),
        ),
        const SizedBox(width: Space.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: text.bodySmall!.copyWith(color: tokens.muted)),
              Text(p.district, style: text.titleMedium),
              Text(
                p.landmark,
                style: text.bodySmall!.copyWith(color: tokens.muted),
              ),
            ],
          ),
        ),
      ],
    );
    return FutureBuilder<FoodQuote>(
      future: _quote,
      builder: (context, snapshot) {
        final quote = snapshot.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(Space.lg),
                child: Column(
                  children: [
                    point(tokens.ink, l10n.orderPickupTitle, pickup),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 2,
                          height: 20,
                          color: tokens.border,
                        ),
                      ),
                    ),
                    point(tokens.primary, l10n.orderDropoffTitle, dropoff),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Space.md),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: Text(_type!.label),
                    subtitle: _description.text.trim().isEmpty
                        ? null
                        : Text(_description.text.trim()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_outline_rounded),
                    title: Text(_recipientName.text.trim()),
                    subtitle: Text(normalizePhone(_recipientPhone.text) ?? ''),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.md),
            const PaymentChoice(parcel: true),
            const SizedBox(height: Space.lg),
            if (snapshot.hasError)
              Text(
                failureMessage(l10n, snapshot.error),
                style: text.labelLarge!.copyWith(color: tokens.danger),
              )
            else if (quote == null)
              const Center(child: CircularProgressIndicator())
            else ...[
              if (!quote.couriersAvailable) ...[
                const NoCourierBanner(),
                const SizedBox(height: Space.lg),
              ],
              AmountRow(
                label: l10n.parcelDistance,
                value: l10n.parcelDistanceValue(
                  formatDecimal(quote.distanceM / 1000),
                ),
              ),
              AmountRow(
                label: l10n.checkoutDeliveryFee,
                value: formatMoney(quote.deliveryFee),
              ),
              const Divider(height: Space.lg),
              AmountRow(
                label: l10n.checkoutTotal,
                value: formatMoney(quote.total),
                strong: true,
              ),
            ],
          ],
        );
      },
    );
  }
}

/// « ● ● ○ ○  2/4 » : progression du formulaire.
class _StepDots extends StatelessWidget {
  const _StepDots({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      children: [
        for (var i = 0; i < total; i++)
          AnimatedContainer(
            duration: Motion.normal,
            curve: Motion.curve,
            margin: const EdgeInsets.only(right: Space.xs),
            width: i == current ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i <= current ? tokens.primary : tokens.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        const Spacer(),
        Text(
          '${current + 1}/$total',
          style: Theme.of(
            context,
          ).textTheme.labelLarge!.copyWith(color: tokens.muted),
        ),
      ],
    );
  }
}
