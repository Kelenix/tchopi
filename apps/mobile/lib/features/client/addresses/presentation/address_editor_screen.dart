import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  static const _zoom = 17.0;

  final _form = GlobalKey<FormState>();
  late final TextEditingController _district, _landmark, _instructions;
  late String _label;
  LatLng? _position;
  GoogleMapController? _map;
  bool _locating = false;
  bool _saving = false;
  bool _positionMissing = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _district = TextEditingController(text: address?.district);
    _landmark = TextEditingController(text: address?.landmark);
    _instructions = TextEditingController(text: address?.instructions);
    _label = address?.label ?? 'Maison';
    if (address != null) {
      _position = LatLng(address.latitude, address.longitude);
    }
  }

  @override
  void dispose() {
    for (final controller in [_district, _landmark, _instructions]) {
      controller.dispose();
    }
    _map?.dispose();
    super.dispose();
  }

  LatLng get _initialTarget {
    final zones = ref.read(activeZonesProvider).value;
    return _position ??
        (zones == null || zones.isEmpty
            ? _fallback
            : LatLng(zones.first.centerLat, zones.first.centerLng));
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
        _moveTo(LatLng(latitude, longitude));
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

  void _moveTo(LatLng target) {
    setState(() {
      _position = target;
      _positionMissing = false;
    });
    _map?.animateCamera(CameraUpdate.newLatLngZoom(target, _zoom));
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    // Sans carte, la position ne peut venir que du GPS : pas d'enregistrement au centre de la zone par défaut.
    final position = _position ?? (Env.mapsEnabled ? _initialTarget : null);
    if (position == null) {
      setState(() => _positionMissing = true);
      return;
    }
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
              latitude: position.latitude,
              longitude: position.longitude,
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
      'Maison': l10n.labelHome,
      'Bureau': l10n.labelWork,
      'Autre': l10n.labelOther,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.address == null ? l10n.addressNewTitle : l10n.addressEditTitle,
        ),
        backgroundColor: tokens.background,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: _MapArea(
                      initialTarget: _initialTarget,
                      onCreated: (c) => _map = c,
                      onMoved: (target) => _position = target,
                      position: _position,
                    ),
                  ),
                  // L'épingle reste au centre ; sa pointe désigne la position enregistrée.
                  IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Icon(
                        Icons.location_on,
                        size: 44,
                        color: tokens.primary,
                      ),
                    ),
                  ),
                  Positioned(
                    right: Space.md,
                    bottom: Space.md,
                    child: FloatingActionButton.extended(
                      heroTag: null,
                      onPressed: _locating ? null : _useMyPosition,
                      icon: _locating
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                      label: Text(l10n.addressMyPosition),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _form,
                child: ListView(
                  padding: const EdgeInsets.all(Space.screen),
                  children: [
                    Text(
                      l10n.addressMoveMap,
                      style: text.bodySmall!.copyWith(color: tokens.muted),
                    ),
                    const SizedBox(height: Space.lg),
                    Wrap(
                      spacing: Space.sm,
                      children: [
                        for (final MapEntry(:key, :value) in labels.entries)
                          ChoiceChip(
                            label: Text(value),
                            selected: _label == key,
                            onSelected: (_) => setState(() => _label = key),
                          ),
                      ],
                    ),
                    const SizedBox(height: Space.lg),
                    TextFormField(
                      controller: _district,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.fieldDistrict,
                      ),
                      validator: required,
                    ),
                    const SizedBox(height: Space.lg),
                    TextFormField(
                      controller: _landmark,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: l10n.fieldLandmark,
                        hintText: l10n.fieldLandmarkHint,
                      ),
                      validator: required,
                    ),
                    const SizedBox(height: Space.lg),
                    TextFormField(
                      controller: _instructions,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: l10n.fieldInstructions,
                        hintText: l10n.fieldInstructionsHint,
                      ),
                    ),
                    if (_positionMissing) ...[
                      const SizedBox(height: Space.lg),
                      Text(
                        l10n.mapUnavailable,
                        style: text.labelLarge!.copyWith(color: tokens.danger),
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: Space.lg),
                      Text(
                        failureMessage(l10n, _error),
                        style: text.labelLarge!.copyWith(color: tokens.danger),
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
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Text(l10n.actionSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte Google si une clé est configurée ; sinon un emplacement qui affiche la position choisie par GPS.
class _MapArea extends StatelessWidget {
  const _MapArea({
    required this.initialTarget,
    required this.onCreated,
    required this.onMoved,
    required this.position,
  });

  final LatLng initialTarget;
  final ValueChanged<GoogleMapController> onCreated;
  final ValueChanged<LatLng> onMoved;
  final LatLng? position;

  @override
  Widget build(BuildContext context) {
    if (Env.mapsEnabled) {
      return GoogleMap(
        initialCameraPosition: CameraPosition(target: initialTarget, zoom: 17),
        onMapCreated: onCreated,
        onCameraMove: (camera) => onMoved(camera.target),
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
      );
    }
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final current = position;
    return ColoredBox(
      color: tokens.surfaceAlt,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.xxl, Space.lg, Space.xxl, 96),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              l10n.mapUnavailable,
              textAlign: TextAlign.center,
              style: TextStyle(color: tokens.muted),
            ),
            if (current != null) ...[
              const SizedBox(height: Space.sm),
              Text(
                l10n.mapPosition(
                  current.latitude.toStringAsFixed(5),
                  current.longitude.toStringAsFixed(5),
                ),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
