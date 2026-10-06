import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/animated_background.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/app_illustration.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/motion.dart';
import '../../widgets/common/primary_button.dart';

/// Three-page onboarding flow shown once after the splash.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenData {
  const _OnboardingScreenData(this.title, this.message, this.illustration);

  final String title;
  final String message;
  final String illustration;
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const List<_OnboardingScreenData> _pages = [
    _OnboardingScreenData(
      'Welcome to Smart Child Hub!',
      "Your family's offline smart hub for happy daily habits. Track routines, earn coins and grow together.",
      IllustrationAssets.welcomeHero,
    ),
    _OnboardingScreenData(
      'Track every habit',
      'Sleep, meals, water, mood, homework and screen time — all in one cheerful place for the whole family.',
      IllustrationAssets.sunnyMascot,
    ),
    _OnboardingScreenData(
      'Family in sync',
      'Parents manage routines and reports, kids collect stars and badges. Watch progress with weekly charts.',
      IllustrationAssets.celebration,
    ),
  ];

  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.sch;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: AnimatedBackground(opacity: 0.85)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceLg,
                    vertical: AppConstants.spaceSm,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          // A 55%-white tile reads as frosted glass over the
                          // light backdrop but turns mid grey in dark mode,
                          // where it can no longer carry an accent glyph.
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.surfaceContainerHigh
                              : Colors.white.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).colorScheme.outlineVariant
                                : Colors.white,
                          ),
                        ),
                        child: AppIcon(
                          AppIcons.sparkle,
                          size: 20,
                          color: onTintAccent(palette.secondary, Theme.of(context).brightness),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: palette.primary),
                        onPressed: () =>
                            Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                        child: const Text('Skip'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      final _OnboardingScreenData page = _pages[index];
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.screenPadding,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Entrance(
                              key: ValueKey('onboarding-page-$index'),
                              duration: const Duration(milliseconds: 500),
                              child: GlassCard(
                                intensive: true,
                                padding: const EdgeInsets.all(AppConstants.spaceXxl),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final double artHeight = (constraints.maxHeight - 200).clamp(
                                      110.0,
                                      240.0,
                                    );
                                    return SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AppIllustration(
                                            page.illustration,
                                            width: artHeight,
                                            height: artHeight,
                                          ),
                                          const SizedBox(height: AppConstants.spaceXxl),
                                          Text(
                                            page.title,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context).textTheme.headlineSmall
                                                ?.copyWith(
                                                  fontFamily: 'Baloo2',
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                          const SizedBox(height: AppConstants.spaceMd),
                                          Text(
                                            page.message,
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              color: palette.onSurfaceVariant,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _PageDots(count: _pages.length, current: _currentPage),
                Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceXxl),
                  child: PrimaryButton(
                    label: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    icon: _currentPage == _pages.length - 1 ? AppIcons.sparkle : null,
                    onPressed: _next,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final bool active = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXs),
          width: active ? 28 : 9,
          height: 9,
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF4359E0), Color(0xFF8A5BF5)],
                  )
                : null,
            color: active ? null : scheme.outlineVariant,
            borderRadius: BorderRadius.circular(999),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: const Color(0xFF4359E0).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
