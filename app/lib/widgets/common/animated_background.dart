import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Performance-friendly animated "living world" background.
///
/// Renders a soft gradient base with a few slowly drifting gradient blobs,
/// twinkling floating particles, tiny sparkle stars and translucent bubble
/// rings. Everything is painted with a single [CustomPainter] driven by one
/// repeating [AnimationController], using only transparent paints
/// (no images, no blur filters, no per-frame layout), so it stays smooth.
///
/// Pass an optional [child] to layer UI content on top. Use [opacity] to fade
/// the whole world down when it would distract from dense content, and [dark]
/// to force a variant.
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key, this.child, this.opacity = 1, this.dark});

  /// Optional UI content rendered above the animated world.
  final Widget? child;

  /// Global opacity of the decorative layer (0..1).
  final double opacity;

  /// Force the dark variant; otherwise derived from the ambient brightness.
  final bool? dark;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _animate = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 40));
    _controller.value = 0.25;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool shouldAnimate = !MediaQuery.disableAnimationsOf(context);
    if (shouldAnimate == _animate) return;
    _animate = shouldAnimate;
    if (_animate) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0.25;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness =
        Theme.of(context).brightness == Brightness.dark && widget.dark != false
        ? Brightness.dark
        : (widget.dark == true ? Brightness.dark : Brightness.light);

    return ColoredBox(
      color: brightness == Brightness.dark ? const Color(0xFF0C1026) : const Color(0xFFF3F7FF),
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _WorldPainter(
                    progress: _controller.value,
                    dark: brightness == Brightness.dark,
                    opacity: widget.opacity.clamp(0.0, 1.0),
                  ),
                );
              },
            ),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

/// Static pseudo-random state derived from a fixed seed so the world looks the
/// same on every frame and on every screen (deterministic).
class _World {
  _World({required bool dark}) {
    final math.Random rng = math.Random(20260214);

    // Gradient blobs.
    final List<Color> blobColors = dark
        ? const [Color(0xFF7E92FF), Color(0xFF9E7BFF), Color(0xFF4AD0FE), Color(0xFFDFB0FF)]
        : const [Color(0xFF7E92FF), Color(0xFFA98BFF), Color(0xFF4AD0FE), Color(0xFFFF8FA3)];
    for (int i = 0; i < 4; i++) {
      _blobs.add(
        _Blob(
          color: blobColors[i],
          baseX: 0.5 - 0.4 + (i * 0.26) + rng.nextDouble() * 0.12,
          baseY: 0.35 + rng.nextDouble() * 0.35,
          amp: 40 + rng.nextDouble() * 90,
          speed: 0.06 + rng.nextDouble() * 0.06,
          phase: rng.nextDouble() * math.pi * 2,
          radius: 0.26 + rng.nextDouble() * 0.22,
          alpha: dark ? 0.16 + rng.nextDouble() * 0.06 : 0.16 + rng.nextDouble() * 0.10,
        ),
      );
    }

    // Floating particles.
    for (int i = 0; i < 30; i++) {
      _particles.add(
        _Particle(
          x: rng.nextDouble(),
          y: rng.nextDouble(),
          radius: 1.1 + rng.nextDouble() * 2.1,
          speed: 0.008 + rng.nextDouble() * 0.022,
          phase: rng.nextDouble() * math.pi * 2,
          flicker: 0.7 + rng.nextDouble() * 1.6,
        ),
      );
    }

    // Sparkle stars.
    for (int i = 0; i < 8; i++) {
      _stars.add(
        _Star(
          x: rng.nextDouble(),
          y: rng.nextDouble(),
          radius: 3.5 + rng.nextDouble() * 5.5,
          phase: rng.nextDouble() * math.pi * 2,
          flicker: 0.9 + rng.nextDouble() * 1.4,
          spin: (rng.nextDouble() - 0.5) * 0.15,
        ),
      );
    }

    // Bubble rings.
    for (int i = 0; i < 6; i++) {
      _bubbles.add(
        _Bubble(
          x: rng.nextDouble(),
          y: rng.nextDouble(),
          radius: 24 + rng.nextDouble() * 46,
          speed: 0.006 + rng.nextDouble() * 0.014,
          phase: rng.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  final List<_Blob> _blobs = [];
  final List<_Particle> _particles = [];
  final List<_Star> _stars = [];
  final List<_Bubble> _bubbles = [];
}

class _Blob {
  const _Blob({
    required this.color,
    required this.baseX,
    required this.baseY,
    required this.amp,
    required this.speed,
    required this.phase,
    required this.radius,
    required this.alpha,
  });

  final Color color;
  final double baseX;
  final double baseY;
  final double amp;
  final double speed;
  final double phase;
  final double radius;
  final double alpha;
}

class _Particle {
  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.flicker,
  });

  final double x;
  final double y;
  final double radius;
  final double speed;
  final double phase;
  final double flicker;
}

class _Star {
  const _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.phase,
    required this.flicker,
    required this.spin,
  });

  final double x;
  final double y;
  final double radius;
  final double phase;
  final double flicker;
  final double spin;
}

class _Bubble {
  const _Bubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
  });

  final double x;
  final double y;
  final double radius;
  final double speed;
  final double phase;
}

class _WorldPainter extends CustomPainter {
  _WorldPainter({required this.progress, required this.dark, required this.opacity})
    : _world = _World(dark: dark);

  final double progress;
  final bool dark;
  final double opacity;
  final _World _world;

  static const double _twoPi = math.pi * 2;

  double _loop(double t) => (t % 1.0 + 1.0) % 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.01) return;
    final double w = size.width;
    final double h = size.height;

    canvas.save();
    if (opacity < 1) {
      canvas.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: opacity));
    }

    // 1. Base gradient wash.
    final Paint base = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? const [Color(0xFF0C1026), Color(0xFF171A3A), Color(0xFF0E2A3E)]
            : const [Color(0xFFEFF4FF), Color(0xFFF6F0FF), Color(0xFFE8FAFF)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, base);

    // 2. Drifting gradient blobs.
    for (final _Blob blob in _world._blobs) {
      final double t = _twoPi * progress;
      final double cx = blob.baseX * w + blob.amp * math.sin(blob.speed * t + blob.phase);
      final double cy =
          blob.baseY * h + blob.amp * math.cos(blob.speed * 0.82 * t + blob.phase * 1.3);
      final double radius = blob.radius * w.clamp(300.0, 1200.0);
      final double blowUp = 1.0 + 0.08 * math.sin(t * 0.5 + blob.phase);
      final Color c = blob.color.withValues(alpha: blob.alpha);

      final Paint paint = Paint()
        ..shader = RadialGradient(
          colors: [c, c.withValues(alpha: 0.35), c.withValues(alpha: 0)],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius * 2 * blowUp));
      canvas.drawCircle(Offset(cx, cy), radius * 2 * blowUp, paint);
    }

    // 3. Twinkling particles drifting upward.
    final Color particleColor = dark ? Colors.white : const Color(0xFF3351E8);
    for (final _Particle p in _world._particles) {
      final double y = _loop(p.y - progress * p.speed) * h;
      final double x = p.x * w + 6 * math.sin(_twoPi * progress * 0.4 + p.phase);
      final double twinkle = 0.5 + 0.5 * math.sin(_twoPi * (progress * p.flicker) + p.phase);
      canvas.drawCircle(
        Offset(x, y),
        p.radius * (0.75 + 0.25 * twinkle),
        Paint()..color = particleColor.withValues(alpha: 0.10 + 0.22 * twinkle),
      );
    }

    // 4. Sparkle stars (four-point glints).
    final Color starColor = dark ? Colors.white : const Color(0xFFFFFFFF);
    for (final _Star s in _world._stars) {
      final double y = _loop(s.y - progress * 0.01) * h;
      final double x = s.x * w;
      final double twinkle = 0.5 + 0.5 * math.sin(_twoPi * (progress * s.flicker) + s.phase);
      final double rot = s.spin * _twoPi * progress;
      final double r = s.radius * (0.7 + 0.45 * twinkle);
      final Path path = Path();
      final Offset c = Offset(x, y);
      for (int k = 0; k < 4; k++) {
        final double arm = rot + k * math.pi / 2;
        path.moveTo(c.dx + math.cos(arm) * r, c.dy + math.sin(arm) * r);
        path.lineTo(c.dx, c.dy);
      }
      path.close();
      canvas.drawPath(
        path..close(),
        Paint()..color = starColor.withValues(alpha: 0.10 + 0.45 * twinkle),
      );
    }

    // 5. Bubble rings.
    for (final _Bubble b in _world._bubbles) {
      final double y = _loop(b.y - progress * b.speed) * h;
      final double x = b.x * w;
      final double pulse = 1.0 + 0.06 * math.sin(_twoPi * progress * 0.6 + b.phase);
      canvas.drawCircle(
        Offset(x, y),
        b.radius * pulse,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = (dark ? Colors.white : const Color(0xFF3351E8)).withValues(alpha: 0.06),
      );
    }

    if (opacity < 1) canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WorldPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.dark != dark ||
      oldDelegate.opacity != opacity;
}
