import 'package:flutter/material.dart';

/// Animated ring progress indicator with rounded caps.
class CircularProgressWidget extends StatelessWidget {
  const CircularProgressWidget({
    super.key,
    required this.value,
    this.size = 88,
    this.strokeWidth = 10,
    this.color,
    this.trackColor,
    this.child,
    this.duration = const Duration(milliseconds: 900),
  });

  final double value;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? trackColor;
  final Widget? child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color progressColor = color ?? scheme.primary;
    final Color track = trackColor ?? scheme.surfaceContainerHighest;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: duration,
      curve: Curves.decelerate,
      builder: (context, animatedValue, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size.square(size),
                painter: _RingPainter(
                  value: animatedValue,
                  color: progressColor,
                  trackColor: track,
                  strokeWidth: strokeWidth,
                ),
              ),
              ?child,
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double value;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (size.shortestSide - strokeWidth) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, trackPaint);

    final Paint progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(
      rect,
      -1.57079633, // start at top
      value * 6.2831853, // full sweep
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
