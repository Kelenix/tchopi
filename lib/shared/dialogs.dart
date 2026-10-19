import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Saisie d'un motif obligatoire (refus, suspension, abandon, échec) ; `null` si l'admin annule.
Future<String?> askReason(BuildContext context, String title) => askText(
  context,
  title: title,
  label: AppLocalizations.of(context).reasonField,
  multiline: true,
);

/// Saisie d'un nouvel identifiant de connexion ; `null` si l'admin annule.
Future<String?> askLogin(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return askText(
    context,
    title: l10n.userChangeLogin,
    label: l10n.userChangeLoginField,
  );
}

/// Saisie d'un texte court ; `null` si l'admin annule.
Future<String?> askText(
  BuildContext context, {
  required String title,
  required String label,
  bool multiline = false,
}) {
  final controller = TextEditingController();
  final l10n = AppLocalizations.of(context);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLines: multiline ? 3 : 1,
        decoration: InputDecoration(labelText: label),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () {
            final value = controller.text.trim();
            if (value.isNotEmpty) Navigator.pop(context, value);
          },
          child: Text(l10n.actionContinue),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}
