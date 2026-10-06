import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_icons.dart';
import '../../core/services/dashboard_loader.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/mood_record_model.dart';
import '../../models/report_model.dart';
import '../../models/task_model.dart';
import '../../providers/child_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/task_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/cards/dashboard_card.dart';
import '../../widgets/cards/task_tile.dart';
import '../../widgets/charts/weekly_bar_chart.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/circular_progress_widget.dart';
import '../../widgets/common/child_avatar.dart';
import '../../widgets/common/error_state_widget.dart' show showAppError, showAppSnackBar;
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/motion.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/status_pill.dart';

/// Child home: greeting, daily progress, tasks, weekly stats, mood + badges.
class ChildDashboardScreen extends StatelessWidget {
  const ChildDashboardScreen({super.key, this.onSwitchToParent, this.onOpenProfile});

  final VoidCallback? onSwitchToParent;

  /// Opens the child's own "Me" profile tab.
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppPalette palette = context.sch;
    final ChildProvider childrenProvider = context.watch<ChildProvider>();
    final TaskProvider taskProvider = context.watch<TaskProvider>();
    final MoodProvider moodProvider = context.watch<MoodProvider>();
    final ReportProvider reportProvider = context.watch<ReportProvider>();

    final child = childrenProvider.selectedChild;
    // ChildShell guarantees a selection before this screen is built, so an
    // empty id here means the session was lost — render empty states rather
    // than another child's data.
    final String childId = child?.id ?? '';
    final String name = child?.name ?? 'there';
    final int completed = taskProvider.completedCount(childId);
    final int total = taskProvider.totalCount(childId);
    final double progress = taskProvider.progress(childId);

    final List<ChartDatum> weeklyChart =
        reportProvider.statsFor(childId, ReportPeriod.weekly)?.taskChart ?? const [];
    final int coins = child?.coins ?? 0;
    final int streak = child?.streakDays ?? 0;
    final List<_Badge> badges = _badgesFor(
      completed: completed,
      total: total,
      coins: coins,
      streak: streak,
    );

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => loadDashboardData(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greeting(),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontFamily: 'Baloo2',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${Formatters.weekdayFull(DateTime.now())}, ${Formatters.shortDate(DateTime.now())}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: palette.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (onSwitchToParent != null)
                          IconButton(
                            tooltip: 'Parent zone',
                            onPressed: onSwitchToParent,
                            icon: const AppIcon(AppIcons.lock, size: 22),
                          ),
                        const SizedBox(width: 4),
                        _CoinPill(coins: coins),
                        const SizedBox(width: 10),
                        ChildAvatar(
                          name: name,
                          avatarKey: child?.avatarKey ?? 'sunshine',
                          size: 46,
                          onTap: onOpenProfile,
                          photoUrl: child?.photoUrl ?? '',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _HeroCard(
                      name: name,
                      completed: completed,
                      total: total,
                      progress: progress,
                      streak: streak,
                    ),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'My Tasks',
                      subtitle: 'Today’s schedule',
                      trailing: TextButton(
                        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.activityHub),
                        child: const Text('See all'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Staggered(
                      spacing: 10,
                      step: const Duration(milliseconds: 55),
                      children: [
                        for (final task in taskProvider.tasksFor(childId))
                          TaskTile(
                            task: task,
                            onToggle: () async {
                              final bool wasDone = task.status == TaskStatus.completed;
                              final int taskCoins = task.coins;
                              final TaskModel? toggled = await taskProvider.toggle(task.id);
                              if (!context.mounted) return;
                              if (taskProvider.error != null) {
                                showAppError(context, taskProvider.error);
                              } else if (!wasDone && toggled?.status == TaskStatus.completed) {
                                childrenProvider.bumpCoinsLocal(childId, taskCoins);
                                if (context.mounted) {
                                  showAppSnackBar(context, '+$taskCoins coins earned!');
                                }
                              }
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const SectionHeader(title: 'This Week'),
                    const SizedBox(height: 8),
                    _WeekSection(progress: progress, chartData: weeklyChart),
                    const SizedBox(height: 20),
                    _MoodSelector(
                      onSelect: (MoodType mood) async {
                        await moodProvider.addMood(childId: childId, mood: mood);
                        if (!context.mounted) return;
                        if (moodProvider.error != null) {
                          showAppError(context, moodProvider.error);
                        } else {
                          showAppSnackBar(context, 'Mood saved: ${mood.label}');
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'Badges',
                      subtitle: '$completed of $total unlocked',
                      trailing: TextButton(
                        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.reports),
                        child: const Text('See all'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _BadgeStrip(badges: badges),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_Badge> _badgesFor({
    required int completed,
    required int total,
    required int coins,
    required int streak,
  }) {
    return [
      _Badge(AppIcons.lightning, 'Streak', streak >= 3),
      _Badge(AppIcons.coin, 'Coins', coins >= 50),
      _Badge(AppIcons.tasks, 'Tasks', completed >= 5),
      _Badge(AppIcons.check, 'All done', total > 0 && completed >= total),
    ];
  }

  String _greeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }
}

class _Badge {
  const _Badge(this.icon, this.title, this.unlocked);

  final String icon;
  final String title;
  final bool unlocked;
}

class _CoinPill extends StatelessWidget {
  const _CoinPill({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.sch;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.sunshine, palette.warning],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: palette.warning.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppIcon(AppIcons.coin, size: 17),
          const SizedBox(width: 6),
          Text(
            '$coins',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: palette.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.name,
    required this.completed,
    required this.total,
    required this.progress,
    required this.streak,
  });

  final String name;
  final int completed;
  final int total;
  final double progress;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppPalette palette = context.sch;

    return Entrance(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4359E0), Color(0xFF7A5BF5)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4359E0).withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
            ),
            Positioned(
              left: -24,
              bottom: -50,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final bool wide = constraints.maxWidth >= 460;
                final Widget info = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Great job, $name!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontFamily: 'Baloo2',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'You finished $completed of $total tasks',
                      style: const TextStyle(
                        color: Color(0xFFDDE5FF),
                        fontFamily: 'Nunito',
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        StatusPill(
                          label: '$streak day streak',
                          icon: AppIcons.lightning,
                          color: palette.sunshine,
                          // The 40%-dark tint resolves to muddy brown in dark
                          // mode, which no amber tint can stay legible on.
                          foregroundColor: Colors.white,
                          backgroundColor: palette.onSecondaryContainer.withValues(alpha: 0.40),
                        ),
                        const SizedBox(width: 8),
                        StatusPill(
                          label: '$completed done',
                          icon: AppIcons.check,
                          color: const Color(0xFFFFFFFF),
                          backgroundColor: Colors.white.withValues(alpha: 0.16),
                        ),
                      ],
                    ),
                  ],
                );

                final Widget ring = CircularProgressWidget(
                  value: progress,
                  size: wide ? 118 : 96,
                  strokeWidth: 11,
                  color: palette.sunshine,
                  trackColor: Colors.white.withValues(alpha: 0.25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                          fontSize: wide ? 22 : 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Text(
                        'today',
                        style: TextStyle(
                          color: Color(0xFFDDE5FF),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );

                return wide
                    ? Row(
                        children: [
                          Expanded(flex: 3, child: info),
                          const SizedBox(width: 16),
                          ring,
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          info,
                          const SizedBox(height: 18),
                          Center(child: ring),
                        ],
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekSection extends StatelessWidget {
  const _WeekSection({required this.progress, required this.chartData});

  final double progress;
  final List<ChartDatum> chartData;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth >= 600;
        final Widget chart = DashboardCard(
          title: 'Tasks per day',
          child: chartData.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'No data yet this week.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : WeeklyBarChart(data: chartData, height: 130),
        );
        final Widget goal = Entrance(
          delay: const Duration(milliseconds: 150),
          child: DashboardCard(
            title: 'Goal this week',
            icon: AppIcons.target,
            iconColor: const Color(0xFF1FBFA0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '100',
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 30, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  '${(progress * 100).round()}% collected',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: chart),
              const SizedBox(width: 16),
              SizedBox(width: 200, child: goal),
            ],
          );
        }
        return Column(children: [chart, const SizedBox(height: 12), goal]);
      },
    );
  }
}

class _MoodSelector extends StatelessWidget {
  const _MoodSelector({required this.onSelect});

  final ValueChanged<MoodType> onSelect;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DashboardCard(
      title: 'How do you feel?',
      icon: AppIcons.sun,
      iconColor: const Color(0xFFFFC93C),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final MoodType mood in MoodType.values)
            InkWell(
              onTap: () => onSelect(mood),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Entrance(
                  delay: Duration(milliseconds: 60 * mood.index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: mood.colorOf(context).withValues(alpha: 0.16),
                          border: Border.all(color: mood.colorOf(context).withValues(alpha: 0.25)),
                        ),
                        child: Icon(
                          mood.icon,
                          color: onTintAccent(mood.colorOf(context), theme.brightness),
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mood.label,
                        style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BadgeStrip extends StatelessWidget {
  const _BadgeStrip({required this.badges});

  final List<_Badge> badges;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: badges.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final achievement = badges[index];
          return Entrance(
            delay: Duration(milliseconds: 80 * index),
            child: _BadgeCard(
              icon: achievement.icon,
              title: achievement.title,
              unlocked: achievement.unlocked,
            ),
          );
        },
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.icon, required this.title, required this.unlocked});

  final String icon;
  final String title;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: 96,
        height: 108,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: unlocked ? 1 : 0.35,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: unlocked
                      ? const Color(0xFFFFC93C).withValues(alpha: 0.18)
                      : theme.colorScheme.surfaceContainerHigh,
                ),
                child: AppIcon(
                  icon,
                  size: 30,
                  color: unlocked
                      ? onTintAccent(const Color(0xFFE8A500), theme.brightness)
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: unlocked ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
