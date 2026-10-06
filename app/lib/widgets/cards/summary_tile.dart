import 'package:flutter/material.dart';

import '../../core/constants/app_icons.dart';
import '../common/app_icon.dart';
import '../common/glass_card.dart';
import '../common/linear_progress_widget.dart';

/// Compact summary tile used on the parent dashboard.
class SummaryTile extends StatelessWidget {
  const SummaryTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.progress,
    this.onTap,
  });

  final String icon;
  final String label;
  final String value;
  final Color color;
  final double? progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withValues(alpha: 0.24), color.withValues(alpha: 0.08)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AppIcon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 8),
                  LinearProgressWidget(value: progress!, color: color, height: 6),
                ],
              ],
            ),
          ),
          AppIcon(AppIcons.chevRight, size: 20, color: theme.colorScheme.outline),
        ],
      ),
    );
  }
}
