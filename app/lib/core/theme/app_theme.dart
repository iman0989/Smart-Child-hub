import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Which zone of the app is active. Affects the body font family and shell.
enum AppMode { parent, child }

/// Builds the Material 3 theme from the Phase 2 design tokens.
class AppTheme {
  AppTheme._();

  static ThemeData light() =>
      _build(palette: AppPalette.light, brightness: Brightness.light, bodyFamily: AppFonts.nunito);

  static ThemeData dark() =>
      _build(palette: AppPalette.dark, brightness: Brightness.dark, bodyFamily: AppFonts.nunito);

  /// Child mode variant: switches the body face to Quicksand.
  static ThemeData childLight() => _build(
    palette: AppPalette.light,
    brightness: Brightness.light,
    bodyFamily: AppFonts.quicksand,
  );

  static ThemeData childDark() =>
      _build(palette: AppPalette.dark, brightness: Brightness.dark, bodyFamily: AppFonts.quicksand);

  static ThemeData _build({
    required AppPalette palette,
    required Brightness brightness,
    required String bodyFamily,
  }) {
    final ColorScheme colorScheme = ColorScheme(
      brightness: brightness,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      primaryContainer: palette.primaryContainer,
      onPrimaryContainer: palette.onPrimaryContainer,
      secondary: palette.secondary,
      onSecondary: palette.onSecondary,
      secondaryContainer: palette.secondaryContainer,
      onSecondaryContainer: palette.onSecondaryContainer,
      tertiary: palette.tertiary,
      onTertiary: palette.onTertiary,
      tertiaryContainer: palette.tertiaryContainer,
      onTertiaryContainer: palette.onTertiaryContainer,
      error: palette.error,
      onError: palette.onError,
      errorContainer: palette.errorContainer,
      onErrorContainer: palette.onErrorContainer,
      surface: palette.surface,
      onSurface: palette.onSurface,
      onSurfaceVariant: palette.onSurfaceVariant,
      outline: palette.outline,
      outlineVariant: palette.outlineVariant,
      surfaceContainer: palette.surfaceContainer,
      surfaceContainerHigh: palette.surfaceContainerHigh,
      surfaceContainerHighest: palette.surfaceContainerHigh,
      surfaceContainerLow: palette.surfaceContainer,
      surfaceContainerLowest: palette.background,
      shadow: palette.black,
      inverseSurface: palette.surfaceVariant,
      onInverseSurface: palette.onSurface,
      inversePrimary: palette.primaryContainer,
      surfaceTint: palette.primary,
    );

    final TextTheme textTheme = AppTextStyles.build(
      bodyFamily: bodyFamily,
      onSurface: palette.onSurface,
    );

    // `outline` is a border tone; in dark mode it is too dim to read as hint or
    // floating label text on the filled field, so fall back to the body tone.
    final Color fieldLabelColor = brightness == Brightness.dark
        ? palette.onSurfaceVariant
        : palette.outline;

    final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
      filled: true,
      fillColor: palette.surfaceContainer,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLg,
        vertical: AppConstants.spaceLg,
      ),
      hintStyle: textTheme.bodyLarge?.copyWith(color: fieldLabelColor),
      labelStyle: textTheme.bodyMedium?.copyWith(color: fieldLabelColor),
      floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: palette.primary),
      prefixIconColor: palette.onSurfaceVariant,
      suffixIconColor: palette.onSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusInput),
        borderSide: BorderSide(color: palette.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusInput),
        borderSide: BorderSide(color: palette.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusInput),
        borderSide: BorderSide(color: palette.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusInput),
        borderSide: BorderSide(color: palette.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusInput),
        borderSide: BorderSide(color: palette.error, width: 2),
      ),
    );

    final CardThemeData cardTheme = CardThemeData(
      color: palette.surface,
      elevation: 1,
      margin: EdgeInsets.zero,
      shadowColor: palette.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      textTheme: textTheme,
      fontFamily: bodyFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: AppConstants.appBarHeight,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: palette.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: cardTheme,
      inputDecorationTheme: inputDecorationTheme,
      dividerTheme: DividerThemeData(color: palette.outlineVariant, thickness: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          minimumSize: const Size(64, AppConstants.controlHeight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusButton),
          ),
          elevation: 0,
          textStyle: textTheme.labelLarge?.copyWith(
            color: palette.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          // The framework default fades disabled labels to 38% of onSurface,
          // which lands near 2.3:1 on the light background. The muted
          // onSurfaceVariant tone still reads as inactive and clears 4.5:1.
          disabledForegroundColor: palette.onSurfaceVariant,
          minimumSize: const Size(64, AppConstants.controlHeight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(color: palette.outlineVariant, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusButton),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          disabledForegroundColor: palette.onSurfaceVariant,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceVariant,
        selectedColor: palette.primary,
        labelStyle: textTheme.labelMedium?.copyWith(color: palette.onSurfaceVariant),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(color: palette.onPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.onPrimary;
          return palette.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.primary;
          return palette.outlineVariant;
        }),
        trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.primaryContainer,
        height: AppConstants.bottomNavHeight,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? palette.primary
                : palette.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? palette.primary
                : palette.onSurfaceVariant,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
        linearTrackColor: palette.surfaceVariant,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.primary,
        foregroundColor: palette.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeThroughTransitionBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeThroughTransitionBuilder(),
          TargetPlatform.macOS: FadeThroughTransitionBuilder(),
          TargetPlatform.linux: FadeThroughTransitionBuilder(),
        },
      ),
    );
  }
}

/// Fade-through page transition used across the app (300 ms, 8% horizontal slide).
class FadeThroughTransitionBuilder extends PageTransitionsBuilder {
  const FadeThroughTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (route.settings.name == '/') {
      return child;
    }
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeOutCubic,
    );
    final slide = Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero).animate(curved);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(position: slide, child: child),
    );
  }
}
