import 'package:flutter/material.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../models/task_model.dart';
import '../common/app_icon.dart';
import '../common/glass_card.dart';
import '../common/status_pill.dart';

/// Task row used in the child dashboard and task screens.
class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task, this.onTap, this.onToggle});

  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;

  Color _statusColor(BuildContext context) {
    final AppPalette palette = context.sch;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    switch (task.status) {
      case TaskStatus.completed:
        return palette.success;
      case TaskStatus.inProgress:
        return palette.warning;
      case TaskStatus.locked:
        return scheme.outline;
      case TaskStatus.pending:
        return scheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppPalette palette = context.sch;
    final bool done = task.status == TaskStatus.completed;
    final Color statusColor = _statusColor(context);

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      color: done ? palette.success.withValues(alpha: 0.18) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            InkWell(
              onTap: onToggle,
              customBorder: const CircleBorder(),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? const Color(0xFF2FAE66) : Colors.transparent,
                  border: done ? null : Border.all(color: statusColor, width: 2),
                ),
                child: done ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      decoration: done ? TextDecoration.lineThrough : null,
                      color: done
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${task.category} · ${task.time}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (task.status == TaskStatus.locked)
              const AppIcon(AppIcons.lock, size: 18)
            else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: palette.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon(AppIcons.coin, size: 14, color: palette.onSecondaryContainer),
                    const SizedBox(width: 3),
                    Text(
                      '+${task.coins}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: palette.onSecondaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(label: task.status.label, color: statusColor),
            ],
          ],
        ),
      ),
    );
  }
}
