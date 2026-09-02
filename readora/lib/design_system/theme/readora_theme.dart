import 'package:flutter/material.dart';
import 'package:readora/design_system/tokens/readora_colors.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/tokens/readora_typography.dart';

/// Builds `ThemeData` from the tokens and nothing else.
///
/// If a value here is not a token reference, it is a bug: it means the design
/// system has a gap that got patched locally instead of imported.
abstract final class ReadoraTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final bg = isDark ? ReadoraColors.darkBackground : ReadoraColors.lightBackground;
    final surface = isDark ? ReadoraColors.darkSurface : ReadoraColors.lightSurface;
    final surfaceWarm =
        isDark ? ReadoraColors.darkSurfaceWarm : ReadoraColors.lightSurfaceWarm;
    final ink = isDark ? ReadoraColors.darkTextPrimary : ReadoraColors.lightTextPrimary;
    final ink2 =
        isDark ? ReadoraColors.darkTextSecondary : ReadoraColors.lightTextSecondary;
    final hairline = isDark ? ReadoraColors.darkBorder : ReadoraColors.lightBorder;
    final gold = isDark ? ReadoraColors.darkGold : ReadoraColors.lightGold;
    final ai = isDark ? ReadoraColors.darkAi : ReadoraColors.lightAi;
    final danger = isDark ? ReadoraColors.darkDanger : ReadoraColors.lightDanger;

    // Gold is a mid-tone: dark ink sits on it in light mode, the near-black
    // background in dark mode. Both were checked at 4.5:1.
    final onGold = isDark ? ReadoraColors.darkBackground : ReadoraColors.lightTextPrimary;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: gold,
      onPrimary: onGold,
      primaryContainer: surfaceWarm,
      onPrimaryContainer: ink,
      secondary: ai,
      onSecondary: isDark ? ReadoraColors.darkBackground : ReadoraColors.lightSurface,
      secondaryContainer: isDark ? ReadoraColors.darkAiSoft : ReadoraColors.lightAiSoft,
      onSecondaryContainer: ink,
      error: danger,
      onError: isDark ? ReadoraColors.darkBackground : ReadoraColors.lightSurface,
      surface: surface,
      onSurface: ink,
      surfaceContainerHighest: surfaceWarm,
      onSurfaceVariant: ink2,
      outline: hairline,
      outlineVariant: hairline,
      scrim: isDark ? ReadoraColors.darkScrim : ReadoraColors.lightScrim,
    );

    final textTheme = ReadoraType.textTheme.apply(
      bodyColor: ink,
      displayColor: ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      dividerColor: hairline,
      splashFactory: InkSparkle.splashFactory,

      // The artboards have no filled app bar anywhere — the page background
      // runs straight under the status bar and the title is set in the serif.
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),

      // Pill is the design's default for buttons and inputs.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: onGold,
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          side: BorderSide(color: hairline),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: gold,
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: gold,
        foregroundColor: onGold,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        extendedTextStyle: textTheme.labelLarge,
        shape: const StadiumBorder(),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.gutter,
          vertical: Spacing.lg,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: isDark
              ? ReadoraColors.darkTextTertiary
              : ReadoraColors.lightTextTertiary,
        ),
        labelStyle: textTheme.bodyMedium,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.pill),
          borderSide: BorderSide(color: hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.pill),
          borderSide: BorderSide(color: hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.pill),
          borderSide: BorderSide(color: gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.pill),
          borderSide: BorderSide(color: danger),
        ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
          side: BorderSide(color: hairline),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        indicatorColor: gold.withValues(alpha: 0.16),
        elevation: 0,
        height: 88,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelMedium?.copyWith(letterSpacing: 0.6),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? gold
                : (isDark
                    ? ReadoraColors.darkTextTertiary
                    : ReadoraColors.lightTextTertiary),
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: gold.withValues(alpha: 0.16),
        side: BorderSide(color: hairline),
        shape: const StadiumBorder(),
        labelStyle: textTheme.labelMedium!.copyWith(color: ink2),
        secondaryLabelStyle: textTheme.labelMedium!.copyWith(color: ink),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        showCheckmark: false,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? surfaceWarm : ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? ink : ReadoraColors.lightBackground,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        elevation: 0,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: gold,
        linearTrackColor: hairline,
        circularTrackColor: hairline,
      ),

      dividerTheme: DividerThemeData(color: hairline, thickness: 1, space: 1),

      listTileTheme: ListTileThemeData(
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall,
        iconColor: ink2,
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          //TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
