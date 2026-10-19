import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/admin_zone_repository.dart';
import '../zones_providers.dart';

/// A-08 : zone (centre, rayon, activation), règles tarifaires repas et colis, simulateur (ADR-06, ADR-07).
class ZoneFormScreen extends ConsumerStatefulWidget {
  const ZoneFormScreen({super.key, this.zone});

  final Zone? zone;

  @override
  ConsumerState<ZoneFormScreen> createState() => _ZoneFormScreenState();
}

class _ZoneFormScreenState extends ConsumerState<ZoneFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _city, _lat, _lng, _radiusKm;
  late bool _active;
  final _pricing = {
    for (final service in Service.values)
      service: _PricingFields.defaults(service),
  };
  bool _saving = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    final zone = widget.zone;
    _name = TextEditingController(text: zone?.name);
    _city = TextEditingController(text: zone?.city ?? 'Abidjan');
    _lat = TextEditingController(text: zone?.centerLat.toString());
    _lng = TextEditingController(text: zone?.centerLng.toString());
    _radiusKm = TextEditingController(
      text: zone == null ? '' : (zone.radiusM / 1000).toString(),
    );
    _active = zone?.isActive ?? true;
    if (zone != null) _loadPricing(zone.id);
  }

  Future<void> _loadPricing(String zoneId) async {
    final rules = await ref.read(zonePricingProvider(zoneId).future);
    if (!mounted) return;
    setState(() {
      for (final rule in rules) {
        _pricing[rule.service]!.fill(rule);
      }
    });
  }

  @override
  void dispose() {
    for (final controller in [_name, _city, _lat, _lng, _radiusKm]) {
      controller.dispose();
    }
    for (final fields in _pricing.values) {
      fields.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final saved = AppLocalizations.of(context).zoneSaved;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final zone = Zone(
        id: widget.zone?.id ?? '',
        name: _name.text,
        city: _city.text,
        centerLat: double.parse(_lat.text.replaceAll(',', '.')),
        centerLng: double.parse(_lng.text.replaceAll(',', '.')),
        radiusM: (double.parse(_radiusKm.text.replaceAll(',', '.')) * 1000)
            .round(),
        isActive: _active,
      );
      await ref.read(adminZoneRepositoryProvider).save(zone, [
        for (final MapEntry(:key, :value) in _pricing.entries)
          value.toRule(key),
      ], isNew: widget.zone == null);
      ref
        ..invalidate(adminZonesProvider)
        ..invalidate(activeZonesProvider);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(saved)));
      context.pop();
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _error = failure);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    String? required(String? value) =>
        (value?.trim().isEmpty ?? true) ? l10n.errorRequired : null;
    String? Function(String?) number({
      double min = 0,
      double max = double.infinity,
    }) => (value) {
      final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
      return parsed == null || parsed < min || parsed > max
          ? l10n.errorNumber
          : null;
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.zone == null ? l10n.zoneNewTitle : l10n.zoneEditTitle,
        ),
      ),
      body: Form(
        key: _form,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(Space.screen),
              children: [
                _Section(
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: InputDecoration(
                        labelText: l10n.fieldZoneName,
                      ),
                      validator: required,
                    ),
                    CityField(
                      initialValue: _city.text.isEmpty ? null : _city.text,
                      onChanged: (city) => _city.text = city,
                    ),
                    _Row(
                      children: [
                        _NumberField(
                          controller: _lat,
                          label: l10n.fieldCenterLat,
                          validator: number(min: -90, max: 90),
                          signed: true,
                        ),
                        _NumberField(
                          controller: _lng,
                          label: l10n.fieldCenterLng,
                          validator: number(min: -180, max: 180),
                          signed: true,
                        ),
                      ],
                    ),
                    _NumberField(
                      controller: _radiusKm,
                      label: l10n.fieldRadiusKm,
                      validator: number(min: 0.5, max: 100),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        icon: const Icon(Icons.map_outlined),
                        label: Text(l10n.zoneViewOnMap),
                        onPressed: () => launchUrl(
                          Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=${_lat.text},${_lng.text}',
                          ),
                        ),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.zoneActive),
                      value: _active,
                      onChanged: (value) => setState(() => _active = value),
                    ),
                  ],
                ),
                for (final service in Service.values) ...[
                  const SizedBox(height: Space.xl),
                  Text(
                    service == Service.food
                        ? l10n.pricingFood
                        : l10n.pricingParcel,
                    style: text.titleMedium,
                  ),
                  const SizedBox(height: Space.md),
                  _PricingSection(fields: _pricing[service]!, number: number),
                ],
                const SizedBox(height: Space.xl),
                Text(l10n.simulatorTitle, style: text.titleMedium),
                const SizedBox(height: Space.md),
                widget.zone == null
                    ? Text(
                        l10n.simulatorSaveFirst,
                        style: text.bodyMedium!.copyWith(color: tokens.muted),
                      )
                    : _Simulator(zone: widget.zone!),
                if (_error != null) ...[
                  const SizedBox(height: Space.lg),
                  Text(
                    failureMessage(l10n, _error),
                    style: text.labelLarge!.copyWith(color: tokens.danger),
                  ),
                ],
                const SizedBox(height: Space.xl),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Text(l10n.actionSave),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Champs d'une règle tarifaire, préremplis avec des valeurs indicatives pour une nouvelle zone.
class _PricingFields {
  _PricingFields(List<num> values)
    : controllers = [
        for (final value in values) TextEditingController(text: '$value'),
      ];

  factory _PricingFields.defaults(Service service) => _PricingFields(
    service == Service.food
        ? [500, 150, 500, 3000, 1.3, 25, 400, 100]
        : [700, 175, 700, 4000, 1.3, 25, 500, 120],
  );

  /// Ordre : base, prix/km, plancher, plafond, détour, arrondi, livreur fixe, livreur par km.
  final List<TextEditingController> controllers;

  void fill(PricingRule rule) {
    final values = [
      rule.baseFee,
      rule.perKmFee,
      rule.minFee,
      rule.maxFee,
      rule.detourFactor,
      rule.roundingStep,
      rule.courierBase,
      rule.courierPerKm,
    ];
    for (var i = 0; i < values.length; i++) {
      controllers[i].text = '${values[i]}';
    }
  }

  int _int(int index) =>
      double.parse(controllers[index].text.replaceAll(',', '.')).round();

  PricingRule toRule(Service service) => PricingRule(
    zoneId: '',
    service: service,
    baseFee: _int(0),
    perKmFee: _int(1),
    minFee: _int(2),
    maxFee: _int(3),
    detourFactor: double.parse(controllers[4].text.replaceAll(',', '.')),
    roundingStep: _int(5),
    courierBase: _int(6),
    courierPerKm: _int(7),
  );

  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
  }
}

class _PricingSection extends StatelessWidget {
  const _PricingSection({required this.fields, required this.number});

  final _PricingFields fields;
  final String? Function(String?) Function({double min, double max}) number;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = fields.controllers;
    String? minMax(String? _) {
      final min = double.tryParse(c[2].text);
      final max = double.tryParse(c[3].text);
      return min != null && max != null && min > max ? l10n.errorMinMax : null;
    }

    return _Section(
      children: [
        _Row(
          children: [
            _NumberField(
              controller: c[0],
              label: l10n.fieldBaseFee,
              validator: number(),
            ),
            _NumberField(
              controller: c[1],
              label: l10n.fieldPerKm,
              validator: number(),
            ),
          ],
        ),
        _Row(
          children: [
            _NumberField(
              controller: c[2],
              label: l10n.fieldMinFee,
              validator: (v) => number()(v) ?? minMax(v),
            ),
            _NumberField(
              controller: c[3],
              label: l10n.fieldMaxFee,
              validator: number(),
            ),
          ],
        ),
        _Row(
          children: [
            _NumberField(
              controller: c[4],
              label: l10n.fieldDetour,
              validator: number(min: 1, max: 3),
            ),
            _NumberField(
              controller: c[5],
              label: l10n.fieldRounding,
              validator: number(min: 1, max: 1000),
            ),
          ],
        ),
        _Row(
          children: [
            _NumberField(
              controller: c[6],
              label: l10n.fieldCourierBase,
              validator: number(),
            ),
            _NumberField(
              controller: c[7],
              label: l10n.fieldCourierPerKm,
              validator: number(),
            ),
          ],
        ),
      ],
    );
  }
}

/// Calcule les frais d'une distance avec les règles enregistrées (même calcul que les commandes).
class _Simulator extends ConsumerStatefulWidget {
  const _Simulator({required this.zone});

  final Zone zone;

  @override
  ConsumerState<_Simulator> createState() => _SimulatorState();
}

class _SimulatorState extends ConsumerState<_Simulator> {
  final _km = TextEditingController(text: '4');
  Service _service = Service.food;
  FeeSimulation? _result;
  Object? _error;

  @override
  void dispose() {
    _km.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final km = double.tryParse(_km.text.replaceAll(',', '.'));
    if (km == null || km < 0) return;
    try {
      final result = await ref
          .read(adminZoneRepositoryProvider)
          .simulate(widget.zone.id, _service, km);
      setState(() {
        _result = result;
        _error = null;
      });
    } on AppFailure catch (failure) {
      setState(() => _error = failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final result = _result;
    return _Section(
      children: [
        SegmentedButton<Service>(
          segments: [
            ButtonSegment(value: Service.food, label: Text(l10n.pricingFood)),
            ButtonSegment(
              value: Service.parcel,
              label: Text(l10n.pricingParcel),
            ),
          ],
          selected: {_service},
          showSelectedIcon: false,
          onSelectionChanged: (selection) =>
              setState(() => _service = selection.single),
        ),
        _Row(
          children: [
            _NumberField(controller: _km, label: l10n.simulatorDistance),
            OutlinedButton(onPressed: _run, child: Text(l10n.simulatorRun)),
          ],
        ),
        if (result != null)
          Text(
            l10n.simulatorResult(
              formatDecimal(result.distanceM / 1000),
              formatMoney(result.deliveryFee, currency: widget.zone.currency),
              formatMoney(
                result.courierEarning,
                currency: widget.zone.currency,
              ),
            ),
            style: text.titleMedium,
          ),
        if (_error != null)
          Text(
            failureMessage(l10n, _error),
            style: TextStyle(color: context.tokens.danger),
          ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    this.validator,
    this.signed = false,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final bool signed;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(
      decimal: true,
      signed: signed,
    ),
    inputFormatters: [
      FilteringTextInputFormatter.allow(
        RegExp(signed ? r'[-0-9.,]' : r'[0-9.,]'),
      ),
    ],
    decoration: InputDecoration(labelText: label),
    validator: validator,
  );
}

/// Carte blanche regroupant des champs, avec un espacement régulier.
class _Section extends StatelessWidget {
  const _Section({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(Space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: Space.md),
            children[i],
          ],
        ],
      ),
    ),
  );
}

/// Deux champs côte à côte.
class _Row extends StatelessWidget {
  const _Row({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) const SizedBox(width: Space.md),
        Expanded(child: children[i]),
      ],
    ],
  );
}
