import 'package:flutter/material.dart';

import 'tokens.dart';

/// Thème Material 3 construit à partir des jetons ; police embarquée dans `core`.
/// Clair uniquement, quel que soit le réglage du téléphone (ADR-019).
abstract final class AppTheme {
  static const fontFamily = 'packages/core/PlusJakartaSans';

  static final light = _build(AppTokens.light);

  static ThemeData _build(AppTokens t) {
    final scheme = ColorScheme(
      brightness: Brightness.light,
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
      surfaceContainerLowest: t.surface,
      surfaceContainerLow: t.surface,
      surfaceContainer: t.surface,
      surfaceContainerHigh: t.surface,
      surfaceContainerHighest: t.surfaceAlt,
      surfaceTint: Colors.transparent,
      outline: t.border,
      outlineVariant: t.border,
      inverseSurface: t.ink,
      onInverseSurface: t.onInk,
      shadow: t.ink,
    );
    final text = _textTheme(t.ink);
    const pill = StadiumBorder();
    const buttonSize = Size.fromHeight(56);
    final buttonText = text.labelLarge!.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w700,
    );
    OutlineInputBorder fieldBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.field),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      fontFamily: fontFamily,
      textTheme: text,
      scaffoldBackgroundColor: t.background,
      splashFactory: InkSparkle.splashFactory,
      extensions: [t],
      // Transitions douces et cohérentes sur toutes les plateformes.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: t.background,
        foregroundColor: t.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: Space.sm,
        titleTextStyle: text.titleLarge!.copyWith(fontWeight: FontWeight.w800),
      ),
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (_) => const Icon(Icons.arrow_back_rounded),
      ),
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
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: t.primary,
        foregroundColor: t.onPrimary,
        elevation: 2,
        highlightElevation: 4,
        shape: pill,
        extendedTextStyle: buttonText,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Space.lg,
          vertical: 18,
        ),
        labelStyle: text.bodyMedium!.copyWith(color: t.muted),
        floatingLabelStyle: text.labelLarge!.copyWith(color: t.primary),
        hintStyle: text.bodyMedium!.copyWith(color: t.muted),
        prefixIconColor: t.muted,
        suffixIconColor: t.muted,
        border: fieldBorder(t.border),
        enabledBorder: fieldBorder(t.border),
        focusedBorder: fieldBorder(t.primary, 1.6),
        errorBorder: fieldBorder(t.danger),
        focusedErrorBorder: fieldBorder(t.danger, 1.6),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: t.surface,
        selectedColor: t.ink,
        disabledColor: t.surfaceAlt,
        showCheckmark: false,
        side: BorderSide(color: t.border),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: 10),
        labelStyle: text.labelLarge!.copyWith(color: t.ink),
        secondaryLabelStyle: text.labelLarge!.copyWith(color: t.onInk),
      ),
      cardTheme: CardThemeData(
        color: t.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
          side: BorderSide(color: t.border),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: t.ink,
        contentPadding: const EdgeInsets.symmetric(horizontal: Space.lg),
        titleTextStyle: text.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
        subtitleTextStyle: text.bodySmall!.copyWith(color: t.muted),
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        thumbColor: WidgetStatePropertyAll(t.surface),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? t.primary : t.border,
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
      dialogTheme: DialogThemeData(
        backgroundColor: t.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: t.surface,
        indicatorColor: t.primarySoft,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(
          text.bodySmall!.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: t.surface,
        indicatorColor: t.primarySoft,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: t.ink,
        contentTextStyle: text.bodyMedium!.copyWith(color: t.onInk),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.field),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: t.primary,
        linearTrackColor: t.surfaceAlt,
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
      displayMedium: style(38, 42, FontWeight.w800, -0.03),
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
