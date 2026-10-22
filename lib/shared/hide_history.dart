import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Confirmation avant de masquer une commande terminée ([all] : tout l'historique terminé). Rien n'est supprimé
/// des registres : reçus, paiements et support gardent la commande.
Future<bool> confirmHide(BuildContext context, {bool all = false}) {
  final l10n = AppLocalizations.of(context);
  return showConfirmSheet(
    context,
    icon: all ? Icons.delete_sweep_outlined : Icons.visibility_off_outlined,
    title: all ? l10n.historyClearTitle : l10n.historyHideTitle,
    body: all ? l10n.historyClearBody : l10n.historyHideBody,
    confirmLabel: all ? l10n.historyClear : l10n.historyHide,
    destructive: true,
  );
}

/// Fond révélé en glissant une commande vers la gauche.
class HideBackground extends StatelessWidget {
  const HideBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: Space.xs),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: Space.xl),
      decoration: BoxDecoration(
        color: tokens.dangerSoft,
        borderRadius: BorderRadius.circular(Radii.card),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility_off_outlined, color: tokens.danger),
          const SizedBox(width: Space.sm),
          Text(
            AppLocalizations.of(context).historyHide,
            style: TextStyle(color: tokens.danger, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
