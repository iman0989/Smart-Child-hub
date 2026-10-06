import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

/// Frosted-glass surface with rounded corners, a translucent tint, a subtle
/// hairline border and a soft drop shadow.
///
/// Setting [intensive] to true adds a real [BackdropFilter] blur for floating
/// elements (shell nav, dialogs, hero cards). Regular list cards should leave
/// it off so scrolling stays fast — the translucent fill alone still reads as
/// glass because the animated world is visible through it.
class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
    this.radius = AppConstants.radiusCard,
    this.blur = 22,
    this.intensive = false,
    this.color,
    this.borderColor,
    this.strokeWidth = 1,
    this.shadow = 0.10,
    this.margin,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double radius;
  final double blur;
  final bool intensive;
  final Color? color;
  final Color? borderColor;
  final double strokeWidth;
  final double shadow;
  final EdgeInsets? margin;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.sch;
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    // In dark mode the fill has to sit *below* the world's own lightness. A
    // translucent white wash lifted every glass surface into the mid-tones,
    // where `onSurface` / `onSurfaceVariant` dropped to ~4.4:1; tinting from the
    // theme surface instead keeps the frosted look (the world still shows
    // through, and the blur/border/shadow are unchanged) while leaving the text
    // colours on a surface they were designed for.
    final Color fill =
        widget.color ?? (dark ? palette.surface.withValues(alpha: 0.78) : const Color(0xB3FFFFFF));
    final Color border =
        widget.borderColor ??
        (dark ? Colors.white.withValues(alpha: 0.14) : Colors.white.withValues(alpha: 0.85));
    final Color shadowColor = dark
        ? Colors.black.withValues(alpha: widget.shadow + 0.15)
        : palette.black.withValues(alpha: widget.shadow);

    final double scale = _pressed ? 0.985 : (_hovered ? 1.012 : 1.0);

    final Widget surface = _GlassSurface(
      fill: fill,
      border: border,
      radius: widget.radius,
      strokeWidth: widget.strokeWidth,
      dark: dark,
      child: Padding(padding: widget.padding ?? EdgeInsets.zero, child: widget.child),
    );

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: MouseRegion(
        cursor: widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
          onTapUp: widget.onTap == null ? null : (_) => setState(() => _pressed = false),
          onTapCancel: widget.onTap == null ? null : () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            margin: widget.margin ?? EdgeInsets.zero,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: _hovered ? 34 : 22,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: border.withValues(alpha: 0.6),
                  blurRadius: 0,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.radius),
              child: widget.intensive
                  ? BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
                      child: surface,
                    )
                  : surface,
            ),
          ),
        ),
      ),
    );
  }
}

/// The tinted glass layer (translucent fill + border) rendered on top of the
/// blurred backdrop.
class _GlassSurface extends StatelessWidget {
  const _GlassSurface({
    required this.fill,
    required this.border,
    required this.radius,
    required this.strokeWidth,
    required this.dark,
    required this.child,
  });

  final Color fill;
  final Color border;
  final double radius;
  final double strokeWidth;
  final bool dark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // The sheen is stated directly instead of being derived from the fill's
    // alpha. Deriving it assumed a near-transparent fill, and once the dark
    // fill carries most of the surface colour the lerp ran away and covered the
    // card in near-opaque white.
    final List<Color> stops = dark
        ? <Color>[
            Color.lerp(fill, Colors.white, 0.06)!,
            fill,
            fill,
            Color.lerp(fill, Colors.black, 0.18)!,
          ]
        : <Color>[
            border.withValues(alpha: 0.9).withValues(alpha: 0.30),
            fill,
            fill,
            fill.withValues(alpha: 0.92),
          ];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: stops,
          stops: const [0.0, 0.16, 0.86, 1.0],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border, width: strokeWidth),
      ),
      child: child,
    );
  }
}
