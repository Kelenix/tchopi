import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Charge la vraie police (comme `packages/core`) : les débordements mesurés sont ceux du téléphone.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final loader = FontLoader(AppTheme.fontFamily);
  for (final weight in ['Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    final bytes = File(
      'packages/core/assets/fonts/PlusJakartaSans-$weight.ttf',
    ).readAsBytes();
    loader.addFont(bytes.then(ByteData.sublistView));
  }
  await loader.load();
  // Préférences (apparence) en mémoire : pas de stockage de l'appareil en test.
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();
  await testMain();
}
