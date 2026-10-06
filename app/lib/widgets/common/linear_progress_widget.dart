import 'package:flutter/material.dart';

/// Animated linear progress bar with rounded corners.
class LinearProgressWidget extends StatelessWidget {
  const LinearProgressWidget({
    super.key,
    required this.value,
    this.height = 10,
    this.color,
    this.trackColor,
    this.duration = const Duration(milliseconds: 900),
  });

  final double value;
  final double height;
  final Color? color;
  final Color? trackColor;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color progressColor = color ?? scheme.primary;
    final Color track = trackColor ?? scheme.surfaceContainerHighest;

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Container(width: double.infinity, color: track),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value.clamp(0, 1)),
              duration: duration,
              curve: Curves.decelerate,
              builder: (context, animatedValue, _) => Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: animatedValue,
                  child: Container(
                    decoration: BoxDecoration(
                      color: progressColor,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
