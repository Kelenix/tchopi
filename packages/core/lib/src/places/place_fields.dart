import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../design/tokens.dart';
import '../utils/text.dart';
import 'models.dart';
import 'places_reference.dart';

/// Ville de la zone desservie qui contient le point, sinon `null` (suggestions de quartiers).
String? cityAt(Iterable<Zone> zones, double lat, double lng) {
  double distanceM(Zone z) {
    const earth = 6371000.0;
    double rad(double d) => d * math.pi / 180;
    final dLat = rad(z.centerLat - lat), dLng = rad(z.centerLng - lng);
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(lat)) *
            math.cos(rad(z.centerLat)) *
            math.pow(math.sin(dLng / 2), 2);
    return 2 * earth * math.asin(math.sqrt(a));
  }

  final inside = [
    for (final z in zones)
      if (distanceM(z) <= z.radiusM) z,
  ]..sort((a, b) => distanceM(a).compareTo(distanceM(b)));
  return inside.firstOrNull?.city;
}

/// Champ « Ville » : ouvre une feuille compacte avec recherche ; les villes desservies [served] en tête.
class CityField extends FormField<String> {
  CityField({
    super.key,
    super.initialValue,
    required ValueChanged<String> onChanged,
    List<String> served = const [],
    String? errorText,
  }) : super(
         validator: (value) => value == null ? '' : null,
         builder: (state) {
           final context = state.context;
           final l10n = AppLocalizations.of(context);
           return InkWell(
             borderRadius: BorderRadius.circular(Radii.field),
             onTap: () async {
               final city = await showCityPicker(
                 context,
                 selected: state.value,
                 served: served,
               );
               if (city != null) {
                 state.didChange(city);
                 onChanged(city);
               }
             },
             child: InputDecorator(
               isEmpty: state.value == null,
               decoration: InputDecoration(
                 labelText: l10n.fieldCity,
                 prefixIcon: const Icon(Icons.location_city_outlined),
                 suffixIcon: const Icon(Icons.expand_more_rounded),
                 errorText:
                     errorText ?? (state.hasError ? l10n.errorRequired : null),
               ),
               child: Text(
                 state.value ?? '',
                 style: Theme.of(context).textTheme.bodyLarge,
               ),
             ),
           );
         },
       );
}

/// Feuille de choix de ville : hauteur limitée à l'écran, recherche sans accents, liste défilante.
Future<String?> showCityPicker(
  BuildContext context, {
  String? selected,
  List<String> served = const [],
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => _CityPicker(selected: selected, served: served),
);

class _CityPicker extends StatefulWidget {
  const _CityPicker({required this.selected, required this.served});

  final String? selected;
  final List<String> served;

  @override
  State<_CityPicker> createState() => _CityPickerState();
}

class _CityPickerState extends State<_CityPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final media = MediaQuery.of(context);
    final served = {...widget.served};
    final all = [
      ...([...widget.served]..sort()),
      for (final city in ivoryCoastCities)
        if (!served.contains(city)) city,
    ];
    final results = searchPlaces(all, _query);
    return Padding(
      // Le clavier repousse la feuille au lieu de la recouvrir.
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SizedBox(
        // Hauteur fixe : la feuille ne saute pas pendant la recherche.
        height: media.size.height * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                0,
                Space.screen,
                Space.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.cityPickerTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: Space.md),
                  TextField(
                    autofocus: false,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: l10n.cityPickerSearch,
                      prefixIcon: const Icon(Icons.search_rounded),
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(Space.xxl),
                      child: Text(
                        l10n.cityPickerEmpty,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: tokens.muted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: Space.lg),
                      itemCount: results.length,
                      itemBuilder: (context, i) {
                        final city = results[i];
                        final current = city == widget.selected;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: Space.screen,
                          ),
                          title: Text(city),
                          subtitle: served.contains(city)
                              ? Text(l10n.cityServed)
                              : null,
                          trailing: current
                              ? Icon(Icons.check_rounded, color: tokens.primary)
                              : null,
                          selected: current,
                          selectedColor: tokens.primary,
                          onTap: () => Navigator.of(context).pop(city),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Champ « Quartier » avec suggestions des quartiers de la ville rendue par [city], lue à chaque saisie (elle peut
/// suivre l'épingle de la carte) ; liste discrète sous le champ ; tout autre quartier peut être saisi librement.
class DistrictField extends StatefulWidget {
  const DistrictField({
    super.key,
    required this.controller,
    required this.city,
    this.validator,
  });

  final TextEditingController controller;
  final String? Function() city;
  final FormFieldValidator<String>? validator;

  @override
  State<DistrictField> createState() => _DistrictFieldState();
}

class _DistrictFieldState extends State<DistrictField> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focus,
      optionsBuilder: (value) {
        if (value.text.trim().isEmpty) return const [];
        final known =
            districtsByCity[widget.city()] ??
            {for (final list in districtsByCity.values) ...list}.toList();
        final typed = foldAccents(value.text.trim());
        return searchPlaces(
          known,
          value.text,
        ).where((d) => foldAccents(d) != typed).take(6);
      },
      fieldViewBuilder: (context, controller, focus, onSubmitted) =>
          TextFormField(
            controller: controller,
            focusNode: focus,
            textCapitalization: TextCapitalization.words,
            onFieldSubmitted: (_) => onSubmitted(),
            decoration: InputDecoration(
              labelText: l10n.fieldDistrict,
              prefixIcon: const Icon(Icons.location_city_outlined),
            ),
            validator: widget.validator,
          ),
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(top: Space.xs),
          child: Material(
            color: tokens.surface,
            elevation: 3,
            shadowColor: tokens.ink.withValues(alpha: 0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.field),
              side: BorderSide(color: tokens.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: Space.xs),
                shrinkWrap: true,
                children: [
                  for (final option in options)
                    ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.place_outlined,
                        size: 20,
                        color: tokens.muted,
                      ),
                      title: Text(option),
                      onTap: () => onSelected(option),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
