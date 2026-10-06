import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../common/app_icon.dart';
import '../common/glass_card.dart';

/// Generic dashboard section card that standardises look and padding.
class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
    this.glass = true,
  });

  final String? title;
  final String? subtitle;
  final String? icon;
  final Color? iconColor;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color? accent = iconColor;
    // The icon rides on a low-alpha tint of the accent, so its foreground has
    // to be shifted into a readable band while the tint keeps the brand hue.
    final Color iconForeground = onTintAccent(
      accent ?? theme.colorScheme.primary,
      theme.brightness,
    );

    final Widget body = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (accent ?? theme.colorScheme.primary).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppIcon(icon!, size: 18, color: iconForeground),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null) Text(title!, style: theme.textTheme.titleMedium),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );

    if (!glass) {
      return Card(
        child: onTap == null
            ? body
            : InkWell(onTap: onTap, borderRadius: BorderRadius.circular(26), child: body),
      );
    }

    return GlassCard(onTap: onTap, child: body);
  }
}
