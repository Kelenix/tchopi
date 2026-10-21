import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../design/tokens.dart';

/// Feuille de confirmation : explique la conséquence avant une action importante.
/// Renvoie `true` si l'utilisateur confirme.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String body,
  required String confirmLabel,
  bool destructive = false,
}) async {
  var completed = false;
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    builder: (context) {
      final tokens = context.tokens;
      final text = Theme.of(context).textTheme;
      final accent = destructive ? tokens.danger : tokens.primaryAction;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.screen,
            0,
            Space.screen,
            Space.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: destructive
                    ? tokens.dangerSoft
                    : tokens.primarySoft,
                child: Icon(icon, color: accent),
              ),
              const SizedBox(height: Space.md),
              Text(title, style: text.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: Space.sm),
              Text(
                body,
                style: text.bodyMedium!.copyWith(color: tokens.muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Space.xxl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (completed) return;
                        completed = true;
                        Navigator.pop(context, false);
                      },
                      child: Text(AppLocalizations.of(context).actionCancel),
                    ),
                  ),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: destructive
                            ? tokens.surface
                            : tokens.onPrimaryAction,
                      ),
                      onPressed: () {
                        if (completed) return;
                        completed = true;
                        Navigator.pop(context, true);
                      },
                      child: Text(confirmLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return confirmed ?? false;
}
