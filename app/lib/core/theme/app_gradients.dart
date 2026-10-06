import 'package:flutter/material.dart';

/// Brand gradient recipes used across the redesigned UI.
///
/// Keeps the "Smart Child Hub" palette (primary blue → violet → cyan → orange)
/// consistent everywhere: hero cards, buttons, progress rings, icons and the
/// animated world background.
class AppGradients {
  AppGradients._();

  /// Brand indigo → violet. The primary action gradient.
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4359E0), Color(0xFF8A5BF5)],
  );

  /// Softer brand gradient for large hero surfaces.
  static const LinearGradient brandSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C7BFF), Color(0xFFA98BFF)],
  );

  /// Aqua → sky for water / hydration accents.
  static const LinearGradient ocean = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22C5E6), Color(0xFF54C3F6)],
  );

  /// Mint → teal for health / success accents.
  static const LinearGradient mint = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2FC98B), Color(0xFF1FBFA0)],
  );

  /// Sunrise → peach for energetic accents (play, exercise).
  static const LinearGradient sunshine = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC93C), Color(0xFFFF8A3D)],
  );

  /// Candy pink gradient for screen-time / fun accents.
  static const LinearGradient candy = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF7BA9), Color(0xFFE86AB2)],
  );

  /// Night sky gradient for sleep accents.
  static const LinearGradient twilight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A4EF0), Color(0xFF8A5BF5)],
  );

  /// Deep blue → cyan headline gradient used for greeting text.
  static const LinearGradient headline = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF3351E8), Color(0xFF37C5EE)],
  );

  /// Applies a [Gradient] over [color] to derive matching text colours.
  static Shader shader(Gradient gradient, Rect rect) => gradient.createShader(rect);
}
