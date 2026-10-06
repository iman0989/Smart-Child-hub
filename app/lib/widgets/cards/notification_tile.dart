import 'package:flutter/material.dart';

import '../../core/constants/app_icons.dart';
import '../../core/utils/formatters.dart';
import '../../models/app_notification_model.dart';
import '../common/app_icon.dart';
import '../common/glass_card.dart';
import '../common/status_pill.dart';

/// Notification list tile.
class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification, this.onTap, this.onDismiss});

  final AppNotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = notification.read
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.primary;

    return GlassCard(
      padding: const EdgeInsets.all(14),
      color: notification.read ? null : theme.colorScheme.primary.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accent.withValues(alpha: 0.22), accent.withValues(alpha: 0.06)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppIcon(
                notification.icon.isEmpty ? notification.type.icon : notification.icon,
                size: 20,
                color: accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: notification.read ? FontWeight.w600 : FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        Formatters.timeAgo(notification.timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      StatusPill(label: notification.type.label, color: accent),
                      if (onDismiss != null) ...[
                        const Spacer(),
                        IconButton(
                          tooltip: 'Dismiss',
                          visualDensity: VisualDensity.compact,
                          onPressed: onDismiss,
                          icon: AppIcon(
                            AppIcons.cross,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (!notification.read)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF4359E0), Color(0xFF8A5BF5)]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
