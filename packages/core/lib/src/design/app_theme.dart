import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// Thème Material 3 construit à partir des jetons, en clair et en sombre (ADR-038) ; police embarquée dans `core`.
abstract final class AppTheme {
  static const fontFamily = 'packages/core/PlusJakartaSans';

  static final light = _build(AppTokens.light, Brightness.light);
  static final dark = _build(AppTokens.dark, Brightness.dark);

  /// Thème aux couleurs du logo (orange Tchopi) pour les écrans de marque : accès et démarrage. Orange foncé pour
  /// un texte blanc lisible sur les boutons (contraste ≥ 4,5:1).
  static ThemeData brand(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? AppTokens.dark
        : AppTokens.light;
    return _build(
      base.copyWith(
        primary: brightness == Brightness.dark
            ? const Color(0xFFFF8A3D)
            : const Color(0xFFC2410C),
        onPrimary: brightness == Brightness.dark
            ? const Color(0xFF1A0D04)
            : Colors.white,
        primarySoft: brightness == Brightness.dark
            ? const Color(0xFF3A2112)
            : const Color(0xFFFFF1E6),
      ),
      brightness,
    );
  }

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
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: fontFamily,
      textTheme: text,
      scaffoldBackgroundColor: t.background,
      canvasColor: t.surface,
      iconTheme: IconThemeData(color: t.ink),
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
      // Barre du haut blanche, séparée du contenu par un filet ; légère ombre quand le contenu défile dessous.
      appBarTheme: AppBarTheme(
        backgroundColor: t.surface,
        foregroundColor: t.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: t.ink.withValues(alpha: 0.12),
        shape: Border(bottom: BorderSide(color: t.border)),
        centerTitle: false,
        toolbarHeight: 64,
        titleSpacing: Space.lg,
        systemOverlayStyle:
            (brightness == Brightness.light
                    ? SystemUiOverlayStyle.dark
                    : SystemUiOverlayStyle.light)
                .copyWith(statusBarColor: Colors.transparent),
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
      popupMenuTheme: PopupMenuThemeData(
        color: t.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.field),
          side: BorderSide(color: t.border),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(t.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.field),
              side: BorderSide(color: t.border),
            ),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: t.surface,
          foregroundColor: t.ink,
          selectedBackgroundColor: t.primarySoft,
          selectedForegroundColor: t.primary,
          side: BorderSide(color: t.border),
          textStyle: text.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: Space.sm),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(t.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.field),
              side: BorderSide(color: t.border),
            ),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        side: BorderSide(color: t.muted, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? t.primary : t.muted,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: t.ink,
          borderRadius: BorderRadius.circular(Radii.chip),
        ),
        textStyle: text.bodySmall!.copyWith(color: t.onInk),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: t.primary,
        selectionColor: t.primary.withValues(alpha: 0.3),
        selectionHandleColor: t.primary,
      ),
      // Fenêtres : surface du thème, filet discret, titre et texte de l'échelle typographique.
      dialogTheme: DialogThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium!.copyWith(color: t.muted),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: Space.screen,
          vertical: Space.xxl,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
          side: BorderSide(color: t.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: t.ink,
        indicatorColor: t.primarySoft,
        elevation: 8,
        height: 72,
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
