import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/app_illustration.dart';
import '../../widgets/common/world_screen.dart';

/// About screen: brand, version and credits.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppPalette palette = context.sch;

    return WorldScreen(
      title: 'About',
      subtitle: AppConstants.appName,
      child: ListView(
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: palette.black.withValues(alpha: 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const AppIllustration(IllustrationAssets.logoMark, width: 72, height: 72),
                ),
                const SizedBox(height: 16),
                Text(AppConstants.appName, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  AppConstants.appFullName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: palette.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: palette.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Version ${AppConstants.version}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: palette.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AppIcon(AppIcons.sparkle, size: 22),
                      const SizedBox(width: 10),
                      Text('Why Smart Child Hub?', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Smart Child Hub helps families build happy daily habits. '
                    'Track sleep, meals, hydration, mood, homework and more — '
                    'while kids earn coins and unlock achievements along the way.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Made with love', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(
                    AppConstants.madeFor,
                    style: theme.textTheme.bodyMedium?.copyWith(color: palette.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              AppConstants.copyright,
              style: theme.textTheme.bodySmall?.copyWith(color: palette.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
