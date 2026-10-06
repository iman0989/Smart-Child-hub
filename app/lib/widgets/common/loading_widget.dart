import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Animated "bouncing dots" loading indicator (1000 ms loop).
class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key, this.message, this.color, this.dotSize = 12});

  final String? message;
  final Color? color;
  final double dotSize;

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.color ?? Theme.of(context).colorScheme.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final double t = (_controller.value + (i * 0.25)) % 1.0;
                  final double scale = 0.5 + (0.5 * _bounce(t));
                  final double opacity = 0.25 + (0.75 * _bounce(t));
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: widget.dotSize,
                          height: widget.dotSize,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _bounce(double t) {
    // Smooth up-and-down bounce over the full period.
    return -4 * t * (t - 1);
  }
}

/// Standalone progress widget used by async-first screens.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppConstants.bottomNavHeight,
      child: LoadingWidget(message: message, dotSize: 10),
    );
  }
}
