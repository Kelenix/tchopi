import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../spaces/spaces.dart';
import '../courier_providers.dart';
import 'courier_status_screen.dart';

/// L-01 : zone, moyen de transport, immatriculation et photo, soumis à validation (COU-01, COU-02).
class CourierProfileScreen extends ConsumerStatefulWidget {
  const CourierProfileScreen({super.key});

  static const path = '/courier/profile';

  @override
  ConsumerState<CourierProfileScreen> createState() =>
      _CourierProfileScreenState();
}

class _CourierProfileScreenState extends ConsumerState<CourierProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _plate = TextEditingController();
  String? _zoneId;
  VehicleType _vehicle = VehicleType.motorbike;
  Uint8List? _newPhoto;
  bool _photoMissing = false;
  bool _saving = false;
  Object? _error;

  Courier? get _existing => ref.read(myCourierProvider).value;

  @override
  void initState() {
    super.initState();
    final courier = _existing;
    if (courier != null) {
      _zoneId = courier.zoneId;
      _vehicle = courier.vehicleType;
      _plate.text = courier.plateNumber ?? '';
    }
  }

  @override
  void dispose() {
    _plate.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    // Réduite avant l'envoi (≤ 800 px) : économie de données et de stockage.
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _newPhoto = bytes;
      _photoMissing = false;
    });
  }

  Future<void> _submit() async {
    final hasPhoto = _newPhoto != null || _existing != null;
    setState(() => _photoMissing = !hasPhoto);
    if (!_form.currentState!.validate() || !hasPhoto) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(courierRepositoryProvider)
          .submit(
            userId: ref.read(currentUserIdProvider)!,
            zoneId: _zoneId!,
            vehicle: _vehicle,
            plate: _plate.text,
            newPhoto: _newPhoto,
            currentPhotoPath: _existing?.photoPath,
          );
      ref
        ..invalidate(myCourierProvider)
        ..invalidate(accountRolesProvider);
      await ref.read(activeSpaceProvider.notifier).select(AppSpace.courier);
      if (mounted) context.go(CourierStatusScreen.path);
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
    final zones = ref.watch(activeZonesProvider).value ?? const <Zone>[];
    final vehicles = {
      VehicleType.motorbike: (Icons.two_wheeler, l10n.vehicleMotorbike),
      VehicleType.bicycle: (Icons.pedal_bike, l10n.vehicleBicycle),
      VehicleType.car: (Icons.directions_car_outlined, l10n.vehicleCar),
      VehicleType.onFoot: (Icons.directions_walk, l10n.vehicleOnFoot),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _existing == null
              ? l10n.courierProfileTitle
              : l10n.courierProfileEditTitle,
        ),
        backgroundColor: tokens.background,
        actions: [
          IconButton(
            tooltip: l10n.accountTitle,
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(AppRoutes.account),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(Space.screen),
            children: [
              Text(
                l10n.courierProfileSubtitle,
                style: text.bodyMedium!.copyWith(color: tokens.muted),
              ),
              const SizedBox(height: Space.xl),
              Center(
                child: _PhotoPicker(
                  newPhoto: _newPhoto,
                  existingPath: _existing?.photoPath,
                  onPick: _pickPhoto,
                ),
              ),
              if (_photoMissing) ...[
                const SizedBox(height: Space.sm),
                Text(
                  l10n.errorPhotoRequired,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: tokens.danger),
                ),
              ],
              const SizedBox(height: Space.xl),
              DropdownButtonFormField<String>(
                key: ValueKey((_zoneId, zones.length)),
                initialValue: zones.any((zone) => zone.id == _zoneId)
                    ? _zoneId
                    : null,
                items: [
                  for (final zone in zones)
                    DropdownMenuItem(value: zone.id, child: Text(zone.name)),
                ],
                onChanged: (id) => _zoneId = id,
                validator: (id) => id == null ? l10n.errorRequired : null,
                decoration: InputDecoration(
                  labelText: l10n.fieldZone,
                  prefixIcon: const Icon(Icons.map_outlined),
                ),
              ),
              const SizedBox(height: Space.xl),
              Text(
                l10n.fieldVehicle,
                style: text.labelLarge!.copyWith(color: tokens.muted),
              ),
              const SizedBox(height: Space.sm),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: Space.sm,
                children: [
                  for (final MapEntry(key: vehicle, value: (icon, label))
                      in vehicles.entries)
                    _VehicleTile(
                      icon: icon,
                      label: label,
                      selected: _vehicle == vehicle,
                      onTap: () => setState(() => _vehicle = vehicle),
                    ),
                ],
              ),
              if (_vehicle.needsPlate) ...[
                const SizedBox(height: Space.lg),
                TextFormField(
                  controller: _plate,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: l10n.fieldPlate,
                    prefixIcon: const Icon(Icons.pin_outlined),
                  ),
                  validator: (value) => (value?.trim().length ?? 0) < 3
                      ? l10n.errorRequired
                      : null,
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: Space.lg),
                Text(
                  failureMessage(l10n, _error),
                  style: text.labelLarge!.copyWith(color: tokens.danger),
                ),
              ],
              const SizedBox(height: Space.xxl),
              FilledButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Text(l10n.courierSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleTile extends StatelessWidget {
  const _VehicleTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = selected ? tokens.primary : tokens.ink;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? tokens.primarySoft : tokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.field),
          side: BorderSide(
            color: selected ? tokens.primary : tokens.border,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.field),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: Space.xs),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall!.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Photo choisie (aperçu local) ou photo actuelle (lien temporaire), avec les deux sources possibles.
class _PhotoPicker extends ConsumerWidget {
  const _PhotoPicker({
    required this.newPhoto,
    required this.existingPath,
    required this.onPick,
  });

  final Uint8List? newPhoto;
  final String? existingPath;
  final ValueChanged<ImageSource> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final path = existingPath;
    final existingUrl = path == null
        ? null
        : ref.watch(courierPhotoUrlProvider(path)).value;
    final ImageProvider? image = newPhoto != null
        ? MemoryImage(newPhoto!)
        : (existingUrl != null ? NetworkImage(existingUrl) : null);

    return Column(
      children: [
        CircleAvatar(
          radius: 52,
          backgroundColor: tokens.primarySoft,
          foregroundImage: image,
          child: Icon(Icons.person_outline, size: 44, color: tokens.primary),
        ),
        const SizedBox(height: Space.sm),
        Text(
          l10n.photoHint,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(color: tokens.muted),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => onPick(ImageSource.camera),
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(l10n.photoTake),
            ),
            TextButton.icon(
              onPressed: () => onPick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.photoChoose),
            ),
          ],
        ),
      ],
    );
  }
}
