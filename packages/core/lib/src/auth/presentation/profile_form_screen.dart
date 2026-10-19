import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../design/tokens.dart';
import '../application/auth_controllers.dart';
import '../../places/places_providers.dart';
import '../application/auth_providers.dart';
import '../domain/login_identifier.dart';
import 'widgets/auth_form_scaffold.dart';
import 'widgets/form_fields.dart';

/// S-06 (première connexion) et modification des informations (AUTH-07).
class ProfileFormScreen extends ConsumerStatefulWidget {
  const ProfileFormScreen({super.key, required this.isSetup});

  final bool isSetup;

  @override
  ConsumerState<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends ConsumerState<ProfileFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _firstName, _lastName, _phone;
  String? _city;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(currentProfileProvider).value;
    _firstName = TextEditingController(text: profile?.firstName);
    _lastName = TextEditingController(text: profile?.lastName);
    _phone = TextEditingController(text: profile?.phone);
    _city = profile?.city;
  }

  @override
  void dispose() {
    for (final controller in [_firstName, _lastName, _phone]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final profile = ref.read(currentProfileProvider).value!;
    final messenger = ScaffoldMessenger.of(context);
    final saved = AppLocalizations.of(context).profileSaved;
    final ok = await ref
        .read(formSubmissionProvider('profile').notifier)
        .run(
          () => ref
              .read(authFlowsProvider)
              .saveProfile(
                profile.copyWith(
                  firstName: _firstName.text,
                  lastName: _lastName.text,
                  phone: normalizePhone(_phone.text),
                  city: _city,
                ),
              ),
        );
    // En première connexion, la navigation suit le profil complété ; en modification, on revient au compte.
    if (ok && mounted && !widget.isSetup) {
      messenger.showSnackBar(SnackBar(content: Text(saved)));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final submission = ref.watch(formSubmissionProvider('profile'));
    String? required(String? value) =>
        (value?.trim().isEmpty ?? true) ? l10n.errorRequired : null;
    Widget textField(
      TextEditingController controller,
      String label,
      Iterable<String> hints,
    ) => TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      autofillHints: hints,
      decoration: InputDecoration(labelText: label),
      validator: required,
    );

    return AuthFormScaffold(
      branded: widget.isSetup,
      title: widget.isSetup ? l10n.profileSetupTitle : l10n.profileEditTitle,
      subtitle: l10n.profileSetupSubtitle,
      primaryLabel: widget.isSetup ? l10n.actionContinue : l10n.actionSave,
      onPrimary: _save,
      isLoading: submission.isLoading,
      error: submission.error,
      children: [
        Form(
          key: _form,
          child: Column(
            children: [
              textField(_firstName, l10n.fieldFirstName, const [
                AutofillHints.givenName,
              ]),
              const SizedBox(height: Space.lg),
              textField(_lastName, l10n.fieldLastName, const [
                AutofillHints.familyName,
              ]),
              const SizedBox(height: Space.lg),
              PhoneField(
                controller: _phone,
                label: l10n.fieldPhone,
                validator: (value) => normalizePhone(value ?? '') == null
                    ? l10n.errorPhone
                    : null,
              ),
              const SizedBox(height: Space.lg),
              _CityField(
                value: _city,
                onChanged: (city) => setState(() => _city = city),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Ville choisie parmi les villes desservies (zones actives) ; présélectionnée s'il n'y en a qu'une.
class _CityField extends ConsumerWidget {
  const _CityField({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cities = ref.watch(servedCitiesProvider);
    final options = cities.value ?? const <String>[];
    final selected = options.contains(value)
        ? value
        : (options.length == 1 ? options.single : null);
    if (selected != value && selected != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onChanged(selected));
    }
    return DropdownButtonFormField<String>(
      // Reconstruit le champ quand la liste arrive (la valeur initiale n'est lue qu'à la création).
      key: ValueKey((selected, options.length)),
      initialValue: selected,
      items: [
        for (final city in options)
          DropdownMenuItem(value: city, child: Text(city)),
      ],
      onChanged: onChanged,
      validator: (city) => city == null ? l10n.errorRequired : null,
      decoration: InputDecoration(
        labelText: l10n.fieldCity,
        prefixIcon: const Icon(Icons.location_city_outlined),
        errorText: cities.hasError ? l10n.failureNetwork : null,
      ),
    );
  }
}
