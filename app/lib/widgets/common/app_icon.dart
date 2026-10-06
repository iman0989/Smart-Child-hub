import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_icons.dart';

/// Renders one of the custom SVG icons from the Phase 2 icon set.
class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, this.size = 24, this.color, this.semanticLabel});

  /// Icon name from [AppIcons].
  final String icon;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    // The SVG assets are painted with `currentColor`, which resolves to black
    // unless a filter is supplied, so default to the theme's on-surface tone to
    // keep icons legible in dark mode.
    final Color tint = color ?? Theme.of(context).colorScheme.onSurface;
    return SvgPicture.asset(
      IconAssets.get(icon),
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      semanticsLabel: semanticLabel ?? 'icon',
    );
  }
}
