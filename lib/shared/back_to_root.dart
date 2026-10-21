import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Retour Android sur un onglet d'un espace : les onglets se remplacent (`go`), il n'y a donc pas d'écran
/// précédent ; le retour ramène à l'onglet d'accueil de l'espace, et seul celui-ci ferme l'application.
class BackToRoot extends StatelessWidget {
  const BackToRoot({super.key, required this.root, required this.child});

  /// Onglet d'accueil de l'espace.
  final String root;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    final atRoot =
        router == null ||
        router.canPop() ||
        router.routerDelegate.currentConfiguration.uri.path == root;
    return PopScope(
      canPop: atRoot,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) router?.go(root);
      },
      child: child,
    );
  }
}
