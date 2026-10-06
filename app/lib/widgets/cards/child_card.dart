import 'package:flutter/material.dart';

import '../../models/child_model.dart';
import '../common/app_icon.dart';
import '../common/child_avatar.dart';
import '../common/glass_card.dart';

/// Child summary row used on the parent dashboard and manage-children lists.
class ChildCard extends StatelessWidget {
  const ChildCard({
    super.key,
    required this.child,
    this.subtitle,
    this.progress,
    this.onTap,
    this.trailing,
    this.selected = false,
  });

  final ChildModel child;
  final String? subtitle;
  final double? progress;
  final VoidCallback? onTap;
  final Widget? trailing;

  /// Highlights the card as the child the dashboard is currently focused on.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color accent = scheme.primary;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      color: selected ? scheme.primaryContainer.withValues(alpha: 0.45) : null,
      borderColor: selected ? accent : null,
      strokeWidth: selected ? 2 : 1,
      child: Row(
        children: [
          Stack(
            children: [
              ChildAvatar(
                name: child.name,
                avatarKey: child.avatarKey,
                size: 48,
                photoUrl: child.photoUrl,
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppIcon('coin', size: 12),
                      const SizedBox(width: 3),
                      Text(
                        '${child.coins}',
                        style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(child.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle ?? '${child.age} years · ${child.grade}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (progress != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            color: accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${(progress! * 100).round()}%',
                        style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing! else if (!selected) const AppIcon('chev_right', size: 20),
        ],
      ),
    );
  }
}
