import 'package:flutter/material.dart';

/// Couleurs du design system (`docs/design/design-system.md` §1), en clair et en sombre (maquette, ADR-038).
/// Les écrans les lisent via `context.tokens` ; aucune couleur n'est écrite en dur ailleurs.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.ink,
    required this.onInk,
    required this.muted,
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
    required this.success,
    required this.progress,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color ink;
  final Color onInk;
  final Color muted;
  final Color primary;
  final Color onPrimary;
  final Color primarySoft;
  final Color success;
  final Color progress;
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerSoft;

  static const light = AppTokens(
    background: Color(0xFFF5F6F3),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEEF1EC),
    border: Color(0xFFE4E7E2),
    ink: Color(0xFF0F1412),
    onInk: Color(0xFFFFFFFF),
    muted: Color(0xFF646B78),
    primary: Color(0xFF0B5D3B),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFE3F1E9),
    success: Color(0xFF16A34A),
    progress: Color(0xFF22C55E),
    warning: Color(0xFF9A4A07),
    warningSoft: Color(0xFFFCEFD9),
    danger: Color(0xFFC81E1E),
    dangerSoft: Color(0xFFFDE7E7),
  );

  /// Thème sombre de la maquette (`docs/design/maquette.html`) : fond presque noir, vert éclairci.
  static const dark = AppTokens(
    background: Color(0xFF0C110E),
    surface: Color(0xFF151B17),
    surfaceAlt: Color(0xFF1E2621),
    border: Color(0xFF2A332D),
    ink: Color(0xFFEEF2EE),
    onInk: Color(0xFF0F1412),
    muted: Color(0xFF9AA39C),
    primary: Color(0xFF3DD68C),
    onPrimary: Color(0xFF06281A),
    primarySoft: Color(0xFF173326),
    success: Color(0xFF4ADE80),
    progress: Color(0xFF22C55E),
    warning: Color(0xFFFBBF24),
    warningSoft: Color(0xFF33270F),
    danger: Color(0xFFF87171),
    dangerSoft: Color(0xFF3A1717),
  );

  // Les jetons sont fixes : aucune variante locale n'est prévue.
  @override
  AppTokens copyWith({Color? primary, Color? onPrimary, Color? primarySoft}) =>
      AppTokens(
        background: background,
        surface: surface,
        surfaceAlt: surfaceAlt,
        border: border,
        ink: ink,
        onInk: onInk,
        muted: muted,
        primary: primary ?? this.primary,
        onPrimary: onPrimary ?? this.onPrimary,
        primarySoft: primarySoft ?? this.primarySoft,
        success: success,
        progress: progress,
        warning: warning,
        warningSoft: warningSoft,
        danger: danger,
        dangerSoft: dangerSoft,
      );

  @override
  AppTokens lerp(AppTokens? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppTokens(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceAlt: mix(surfaceAlt, other.surfaceAlt),
      border: mix(border, other.border),
      ink: mix(ink, other.ink),
      onInk: mix(onInk, other.onInk),
      muted: mix(muted, other.muted),
      primary: mix(primary, other.primary),
      onPrimary: mix(onPrimary, other.onPrimary),
      primarySoft: mix(primarySoft, other.primarySoft),
      success: mix(success, other.success),
      progress: mix(progress, other.progress),
      warning: mix(warning, other.warning),
      warningSoft: mix(warningSoft, other.warningSoft),
      danger: mix(danger, other.danger),
      dangerSoft: mix(dangerSoft, other.dangerSoft),
    );
  }
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}

/// Espacements (`design-system.md` §3).
abstract final class Space {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
  static const huge = 40.0;

  /// Marge latérale des écrans.
  static const screen = 20.0;
}

abstract final class Radii {
  static const chip = 12.0;
  static const field = 16.0;
  static const card = 24.0;
  static const sheet = 28.0;
}

/// Durées et courbe d'animation (`design-system.md` §4).
abstract final class Motion {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const emphasis = Duration(milliseconds: 400);
  static const curve = Curves.easeOutCubic;
}
