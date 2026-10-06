/// App-wide constants. Single source of truth for static configuration.
library;

class AppConstants {
  AppConstants._();

  static const String appName = 'Smart Child Hub';
  static const String appFullName = 'Smart Child Daily Activity Tracking System';
  static const String tagline = "Your family's smart hub for happy daily habits";
  static const String madeFor = 'Made for happy little routines';
  static const String version = '1.0.0';
  static const String copyright = 'Sunny © 2026 Smart Child Hub';

  /// Dummy credentials used by the offline authentication service.
  static const String demoEmail = 'dana@example.com';
  static const String demoPassword = '123456';
  static const String demoName = 'Dana Smith';
  static const String demoPhone = '+1 555 010 2030';

  /// Splash display duration before navigating to the next screen.
  static const Duration splashDuration = Duration(milliseconds: 1900);

  /// Largest child photo accepted by the upload API. Checked in the app so an
  /// oversized image is rejected before the bytes are sent over the network;
  /// the server enforces the same 5 MB limit.
  static const int maxPhotoUploadBytes = 5 * 1024 * 1024;

  /// Layout tokens from the Phase 2 design system.
  static const double screenPadding = 24;
  static const double screenPaddingExpanded = 32;
  static const double cardPadding = 20;
  static const double gridGap = 16;
  static const double sectionGap = 32;
  static const double contentMaxWidth = 880;
  static const double dashboardMaxWidth = 980;
  static const double authMaxWidth = 440;
  static const double touchTargetMin = 48;
  static const double bottomNavHeight = 80;
  static const double appBarHeight = 64;

  /// Standardized control geometry (Phase 2 design system).
  static const double controlHeight = 54;
  static const double iconSm = 18;
  static const double iconMd = 20;
  static const double iconLg = 22;
  static const double iconXl = 25;

  /// Standardized corner radii (Phase 2 design system).
  static const double radiusSm = 12;
  static const double radiusInput = 16;
  static const double radiusButton = 18;
  static const double radiusCard = 24;
  static const double radiusPill = 999;

  /// 4pt spacing scale used across every screen.
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 20;
  static const double spaceXxl = 24;
  static const double spaceSection = 32;
}

/// Design-system breakpoints.
class Breakpoints {
  Breakpoints._();

  static const double compact = 600;
  static const double expanded = 840;
}

/// Motion tokens from the Phase 2 design system.
class AppDurations {
  AppDurations._();

  static const Duration instant = Duration(milliseconds: 50);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration gentle = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration extra = Duration(milliseconds: 750);
}
