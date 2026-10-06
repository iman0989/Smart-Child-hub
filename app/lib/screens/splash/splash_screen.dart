import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/animated_background.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/app_illustration.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/motion.dart';

/// Brand splash over the animated world with a short reveal animation.
///
/// While the logo animates in it restores any persisted session (auto-login);
/// afterwards it routes to the parent shell or the onboarding flow.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(AppConstants.splashDuration, _next);
  }

  Future<void> _next() async {
    if (!mounted) return;
    final AuthProvider auth = context.read<AuthProvider>();
    final bool loggedIn = await auth.restoreSession();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacementNamed(loggedIn ? AppRoutes.parentShell : AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppPalette palette = context.sch;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedBackground()),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                PopIn(
                  duration: const Duration(milliseconds: 900),
                  child: Container(
                    width: 148,
                    height: 148,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4359E0).withValues(alpha: 0.16),
                          blurRadius: 34,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: AppIllustration(IllustrationAssets.logoMark, width: 100, height: 100),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4359E0), Color(0xFF8A5BF5)],
                  ).createShader(bounds),
                  child: const Text(
                    'Smart Child Hub',
                    style: TextStyle(
                      fontFamily: 'Baloo2',
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppConstants.tagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(flex: 3),
                Entrance(
                  delay: const Duration(milliseconds: 250),
                  child: Column(
                    children: [
                      const LoadingWidget(color: Color(0xFF4359E0), dotSize: 10),
                      const SizedBox(height: 10),
                      GlassCard(
                        intensive: true,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        radius: 18,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppIcon(
                              AppIcons.sparkle,
                              size: 15,
                              color: onTintAccent(palette.secondary, theme.brightness),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Preparing your family hub…',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  AppConstants.madeFor,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
