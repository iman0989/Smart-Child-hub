import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_icons.dart';
import '../../core/services/dashboard_loader.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/mood_record_model.dart';
import '../../providers/child_provider.dart';
import '../../providers/mood_provider.dart';
import '../../widgets/cards/dashboard_card.dart';
import '../../widgets/common/error_state_widget.dart' show showAppError, showAppSnackBar;
import '../../widgets/common/world_screen.dart';

/// Mood tracking: pick how the child feels, see weekly history.
class MoodTrackingScreen extends StatelessWidget {
  const MoodTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MoodProvider provider = context.watch<MoodProvider>();
    final String childId = context.watch<ChildProvider>().selectedChildId ?? '';
    final List<MoodRecord> history = provider.moodsFor(childId);

    return WorldScreen(
      title: 'Mood',
      subtitle: 'How do you feel?',
      actions: const [NotificationBellAction()],
      child: RefreshIndicator(
        onRefresh: () => loadDashboardData(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            DashboardCard(
              title: 'Tap to check in',
              icon: AppIcons.sun,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final MoodType mood in MoodType.values)
                    _MoodOption(
                      mood: mood,
                      onTap: () async {
                        await provider.addMood(childId: childId, mood: mood);
                        if (!context.mounted) return;
                        if (provider.error != null) {
                          showAppError(context, provider.error);
                        } else {
                          showAppSnackBar(context, '${mood.label} noted');
                        }
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            DashboardCard(
              title: 'This week',
              subtitle: 'Mood check-ins',
              icon: AppIcons.chart,
              child: history.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No check-ins yet — tap a face above.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        for (final MoodRecord record in history.take(6))
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Icon(
                                  record.mood.icon,
                                  size: 22,
                                  color: onTintAccent(
                                    record.mood.colorOf(context),
                                    theme.brightness,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(record.mood.label, style: theme.textTheme.bodyMedium),
                                ),
                                Text(
                                  Formatters.timeAgo(record.date),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
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

class _MoodOption extends StatelessWidget {
  const _MoodOption({required this.mood, required this.onTap});

  final MoodType mood;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = mood.colorOf(context);
    // The chip keeps [color] as its tint and border hue, but the glyph needs the
    // readable variant of that hue to clear 3:1 on the tint.
    final Color iconColor = onTintAccent(color, Theme.of(context).brightness);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 92,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            Icon(mood.icon, size: 30, color: iconColor),
            const SizedBox(height: 8),
            Text(
              mood.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
