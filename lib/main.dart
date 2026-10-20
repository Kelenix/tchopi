import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'shared/push.dart';

Future<void> main() => bootstrap(const MobileApp());

class MobileApp extends ConsumerWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Notifications : autorisation demandée dès l'ouverture, une fois connecté (ADR-041).
    ref.listen(pushProvider, (_, _) {});
    return AppRoot(router: ref.watch(routerProvider));
  }
}
