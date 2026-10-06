import 'package:flutter/material.dart';

/// Font families bundled from the Phase 2 design system.
class AppFonts {
  AppFonts._();

  static const String baloo = 'Baloo2';
  static const String quicksand = 'Quicksand';
  static const String nunito = 'Nunito';
}

/// Typography scale from the Phase 2 design system.
///
/// Display + headline roles always render in Baloo 2 (the brand display face).
/// Body / title / label roles use the mode body face (Quicksand in child mode,
/// Nunito in parent mode).
class AppTextStyles {
  AppTextStyles._();

  static const double _statLargeSize = 48;
  static const double _statMediumSize = 28;
  static const double _statSmallSize = 18;

  static TextTheme build({required String bodyFamily, required Color onSurface}) {
    TextStyle display(String family, double size, double height, FontWeight weight) => TextStyle(
      fontFamily: family,
      fontSize: size,
      height: height / size,
      fontWeight: weight,
      color: onSurface,
    );

    TextStyle body(double size, double height, FontWeight weight) => TextStyle(
      fontFamily: bodyFamily,
      fontSize: size,
      height: height / size,
      fontWeight: weight,
      color: onSurface,
    );

    return TextTheme(
      displayLarge: display(AppFonts.baloo, 57, 60, FontWeight.w800),
      displayMedium: display(AppFonts.baloo, 45, 48, FontWeight.w700),
      displaySmall: display(AppFonts.baloo, 36, 40, FontWeight.w700),
      headlineLarge: display(AppFonts.baloo, 32, 36, FontWeight.w700),
      headlineMedium: display(AppFonts.baloo, 28, 32, FontWeight.w700),
      headlineSmall: display(AppFonts.baloo, 24, 28, FontWeight.w700),
      titleLarge: body(22, 26, FontWeight.w700),
      titleMedium: body(16, 24, FontWeight.w600),
      titleSmall: body(14, 20, FontWeight.w600),
      bodyLarge: body(16, 24, FontWeight.w400),
      bodyMedium: body(14, 20, FontWeight.w400),
      bodySmall: body(12, 16, FontWeight.w400),
      labelLarge: body(14, 20, FontWeight.w600),
      labelMedium: body(12, 16, FontWeight.w600),
      labelSmall: body(11, 16, FontWeight.w600),
    );
  }

  /// Big numerals used for balances, totals and dashboard statistics.
  /// Numerals use tabular figures so totals stay visually stable.
  static TextStyle statLarge({required Color color}) => TextStyle(
    fontFamily: AppFonts.nunito,
    fontSize: _statLargeSize,
    height: 52 / _statLargeSize,
    fontWeight: FontWeight.w800,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle statMedium({required Color color}) => TextStyle(
    fontFamily: AppFonts.nunito,
    fontSize: _statMediumSize,
    height: 32 / _statMediumSize,
    fontWeight: FontWeight.w800,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle statSmall({required Color color}) => TextStyle(
    fontFamily: AppFonts.nunito,
    fontSize: _statSmallSize,
    height: 24 / _statSmallSize,
    fontWeight: FontWeight.w700,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

/// Shortcuts for a styled text in the active theme.
extension AppTextContext on BuildContext {
  TextTheme get schText => Theme.of(this).textTheme;

  TextStyle get schStatLarge =>
      AppTextStyles.statLarge(color: Theme.of(this).colorScheme.onSurface);

  TextStyle get schStatMedium =>
      AppTextStyles.statMedium(color: Theme.of(this).colorScheme.onSurface);

  TextStyle get schStatSmall =>
      AppTextStyles.statSmall(color: Theme.of(this).colorScheme.onSurface);
}
