import 'package:flutter/material.dart';

import 'tokens.dart';

/// Thèmes Material 3 construits à partir des jetons ; police embarquée dans `core`.
abstract final class AppTheme {
  static const fontFamily = 'packages/core/PlusJakartaSans';

  static final light = _build(AppTokens.light, Brightness.light);
  static final dark = _build(AppTokens.dark, Brightness.dark);

  static ThemeData _build(AppTokens t, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: t.primary,
      onPrimary: t.onPrimary,
      primaryContainer: t.primarySoft,
      onPrimaryContainer: t.primary,
      secondary: t.ink,
      onSecondary: t.onInk,
      error: t.danger,
      onError: t.surface,
      errorContainer: t.dangerSoft,
      onErrorContainer: t.danger,
      surface: t.surface,
      onSurface: t.ink,
      onSurfaceVariant: t.muted,
      surfaceContainerHighest: t.surfaceAlt,
      outline: t.border,
      outlineVariant: t.border,
      inverseSurface: t.ink,
      onInverseSurface: t.onInk,
    );
    final text = _textTheme(t.ink);
    final pill = const StadiumBorder();
    const buttonSize = Size.fromHeight(56);
    final buttonText = text.labelLarge!.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w700,
    );
    OutlineInputBorder fieldBorder(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radii.field),
      borderSide: BorderSide(color: color, width: 1.5),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: fontFamily,
      textTheme: text,
      scaffoldBackgroundColor: t.background,
      extensions: [t],
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          shape: pill,
          textStyle: buttonText,
          backgroundColor: t.primary,
          foregroundColor: t.onPrimary,
          disabledBackgroundColor: t.surfaceAlt,
          disabledForegroundColor: t.muted,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: pill,
          textStyle: buttonText,
          foregroundColor: t.ink,
          backgroundColor: t.surface,
          side: BorderSide(color: t.border, width: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: t.primary,
          textStyle: buttonText.copyWith(fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Space.lg,
          vertical: 14,
        ),
        labelStyle: text.labelLarge!.copyWith(color: t.muted),
        hintStyle: text.bodyMedium!.copyWith(color: t.muted),
        border: fieldBorder(t.border),
        enabledBorder: fieldBorder(t.border),
        focusedBorder: fieldBorder(t.primary),
        errorBorder: fieldBorder(t.danger),
        focusedErrorBorder: fieldBorder(t.danger),
      ),
      cardTheme: CardThemeData(
        color: t.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.surface,
        showDragHandle: true,
        dragHandleColor: t.border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Radii.sheet),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: t.surface,
        indicatorColor: t.primarySoft,
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(
          text.bodySmall!.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: t.ink,
        contentTextStyle: text.bodyMedium!.copyWith(color: t.onInk),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.field),
        ),
      ),
      dividerTheme: DividerThemeData(color: t.border, thickness: 1, space: 1),
    );
  }

  /// Échelle typographique (`design-system.md` §2).
  static TextTheme _textTheme(Color ink) {
    TextStyle style(
      double size,
      double lineHeight,
      FontWeight weight, [
      double tracking = 0,
    ]) => TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      letterSpacing: size * tracking,
      color: ink,
    );
    final body = style(15, 22, FontWeight.w500);
    return TextTheme(
      displaySmall: style(32, 38, FontWeight.w800, -0.02),
      headlineMedium: style(26, 32, FontWeight.w800, -0.01),
      titleLarge: style(20, 26, FontWeight.w700),
      titleMedium: style(17, 22, FontWeight.w700),
      bodyLarge: body,
      bodyMedium: body,
      labelLarge: style(13, 18, FontWeight.w600),
      bodySmall: style(12, 16, FontWeight.w500),
      labelSmall: style(12, 16, FontWeight.w500),
    );
  }
}
