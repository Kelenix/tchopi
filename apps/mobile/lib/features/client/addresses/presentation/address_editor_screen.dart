import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../shared/pin_map.dart';
import '../application/addresses_providers.dart';
import '../data/location_service.dart';

/// C-14 : épingle fixe au centre, on déplace la carte ; quartier, repère, instructions et libellé.
/// Zone et ville sont déduites par le serveur, qui refuse une position hors zone (ADR-02, ADR-03).
class AddressEditorScreen extends ConsumerStatefulWidget {
  const AddressEditorScreen({super.key, this.address});

  final Address? address;

  @override
  ConsumerState<AddressEditorScreen> createState() =>
      _AddressEditorScreenState();
}

class _AddressEditorScreenState extends ConsumerState<AddressEditorScreen> {
  // Centre d'Abidjan, utilisé tant qu'aucune zone n'est chargée.
  static const _fallback = LatLng(5.3364, -4.0267);

  final _form = GlobalKey<FormState>();
  final _map = MapController();
  late final TextEditingController _district, _landmark, _instructions;
  late String _label;

  /// Point désigné par l'épingle ; c'est lui qui est enregistré.
  late LatLng _position;
  bool _locating = false;
  bool _saving = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _district = TextEditingController(text: address?.district);
    _landmark = TextEditingController(text: address?.landmark);
    _instructions = TextEditingController(text: address?.instructions);
    _label = address?.label ?? 'Maison';
    final zone = ref.read(activeZonesProvider).value?.firstOrNull;
    _position = address != null
        ? LatLng(address.latitude, address.longitude)
        : zone != null
        ? LatLng(zone.centerLat, zone.centerLng)
        : _fallback;
  }

  @override
  void dispose() {
    for (final controller in [_district, _landmark, _instructions]) {
      controller.dispose();
    }
    _map.dispose();
    super.dispose();
  }

  Future<void> _useMyPosition() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final location = ref.read(locationServiceProvider);
    if (await location.needsPermissionRequest() && mounted) {
      final accepted = await showConfirmSheet(
        context,
        icon: Icons.my_location,
        title: l10n.locationRationaleTitle,
        body: l10n.locationRationaleBody,
        confirmLabel: l10n.actionContinue,
      );
      if (!accepted) return;
    }
    setState(() => _locating = true);
    final result = await location.currentPosition();
    if (!mounted) return;
    setState(() => _locating = false);
    switch (result) {
      case LocationFound(:final latitude, :final longitude, :final isPrecise):
        _position = LatLng(latitude, longitude);
        _map.move(_position, PinMap.zoom);
        if (!isPrecise) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.locationLowAccuracy)),
          );
        }
        if (_district.text.trim().isEmpty) {
          final district = await location.suggestDistrict(latitude, longitude);
          if (district != null && mounted && _district.text.trim().isEmpty) {
            _district.text = district;
          }
        }
      case LocationUnavailable(:final problem):
        messenger.showSnackBar(
          SnackBar(
            content: Text(switch (problem) {
              LocationProblem.serviceOff => l10n.locationOff,
              LocationProblem.denied => l10n.locationDenied,
              LocationProblem.deniedForever => l10n.locationDeniedForever,
            }),
            action: problem == LocationProblem.deniedForever
                ? SnackBarAction(
                    label: l10n.locationOpenSettings,
                    onPressed: location.openSettings,
                  )
                : null,
          ),
        );
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final saved = AppLocalizations.of(context).addressSaved;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(addressesProvider.notifier)
          .save(
            Address(
              id: widget.address?.id,
              label: _label,
              district: _district.text,
              landmark: _landmark.text,
              instructions: _instructions.text,
              latitude: _position.latitude,
              longitude: _position.longitude,
            ),
          );
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
    final labels = {
      'Maison': (l10n.labelHome, Icons.home_outlined),
      'Bureau': (l10n.labelWork, Icons.work_outline),
      'Autre': (l10n.labelOther, Icons.place_outlined),
    };

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // La carte occupe le haut ; la feuille du formulaire la recouvre de ses coins arrondis.
          final mapHeight = (constraints.maxHeight * 0.42).clamp(200.0, 380.0);
          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: mapHeight + Radii.sheet,
                child: PinMap(
                  controller: _map,
                  initialCenter: _position,
                  onMoved: (target) => _position = target,
                ),
              ),
              const Positioned(
                top: 0,
                left: 0,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(top: Space.sm),
                    child: RoundBackButton(),
                  ),
                ),
              ),
              Positioned(
                right: Space.lg,
                top: mapHeight - 56 - Space.lg,
                child: FloatingActionButton.extended(
                  heroTag: null,
                  backgroundColor: tokens.surface,
                  foregroundColor: tokens.ink,
                  onPressed: _locating ? null : _useMyPosition,
                  icon: _locating
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.my_location, color: tokens.primary),
                  label: Text(l10n.addressMyPosition),
                ),
              ),
              Positioned.fill(
                top: mapHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: tokens.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(Radii.sheet),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        Expanded(
                          child: Form(
                            key: _form,
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(
                                Space.screen,
                                Space.xxl,
                                Space.screen,
                                Space.lg,
                              ),
                              children: [
                                Text(
                                  widget.address == null
                                      ? l10n.addressNewTitle
                                      : l10n.addressEditTitle,
                                  style: text.headlineMedium,
                                ),
                                const SizedBox(height: Space.xs),
                                Text(
                                  l10n.addressMoveMap,
                                  style: text.bodyMedium!.copyWith(
                                    color: tokens.muted,
                                  ),
                                ),
                                const SizedBox(height: Space.xl),
                                Wrap(
                                  spacing: Space.sm,
                                  children: [
                                    for (final MapEntry(
                                          :key,
                                          value: (label, icon),
                                        )
                                        in labels.entries)
                                      ChoiceChip(
                                        avatar: Icon(
                                          icon,
                                          size: 18,
                                          color: _label == key
                                              ? tokens.onInk
                                              : tokens.ink,
                                        ),
                                        label: Text(label),
                                        selected: _label == key,
                                        onSelected: (_) =>
                                            setState(() => _label = key),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: Space.xl),
                                TextFormField(
                                  controller: _district,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                    labelText: l10n.fieldDistrict,
                                    prefixIcon: const Icon(
                                      Icons.location_city_outlined,
                                    ),
                                  ),
                                  validator: required,
                                ),
                                const SizedBox(height: Space.md),
                                TextFormField(
                                  controller: _landmark,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  decoration: InputDecoration(
                                    labelText: l10n.fieldLandmark,
                                    hintText: l10n.fieldLandmarkHint,
                                    prefixIcon: const Icon(Icons.flag_outlined),
                                  ),
                                  validator: required,
                                ),
                                const SizedBox(height: Space.md),
                                TextFormField(
                                  controller: _instructions,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  maxLines: 2,
                                  minLines: 1,
                                  decoration: InputDecoration(
                                    labelText: l10n.fieldInstructions,
                                    hintText: l10n.fieldInstructionsHint,
                                    prefixIcon: const Icon(Icons.notes_rounded),
                                  ),
                                ),
                                if (_error != null) ...[
                                  const SizedBox(height: Space.lg),
                                  Text(
                                    failureMessage(l10n, _error),
                                    style: text.labelLarge!.copyWith(
                                      color: tokens.danger,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            Space.screen,
                            0,
                            Space.screen,
                            Space.lg,
                          ),
                          child: FilledButton(
                            onPressed: _saving ? null : _save,
                            child: _saving
                                ? const SizedBox.square(
                                    dimension: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(l10n.actionSave),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
