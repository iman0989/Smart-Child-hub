import 'package:flutter/material.dart';

/// Reusable entrance + micro-interaction primitives.
///
/// All animations are transform/opacity based (GPU friendly) and stay within
/// the 200–700 ms target band.
class Motion {
  Motion._();

  static const Curve standard = Curves.easeOutCubic;
  static const Curve spring = Curves.easeOutBack;
}

/// Fades + slides a child in, with an optional [delay].
///
/// `offset` is expressed in fraction of its own length; the default 0.06
/// gives a gentle rise. Use `from` (scale) to add a subtle pop-in.
class Entrance extends StatelessWidget {
  const Entrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 520),
    this.offset = const Offset(0, 0.06),
    this.curve = Motion.standard,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final double delayRatio = (delay.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      key: ValueKey('entrance-$delay-$offset'),
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Interval(delayRatio, 1, curve: curve),
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: offset * (1 - t), child: child),
        );
      },
      child: child,
    );
  }
}

/// Pop-in entrance used for icons and avatar chips (scale + fade).
class PopIn extends StatelessWidget {
  const PopIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 480),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final double delayRatio = (delay.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Interval(delayRatio, 1, curve: Motion.spring),
      builder: (context, t, child) {
        final double scale = 0.6 + 0.4 * t;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: child,
    );
  }
}

/// Renders [children] as a column whose items fade-in sequentially.
class Staggered extends StatelessWidget {
  const Staggered({
    super.key,
    required this.children,
    this.spacing = 0,
    this.step = const Duration(milliseconds: 70),
    this.start = const Duration(milliseconds: 120),
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.mainAxisSize = MainAxisSize.max,
  });

  final List<Widget> children;
  final double spacing;
  final Duration step;
  final Duration start;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: spacing),
          Entrance(delay: start + step * i, child: children[i]),
        ],
      ],
    );
  }
}

/// Adds a gentle scale-down press effect and optional hover lift.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
    this.hoverScale = 1.02,
    this.duration = const Duration(milliseconds: 180),
    this.onLongPress,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final double hoverScale;
  final Duration duration;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    double target = 1;
    if (_pressed) {
      target = widget.pressedScale;
    } else if (_hovered) {
      target = widget.hoverScale;
    }

    return MouseRegion(
      cursor: widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
        onTapUp: widget.onTap == null ? null : (_) => setState(() => _pressed = false),
        onTapCancel: widget.onTap == null ? null : () => setState(() => _pressed = false),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: target,
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}

/// A thin animated gradient divider that draws itself in from the left.
class GradientRule extends StatelessWidget {
  const GradientRule({
    super.key,
    this.gradient = const LinearGradient(colors: [Color(0xFF7E92FF), Color(0xFFFF8FA3)]),
    this.height = 3,
    this.width = 56,
    this.delay = Duration.zero,
  });

  final Gradient gradient;
  final double height;
  final double width;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Entrance(
      delay: delay,
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}
