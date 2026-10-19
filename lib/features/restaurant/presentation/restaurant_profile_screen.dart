import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/media.dart';
import '../restaurant_providers.dart';
import 'restaurant_scaffold.dart';

/// R-05 : présentation, téléphone, temps de préparation, fermeture temporaire, horaires (RES-02, RES-03).
/// La commission et la zone sont affichées sans être modifiables (réservées à l'équipe).
class RestaurantProfileScreen extends ConsumerWidget {
  const RestaurantProfileScreen({super.key});

  static const path = '/restaurant/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = ref.watch(managedRestaurantIdProvider);
    if (id == null) return const SizedBox.shrink();
    final restaurant = ref.watch(managedRestaurantProvider(id));
    final hours = ref.watch(openingHoursProvider(id));
    return RestaurantScaffold(
      current: path,
      title: l10n.restaurantProfile,
      body: switch ((restaurant, hours)) {
        (AsyncData(value: final r), AsyncData(value: final h)) => _ProfileForm(
          key: ValueKey(r.id),
          restaurant: r,
          hours: h,
        ),
        (AsyncError(:final error), _) || (_, AsyncError(:final error)) =>
          Center(child: Text(failureMessage(l10n, error))),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({
    super.key,
    required this.restaurant,
    required this.hours,
  });

  final Restaurant restaurant;
  final List<OpeningHour> hours;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _category, _description, _phone, _prepTime;
  late bool _temporarilyClosed;
  late final Map<int, List<(TimeOfDay, TimeOfDay)>> _hours;
  Uint8List? _newCover;
  bool _saving = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    final r = widget.restaurant;
    _category = TextEditingController(text: r.category);
    _description = TextEditingController(text: r.description);
    _phone = TextEditingController(text: r.phone);
    _prepTime = TextEditingController(text: '${r.prepTimeMin}');
    _temporarilyClosed = r.isTemporarilyClosed;
    _hours = {
      for (var day = 1; day <= 7; day++)
        day: [
          for (final hour in widget.hours.where((h) => h.weekday == day))
            (_parse(hour.opensAt), _parse(hour.closesAt)),
        ],
    };
  }

  @override
  void dispose() {
    for (final controller in [_category, _description, _phone, _prepTime]) {
      controller.dispose();
    }
    super.dispose();
  }

  static TimeOfDay _parse(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String _format(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _addRange(int day) async {
    final opens = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 11, minute: 0),
    );
    if (opens == null || !mounted) return;
    final closes = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 22, minute: 0),
    );
    if (closes == null || !mounted) return;
    if (closes.hour * 60 + closes.minute <= opens.hour * 60 + opens.minute) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).hoursInvalid)),
      );
      return;
    }
    setState(() => _hours[day]!.add((opens, closes)));
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final saved = AppLocalizations.of(context).restaurantSaved;
    final r = widget.restaurant;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final cover = _newCover;
      final coverPath = cover == null
          ? r.coverPath
          : await ref
                .read(mediaRepositoryProvider)
                .uploadRestaurantImage(r.id, cover, 'cover');
      final repository = ref.read(restaurantRepositoryProvider);
      await repository.updateProfile(
        r.copyWith(
          category: _category.text,
          description: _description.text,
          phone: normalizePhone(_phone.text)!,
          prepTimeMin: int.parse(_prepTime.text),
          isTemporarilyClosed: _temporarilyClosed,
          coverPath: coverPath,
        ),
      );
      await repository.saveHours(r.id, [
        for (final MapEntry(key: day, value: ranges) in _hours.entries)
          for (final (opens, closes) in ranges)
            OpeningHour(
              weekday: day,
              opensAt: _format(opens),
              closesAt: _format(closes),
            ),
      ]);
      ref
        ..invalidate(managedRestaurantProvider(r.id))
        ..invalidate(openingHoursProvider(r.id));
      messenger.showSnackBar(SnackBar(content: Text(saved)));
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
    final r = widget.restaurant;
    final days = [
      l10n.weekday1,
      l10n.weekday2,
      l10n.weekday3,
      l10n.weekday4,
      l10n.weekday5,
      l10n.weekday6,
      l10n.weekday7,
    ];
    final coverPath = r.coverPath;
    final ImageProvider? cover = _newCover != null
        ? MemoryImage(_newCover!)
        : coverPath == null
        ? null
        : NetworkImage(ref.read(mediaRepositoryProvider).publicUrl(coverPath));

    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(Space.screen),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Material(
              color: tokens.surfaceAlt,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Radii.card),
              ),
              child: InkWell(
                onTap: () async {
                  final bytes = await pickPhoto(context);
                  if (bytes != null) setState(() => _newCover = bytes);
                },
                child: cover == null
                    ? Center(
                        child: Text(
                          l10n.coverPhoto,
                          style: TextStyle(color: tokens.muted),
                        ),
                      )
                    : Ink.image(image: cover, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: Space.lg),
          Text(r.name, style: text.headlineMedium),
          Text(
            '${r.district} · ${r.landmark}',
            style: text.bodyMedium!.copyWith(color: tokens.muted),
          ),
          Text(
            l10n.commissionReadOnly(formatDecimal(r.commissionRate)),
            style: text.bodySmall!.copyWith(color: tokens.muted),
          ),
          const SizedBox(height: Space.lg),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.restaurantTemporarilyClosed),
            subtitle: Text(l10n.restaurantTemporarilyClosedBody),
            value: _temporarilyClosed,
            onChanged: (value) => setState(() => _temporarilyClosed = value),
          ),
          const SizedBox(height: Space.md),
          TextFormField(
            controller: _category,
            decoration: InputDecoration(
              labelText: l10n.fieldRestaurantCategory,
            ),
          ),
          const SizedBox(height: Space.lg),
          TextFormField(
            controller: _description,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l10n.fieldDescription),
          ),
          const SizedBox(height: Space.lg),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l10n.fieldPhone,
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            validator: (value) =>
                normalizePhone(value ?? '') == null ? l10n.errorPhone : null,
          ),
          const SizedBox(height: Space.lg),
          TextFormField(
            controller: _prepTime,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: l10n.fieldPrepTime),
            validator: (value) {
              final minutes = int.tryParse(value ?? '') ?? 0;
              return minutes < 5 || minutes > 120 ? l10n.errorNumber : null;
            },
          ),
          const SizedBox(height: Space.xl),
          Text(l10n.openingHours, style: text.titleMedium),
          const SizedBox(height: Space.sm),
          Card(
            child: Column(
              children: [
                for (var day = 1; day <= 7; day++)
                  ListTile(
                    title: Text(days[day - 1]),
                    subtitle: Wrap(
                      spacing: Space.xs,
                      runSpacing: Space.xs,
                      children: [
                        if (_hours[day]!.isEmpty)
                          Text(
                            l10n.hoursClosedDay,
                            style: TextStyle(color: tokens.muted),
                          ),
                        for (final range in _hours[day]!)
                          InputChip(
                            label: Text(
                              '${_format(range.$1)} – ${_format(range.$2)}',
                            ),
                            onDeleted: () =>
                                setState(() => _hours[day]!.remove(range)),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      tooltip: l10n.hoursAdd,
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _addRange(day),
                    ),
                  ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: Space.md),
            Text(
              failureMessage(l10n, _error),
              style: TextStyle(color: tokens.danger),
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
    );
  }
}
