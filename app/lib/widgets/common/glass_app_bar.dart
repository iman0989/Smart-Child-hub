import 'package:flutter/material.dart';

import '../../core/constants/app_icons.dart';
import 'app_icon.dart';
import 'glass_card.dart';
import 'motion.dart';

/// Floating frosted top bar used on screens that sit on the animated world.
/// Renders above the page content (caller places it in a [SafeArea]).
class GlassAppBar extends StatelessWidget {
  const GlassAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.actions = const [],
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final List<Widget> actions;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Entrance(
        child: GlassCard(
          intensive: true,
          radius: 22,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            children: [
              if (showBack)
                Material(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'Back',
                    visualDensity: VisualDensity.compact,
                    onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                    icon: AppIcon(AppIcons.chevLeft, size: 24),
                  ),
                ),
              if (showBack) const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }
}
