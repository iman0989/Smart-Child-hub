import 'package:flutter/material.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../common/animated_counter.dart';
import '../common/app_icon.dart';
import '../common/glass_card.dart';
import '../common/status_pill.dart';

/// Big-number statistic card used on dashboards and reports.
class StatisticCard extends StatelessWidget {
  const StatisticCard({
    super.key,
    required this.label,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    required this.icon,
    this.color,
    this.delta,
    this.onTap,
    this.intensive = false,
  });

  final String label;
  final int value;
  final String prefix;
  final String suffix;
  final String icon;
  final Color? color;
  final String? delta;
  final VoidCallback? onTap;
  final bool intensive;

  @override
  Widget build(BuildContext context) {
    final Color accent = color ?? Theme.of(context).colorScheme.primary;
    // The icon and the delta pill both sit on tints of the accent, so their
    // foregrounds use the readable variant while the tints keep the accent hue.
    final Color accentForeground = onTintAccent(accent, Theme.of(context).brightness);
    final TextStyle numberStyle = Theme.of(context).textTheme.titleLarge!.copyWith(
      fontWeight: FontWeight.w800,
      fontSize: 30,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return GlassCard(
      onTap: onTap,
      intensive: intensive,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accent.withValues(alpha: 0.22), accent.withValues(alpha: 0.10)],
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: AppIcon(icon, size: 20, color: accentForeground),
              ),
              if (delta != null)
                StatusPill(label: delta!, color: accentForeground, icon: AppIcons.lightning),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedCounter(value: value, prefix: prefix, suffix: suffix, style: numberStyle),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
