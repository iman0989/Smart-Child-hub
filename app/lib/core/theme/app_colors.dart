import 'package:flutter/material.dart';

/// Semantic color tokens from the Phase 2 design system.
///
/// Two immutable palettes (light + dark) are shipped. Widgets must resolve
/// colors through [BuildContext.sch] so raw hex values never leak into UI.
class AppPalette {
  const AppPalette({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.outline,
    required this.outlineVariant,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.info,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.sunshine,
    required this.candy,
    required this.sky,
    required this.grape,
    required this.mint,
    required this.peach,
    required this.white,
    required this.black,
  });

  // Brand
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;

  // Surfaces
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color outline;
  final Color outlineVariant;

  // Feedback
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color info;
  final Color infoContainer;
  final Color onInfoContainer;

  // Accents
  final Color sunshine;
  final Color candy;
  final Color sky;
  final Color grape;
  final Color mint;
  final Color peach;

  final Color white;
  final Color black;

  // Light-mode accents are tuned so every token clears WCAG when used as a
  // foreground on its own surface: `primary`/`outline`/`error` each sit at
  // >= 4.5:1 on white and on `background`, which is why they are a shade deeper
  // than the pure brand hues used for decorative fills and gradients.
  static const AppPalette light = AppPalette(
    primary: Color(0xFF4359E0),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDDE5FF),
    onPrimaryContainer: Color(0xFF0E1E5C),
    secondary: Color(0xFFFF8A3D),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFFE0C7),
    onSecondaryContainer: Color(0xFF45260A),
    tertiary: Color(0xFF1FBFA0),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFC4F6E8),
    onTertiaryContainer: Color(0xFF004534),
    background: Color(0xFFF7F8FE),
    onBackground: Color(0xFF191A24),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF191A24),
    surfaceVariant: Color(0xFFE9EAF6),
    onSurfaceVariant: Color(0xFF43434F),
    surfaceContainer: Color(0xFFF1F2FB),
    surfaceContainerHigh: Color(0xFFE9EAF6),
    outline: Color(0xFF666675),
    outlineVariant: Color(0xFFD5D6E4),
    error: Color(0xFFC5302D),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    warning: Color(0xFFFF9F0A),
    warningContainer: Color(0xFFFFF3D1),
    onWarningContainer: Color(0xFF452A00),
    success: Color(0xFF1B8549),
    successContainer: Color(0xFFD7F2E2),
    onSuccessContainer: Color(0xFF02371C),
    info: Color(0xFF2E7BF6),
    infoContainer: Color(0xFFDBE9FD),
    onInfoContainer: Color(0xFF03214D),
    sunshine: Color(0xFFFFC93C),
    candy: Color(0xFFFF7BA9),
    sky: Color(0xFF54C3F6),
    grape: Color(0xFFA98BFF),
    mint: Color(0xFF3DDB9E),
    peach: Color(0xFFFFB37A),
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
  );

  static const AppPalette dark = AppPalette(
    primary: Color(0xFFB7C4FF),
    onPrimary: Color(0xFF10225E),
    primaryContainer: Color(0xFF334798),
    onPrimaryContainer: Color(0xFFDCE4FF),
    secondary: Color(0xFFFFB37A),
    onSecondary: Color(0xFF5B2D0A),
    secondaryContainer: Color(0xFF7A3F10),
    onSecondaryContainer: Color(0xFFFFE0C7),
    tertiary: Color(0xFF57D8B9),
    onTertiary: Color(0xFF00382B),
    tertiaryContainer: Color(0xFF005244),
    onTertiaryContainer: Color(0xFFC4F6E8),
    background: Color(0xFF12131A),
    onBackground: Color(0xFFE6E6EE),
    surface: Color(0xFF1B1C25),
    onSurface: Color(0xFFE6E6EE),
    surfaceVariant: Color(0xFF30313D),
    onSurfaceVariant: Color(0xFFC7C8D4),
    surfaceContainer: Color(0xFF23242F),
    surfaceContainerHigh: Color(0xFF2C2D39),
    outline: Color(0xFF8B8C9A),
    outlineVariant: Color(0xFF3E3F4B),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    warning: Color(0xFFFFC661),
    warningContainer: Color(0xFF4A3400),
    onWarningContainer: Color(0xFFFFF3D1),
    success: Color(0xFF7DDBA5),
    successContainer: Color(0xFF1E5434),
    onSuccessContainer: Color(0xFFD7F2E2),
    info: Color(0xFF9FC6FF),
    infoContainer: Color(0xFF234369),
    onInfoContainer: Color(0xFFDBE9FD),
    sunshine: Color(0xFFFFC93C),
    candy: Color(0xFFFF7BA9),
    sky: Color(0xFF54C3F6),
    grape: Color(0xFFA98BFF),
    mint: Color(0xFF3DDB9E),
    peach: Color(0xFFFFB37A),
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
  );
}

/// Theme-aware access to the palette tokens.
extension AppPaletteContext on BuildContext {
  AppPalette get sch =>
      Theme.of(this).brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;
}

/// Dark-mode counterpart for the light brand accents that feature screens
/// hard-code as foreground colours (icon and pill-label tones).
///
/// Light mode returns [accent] untouched so its appearance is unchanged; in
/// dark mode the accent is swapped for the matching dark-palette tone, which
/// is light enough to stay readable on the dark tinted containers. Accents
/// that are identical in both palettes (`sunshine`, `candy`, `sky`) need no
/// mapping and fall through unchanged.
Color resolveAccent(Color accent, Brightness brightness) {
  if (brightness != Brightness.dark) return accent;
  if (accent == AppPalette.light.primary) return AppPalette.dark.primary;
  if (accent == const Color(0xFF7A5BF5)) return AppPalette.dark.grape;
  if (accent == const Color(0xFF8A5BF5)) return AppPalette.dark.grape;
  if (accent == const Color(0xFF1FBFA0)) return AppPalette.dark.tertiary;
  if (accent == const Color(0xFFFF8A3D)) return AppPalette.dark.secondary;
  if (accent == const Color(0xFF2FAE66)) return AppPalette.dark.success;
  if (accent == const Color(0xFFFF9F0A)) return AppPalette.dark.warning;
  if (accent == AppPalette.light.error) return AppPalette.dark.error;
  if (accent == const Color(0xFF9AA4B5)) return AppPalette.dark.onSurfaceVariant;
  return accent;
}

/// Foreground tone for an icon or label that sits on a low-alpha tint of
/// [accent] (the `accent @ 10-22%` chips, pills and icon tiles used across the
/// dashboards).
///
/// A brand accent is tuned for fills, not for text: the raw hue only reaches
/// ~2-3:1 against its own tint, so using it as a foreground falls short of both
/// the 4.5:1 body-text and the 3:1 non-text minimum. This keeps the hue but
/// shifts it into a readable band — darker in light mode (the tint is near
/// white there), lighter in dark mode via [resolveAccent].
Color onTintAccent(Color accent, Brightness brightness) {
  if (brightness == Brightness.dark) {
    // Resolve the dark-mode hue first, then lift it well clear of the tinted
    // container: the tint composites to a mid tone on a dark surface, so the
    // palette tone on its own still lands around 2.9:1.
    return Color.lerp(resolveAccent(accent, brightness), AppPalette.light.white, 0.45)!;
  }
  return Color.lerp(accent, AppPalette.light.black, 0.55)!;
}
