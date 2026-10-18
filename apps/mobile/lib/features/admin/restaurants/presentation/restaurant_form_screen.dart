import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../admin_scaffold.dart';
import '../../zones/zones_providers.dart';
import '../restaurants_admin_providers.dart';

/// A-05 : fiche restaurant (zone, position, commission, activation) et gérants (RES-01, ADM-03).
class RestaurantFormScreen extends ConsumerStatefulWidget {
  const RestaurantFormScreen({super.key, this.restaurant});

  final Restaurant? restaurant;

  @override
  ConsumerState<RestaurantFormScreen> createState() =>
      _RestaurantFormScreenState();
}

class _RestaurantFormScreenState extends ConsumerState<RestaurantFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name,
      _category,
      _description,
      _phone,
      _lat,
      _lng,
      _district,
      _landmark,
      _commission;
  String? _zoneId;
  late bool _active;
  bool _saving = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    final r = widget.restaurant;
    _name = TextEditingController(text: r?.name);
    _category = TextEditingController(text: r?.category);
    _description = TextEditingController(text: r?.description);
    _phone = TextEditingController(text: r?.phone);
    _lat = TextEditingController(text: r?.latitude.toString());
    _lng = TextEditingController(text: r?.longitude.toString());
    _district = TextEditingController(text: r?.district);
    _landmark = TextEditingController(text: r?.landmark);
    _commission = TextEditingController(
      text: (r?.commissionRate ?? 15).toString(),
    );
    _zoneId = r?.zoneId;
    _active = r?.isActive ?? true;
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _category,
      _description,
      _phone,
      _lat,
      _lng,
      _district,
      _landmark,
      _commission,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  static double _number(TextEditingController controller) =>
      double.parse(controller.text.replaceAll(',', '.'));

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final saved = AppLocalizations.of(context).restaurantSaved;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(adminRestaurantRepositoryProvider)
          .save(
            Restaurant(
              id: widget.restaurant?.id ?? '',
              zoneId: _zoneId!,
              name: _name.text,
              description: _description.text,
              category: _category.text,
              phone: normalizePhone(_phone.text)!,
              latitude: _number(_lat),
              longitude: _number(_lng),
              district: _district.text,
              landmark: _landmark.text,
              commissionRate: _number(_commission),
              isActive: _active,
            ),
            isNew: widget.restaurant == null,
          );
      ref.invalidate(adminRestaurantsProvider);
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
    final zones = ref.watch(adminZonesProvider).value ?? const <Zone>[];
    final restaurant = widget.restaurant;
    String? required(String? value) =>
        (value?.trim().isEmpty ?? true) ? l10n.errorRequired : null;
    String? Function(String?) number(double min, double max) => (value) {
      final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
      return parsed == null || parsed < min || parsed > max
          ? l10n.errorNumber
          : null;
    };
    Widget field(
      TextEditingController controller,
      String label, {
      FormFieldValidator<String>? validator,
      bool decimal = false,
      int maxLines = 1,
    }) => TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true, signed: true)
          : null,
      inputFormatters: decimal
          ? [FilteringTextInputFormatter.allow(RegExp(r'[-0-9.,]'))]
          : null,
      decoration: InputDecoration(labelText: label),
      validator: validator,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          restaurant == null
              ? l10n.restaurantNewTitle
              : l10n.restaurantEditTitle,
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
                field(_name, l10n.fieldRestaurantName, validator: required),
                const SizedBox(height: Space.lg),
                DropdownButtonFormField<String>(
                  initialValue: _zoneId,
                  decoration: InputDecoration(
                    labelText: l10n.fieldRestaurantZone,
                  ),
                  items: [
                    for (final zone in zones)
                      DropdownMenuItem(value: zone.id, child: Text(zone.name)),
                  ],
                  onChanged: (value) => setState(() => _zoneId = value),
                  validator: (value) =>
                      value == null ? l10n.errorRequired : null,
                ),
                const SizedBox(height: Space.lg),
                field(_category, l10n.fieldRestaurantCategory),
                const SizedBox(height: Space.lg),
                field(_description, l10n.fieldDescription, maxLines: 3),
                const SizedBox(height: Space.lg),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: l10n.fieldPhone),
                  validator: (value) => normalizePhone(value ?? '') == null
                      ? l10n.errorPhone
                      : null,
                ),
                const SizedBox(height: Space.lg),
                field(_district, l10n.fieldDistrict, validator: required),
                const SizedBox(height: Space.lg),
                field(_landmark, l10n.fieldLandmark, validator: required),
                const SizedBox(height: Space.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: field(
                        _lat,
                        l10n.fieldLatitude,
                        validator: number(-90, 90),
                        decimal: true,
                      ),
                    ),
                    const SizedBox(width: Space.md),
                    Expanded(
                      child: field(
                        _lng,
                        l10n.fieldLongitude,
                        validator: number(-180, 180),
                        decimal: true,
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.map_outlined),
                    label: Text(l10n.restaurantViewOnMap),
                    onPressed: () => launchUrl(
                      Uri.parse(
                        'https://www.google.com/maps/search/?api=1&query=${_lat.text},${_lng.text}',
                      ),
                    ),
                  ),
                ),
                field(
                  _commission,
                  l10n.fieldCommission,
                  validator: number(0, 50),
                  decimal: true,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.restaurantActive),
                  value: _active,
                  onChanged: (value) => setState(() => _active = value),
                ),
                const SizedBox(height: Space.xl),
                Text(l10n.managersTitle, style: text.titleMedium),
                const SizedBox(height: Space.sm),
                restaurant == null
                    ? Text(
                        l10n.managersSaveFirst,
                        style: text.bodyMedium!.copyWith(color: tokens.muted),
                      )
                    : _Managers(restaurantId: restaurant.id),
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

/// Gérants du restaurant : invitation par email ou numéro, retrait.
class _Managers extends ConsumerWidget {
  const _Managers({required this.restaurantId});

  final String restaurantId;

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      ref.invalidate(restaurantMembersProvider(restaurantId));
    } on AppFailure catch (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
    }
  }

  Future<void> _invite(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final input = await askText(
      context,
      title: l10n.managerInvite,
      label: l10n.managerInviteField,
    );
    if (input == null || !context.mounted) return;
    final login = LoginIdentifier.parse(input);
    if (login == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorIdentifier)));
      return;
    }
    await _run(
      context,
      ref,
      () => ref
          .read(adminRestaurantRepositoryProvider)
          .invite(restaurantId, login),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final members = ref.watch(restaurantMembersProvider(restaurantId));
    return Card(
      child: Column(
        children: [
          ...switch (members) {
            AsyncData(:final value) when value.isEmpty => [
              ListTile(title: Text(l10n.managersEmpty)),
            ],
            AsyncData(:final value) => [
              for (final member in value)
                ListTile(
                  leading: Icon(
                    member.linked
                        ? Icons.verified_user_outlined
                        : Icons.schedule_outlined,
                    color: member.linked ? tokens.primary : tokens.muted,
                  ),
                  title: Text(member.login),
                  subtitle: Text(
                    member.linked ? l10n.managerLinked : l10n.managerPending,
                  ),
                  trailing: TextButton(
                    onPressed: () => _run(
                      context,
                      ref,
                      () => ref
                          .read(adminRestaurantRepositoryProvider)
                          .remove(member.id),
                    ),
                    child: Text(l10n.managerRemove),
                  ),
                ),
            ],
            AsyncError(:final error) => [
              ListTile(title: Text(failureMessage(l10n, error))),
            ],
            _ => [const LinearProgressIndicator()],
          },
          ListTile(
            leading: const Icon(Icons.person_add_alt_outlined),
            title: Text(l10n.managerInvite),
            onTap: () => _invite(context, ref),
          ),
        ],
      ),
    );
  }
}
