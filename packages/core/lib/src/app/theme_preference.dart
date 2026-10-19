import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_preference.g.dart';

/// Apparence choisie par l'utilisateur (ADR-038) : automatique (réglage du téléphone), clair ou sombre ;
/// mémorisée sur l'appareil.
@Riverpod(keepAlive: true)
class ThemePreference extends _$ThemePreference {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    try {
      final saved = await SharedPreferencesAsync().getString(_key);
      final mode = ThemeMode.values.where((m) => m.name == saved).firstOrNull;
      if (mode != null) state = mode;
    } on Exception {
      // Préférence illisible : le réglage du téléphone s'applique.
    }
  }

  Future<void> select(ThemeMode mode) async {
    state = mode;
    await SharedPreferencesAsync().setString(_key, mode.name);
  }
}
