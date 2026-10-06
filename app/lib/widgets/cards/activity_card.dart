import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../common/app_icon.dart';
import '../common/glass_card.dart';
import '../common/linear_progress_widget.dart';

/// Tappable activity card with an optional progress bar.
class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.value,
    this.progress,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final String? value;
  final double? progress;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // The icon tile is a low-alpha wash of [color] and the value sits directly on
    // the card, so both foregrounds use the readable variant of the accent; the
    // wash and the progress bar keep the accent hue.
    final Color accentForeground = onTintAccent(color, theme.brightness);
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withValues(alpha: 0.26), color.withValues(alpha: 0.08)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: AppIcon(icon, size: 22, color: accentForeground),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (value != null)
                Text(
                  value!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: accentForeground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 14),
            LinearProgressWidget(value: progress!, color: color, height: 8),
          ],
        ],
      ),
    );
  }
}
