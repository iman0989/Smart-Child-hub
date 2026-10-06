import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import 'animated_background.dart';
import 'app_icon.dart';
import 'app_illustration.dart';
import 'glass_card.dart';
import 'motion.dart';

/// Branded animated background + centered content column for auth screens.
///
/// The animated world renders once behind everything, the logo and copy sit
/// above a single intensive [GlassCard] that holds the actual form.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.showBack = true,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.sch;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenPadding,
                vertical: AppConstants.spaceLg,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppConstants.authMaxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (showBack)
                            Entrance(
                              delay: const Duration(milliseconds: 60),
                              child: Material(
                                // A 55%-white disc reads as frosted glass over
                                // the light backdrop but turns mid grey in dark
                                // mode, where it can no longer carry the
                                // brand-coloured chevron.
                                color: theme.brightness == Brightness.dark
                                    ? theme.colorScheme.surfaceContainerHigh
                                    : Colors.white.withValues(alpha: 0.55),
                                shape: const CircleBorder(),
                                child: IconButton(
                                  tooltip: 'Back',
                                  onPressed: () => Navigator.of(context).maybePop(),
                                  icon: AppIcon(
                                    AppIcons.chevLeft,
                                    size: AppConstants.iconXl,
                                    color: theme.brightness == Brightness.dark
                                        ? theme.colorScheme.onSurfaceVariant
                                        : palette.primary,
                                  ),
                                ),
                              ),
                            )
                          else
                            const SizedBox(width: 48),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spaceMd),
                      Center(
                        child: Entrance(
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: palette.black.withValues(alpha: 0.08),
                                  blurRadius: 26,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: const AppIllustration(
                              IllustrationAssets.logoMark,
                              width: 62,
                              height: 62,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceSection),
                      Center(
                        child: Entrance(
                          delay: const Duration(milliseconds: 120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontFamily: 'Baloo2',
                                  fontWeight: FontWeight.w800,
                                  color: palette.onSurface,
                                ),
                              ),
                              const SizedBox(height: AppConstants.spaceSm),
                              Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: palette.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceXxl),
                      _FormCard(children: children),
                      SizedBox(height: Responsive.screenPadding(context)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The frosted glass panel that contains the auth form fields.
class _FormCard extends StatelessWidget {
  const _FormCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Entrance(
      delay: const Duration(milliseconds: 200),
      child: GlassCard(
        intensive: true,
        padding: const EdgeInsets.all(AppConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1) const SizedBox(height: AppConstants.spaceLg),
            ],
          ],
        ),
      ),
    );
  }
}
