import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../orders/presentation/order_widgets.dart';
import '../../admin_scaffold.dart';
import '../../payments/admin_payments_providers.dart';
import '../supervision_providers.dart';

/// A-09 : délais de la plateforme et numéro du support (ADM-05) ; bornes identiques à celles de la base.
/// Moyens de paiement actifs par pays : Mobile Money et carte s'activent une fois intégrés (Inc-11 / 12).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const path = '/admin/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(platformSettingsProvider);
    return AdminScaffold(
      current: path,
      body: switch (settings) {
        AsyncData(:final value) => _SettingsForm(settings: value),
        AsyncError(:final error) => Center(
          child: Text(failureMessage(AppLocalizations.of(context), error)),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// Champ numérique : valeur affichée dans [unit] secondes (1 ou 60), bornée comme en base.
typedef _Delay = ({
  String Function(AppLocalizations) label,
  int unit,
  int min,
  int max,
});

class _SettingsForm extends ConsumerStatefulWidget {
  const _SettingsForm({required this.settings});

  final PlatformSettings settings;

  @override
  ConsumerState<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<_SettingsForm> {
  static final List<_Delay> _delays = [
    (label: (l) => l.settingsRestaurantTimeout, unit: 60, min: 2, max: 60),
    (label: (l) => l.settingsPaymentTimeout, unit: 60, min: 5, max: 60),
    (label: (l) => l.settingsDispatchAlert, unit: 60, min: 2, max: 60),
    (label: (l) => l.settingsDispatchCancel, unit: 60, min: 5, max: 240),
  ];

  final _form = GlobalKey<FormState>();
  late final List<TextEditingController> _fields;
  late final TextEditingController _phone;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.settings;
    final values = [
      s.restaurantTimeoutS,
      s.paymentTimeoutS,
      s.dispatchAlertS,
      s.dispatchCancelS,
    ];
    _fields = [
      for (final (i, d) in _delays.indexed)
        TextEditingController(text: '${values[i] ~/ d.unit}'),
    ];
    _phone = TextEditingController(text: s.supportPhone ?? '');
  }

  @override
  void dispose() {
    for (final field in _fields) {
      field.dispose();
    }
    _phone.dispose();
    super.dispose();
  }

  int _seconds(int index) =>
      int.parse(_fields[index].text) * _delays[index].unit;

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      final saved = await ref
          .read(supervisionRepositoryProvider)
          .saveSettings(
            PlatformSettings(
              // Plus d'offre limitée dans le temps (ADR-037) : valeur conservée telle quelle.
              offerTimeoutS: widget.settings.offerTimeoutS,
              restaurantTimeoutS: _seconds(0),
              paymentTimeoutS: _seconds(1),
              dispatchAlertS: _seconds(2),
              dispatchCancelS: _seconds(3),
              supportPhone: normalizePhone(_phone.text),
            ),
          );
      ref.invalidate(platformSettingsProvider);
      _phone.text = saved.supportPhone ?? '';
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsSaved)));
    } on AppFailure catch (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(Space.screen),
        children: [
          SectionHeader(title: l10n.settingsDelaysTitle),
          for (final (i, d) in _delays.indexed) ...[
            TextFormField(
              controller: _fields[i],
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: d.label(l10n)),
              validator: (value) {
                final n = int.tryParse(value ?? '');
                if (n == null || n < d.min || n > d.max) {
                  return l10n.settingsRange(d.min, d.max);
                }
                // L'annulation automatique vient après l'alerte (contrainte de la base).
                if (i == 3 && n <= (int.tryParse(_fields[2].text) ?? 0)) {
                  return l10n.settingsCancelAfterAlert;
                }
                return null;
              },
            ),
            const SizedBox(height: Space.md),
          ],
          const SizedBox(height: Space.lg),
          SectionHeader(title: l10n.settingsSupportTitle),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l10n.settingsSupportPhone,
              prefixIcon: const Icon(Icons.support_agent_outlined),
            ),
            validator: (value) =>
                (value ?? '').trim().isEmpty || normalizePhone(value!) != null
                ? null
                : l10n.errorPhone,
          ),
          const SizedBox(height: Space.lg),
          SectionHeader(title: l10n.settingsPaymentsTitle),
          const _PaymentOptions(),
          const SizedBox(height: Space.xxl),
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
    );
  }
}

class _PaymentOptions extends ConsumerWidget {
  const _PaymentOptions();

  /// Fournisseurs intégrés ; les autres moyens restent « Bientôt ».
  static const _integrated = {'cash', 'nyole', 'stripe'};

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    PaymentOption option,
    bool enabled,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(adminPaymentsRepositoryProvider)
          .setOption(option.id, enabled: enabled);
      ref.invalidate(adminPaymentOptionsProvider);
    } on AppFailure catch (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final options = ref.watch(adminPaymentOptionsProvider).value ?? const [];
    return Card(
      child: Column(
        children: [
          for (final option in options)
            SwitchListTile(
              secondary: Icon(paymentIcon(option.method)),
              title: Text('${option.label} · ${option.countryCode}'),
              subtitle: switch (option.provider) {
                'cash' => null,
                'nyole' => Text(l10n.paymentMobileMoneyHint),
                'stripe' => Text(l10n.paymentCardHint),
                _ => Text(l10n.paymentSoon),
              },
              value: option.isEnabled,
              onChanged: _integrated.contains(option.provider)
                  ? (value) => _toggle(context, ref, option, value)
                  : null,
            ),
        ],
      ),
    );
  }
}
