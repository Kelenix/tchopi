import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';

Future<void> main() => bootstrap(const CourierApp());

class CourierApp extends ConsumerWidget {
  const CourierApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      AppRoot(router: ref.watch(routerProvider));
}
