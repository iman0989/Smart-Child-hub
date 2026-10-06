import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_icons.dart';
import '../../core/services/dashboard_loader.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/child_model.dart';
import '../../models/mood_record_model.dart';
import '../../models/report_model.dart';
import '../../models/sleep_record_model.dart';
import '../../models/task_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';
import '../../providers/homework_provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/sleep_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/water_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/cards/child_card.dart';
import '../../widgets/cards/summary_tile.dart';
import '../../widgets/charts/weekly_bar_chart.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/child_avatar.dart';
import '../../widgets/common/circular_progress_widget.dart';
import '../../widgets/common/error_state_widget.dart' show showAppError, showAppSnackBar;
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/linear_progress_widget.dart';
import '../../widgets/common/motion.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/status_pill.dart';

/// Parent home screen: family overview, daily breakdown, timeline, health
/// summary and quick actions — all rendered on the animated world.
class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => loadDashboardData(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            Responsive.screenPadding(context),
            AppConstants.spaceXl,
            Responsive.screenPadding(context),
            AppConstants.spaceSection,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppConstants.dashboardMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _DashboardHeader(),
                    const SizedBox(height: AppConstants.spaceSm),
                    const _ChildOverview(),
                    const SizedBox(height: AppConstants.spaceXxl),
                    const SectionHeader(
                      title: 'Daily activity statistics',
                      subtitle: 'How the day is going',
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    const _StatGrid(),
                    const SizedBox(height: AppConstants.spaceXxl),
                    const SectionHeader(
                      title: 'Today’s progress',
                      subtitle: 'Overall completion and the week so far',
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    const _ProgressSection(),
                    const SizedBox(height: AppConstants.spaceXxl),
                    const SectionHeader(
                      title: 'Today’s activities',
                      subtitle: 'Scheduled routine for your child',
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    const _TimelineSection(),
                    const SizedBox(height: AppConstants.spaceXxl),
                    const SectionHeader(
                      title: 'Health & wellbeing',
                      subtitle: 'Sleep, hydration, meals and mood',
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    const _WellbeingGrid(),
                    const SizedBox(height: AppConstants.spaceXxl),
                    const _ChildrenSection(),
                    const SizedBox(height: AppConstants.spaceXxl),
                    const SectionHeader(title: 'Quick actions'),
                    const SizedBox(height: AppConstants.spaceMd),
                    const _QuickActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Greeting, date and profile chip for the dashboard header.
class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppPalette palette = context.sch;
    final AuthProvider auth = context.watch<AuthProvider>();
    final ChildProvider childrenProvider = context.watch<ChildProvider>();
    final ChildModel? child = childrenProvider.selectedChild;

    final String firstName = auth.user?.fullName.split(' ').first ?? 'there';

    return Staggered(
      spacing: 14,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good ${_greetingFor()}!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontFamily: 'Baloo2',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Track your child’s daily activities',
                    style: theme.textTheme.bodyMedium?.copyWith(color: palette.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 46,
              height: 46,
              child: IconButton(
                tooltip: 'Notifications',
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
                icon: const AppIcon(AppIcons.bell, size: 22),
              ),
            ),
            const SizedBox(width: 4),
            ChildAvatar(
              name: child?.name ?? '?',
              avatarKey: child?.avatarKey ?? 'sunshine',
              size: 46,
              photoUrl: child?.photoUrl ?? '',
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
            ),
          ],
        ),
        Entrance(
          delay: const Duration(milliseconds: 120),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: palette.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: palette.white),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppIcon(AppIcons.calendar, size: 15, color: Color(0xFF4359E0)),
                    const SizedBox(width: 6),
                    Text(
                      Formatters.fullDate(DateTime.now()),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: palette.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '· $firstName’s family',
                      style: theme.textTheme.labelSmall?.copyWith(color: palette.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _greetingFor() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

/// Child overview glass hero with avatar info and a daily progress ring.
class _ChildOverview extends StatelessWidget {
  const _ChildOverview();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppPalette palette = context.sch;
    final ChildProvider childrenProvider = context.watch<ChildProvider>();
    final TaskProvider taskProvider = context.watch<TaskProvider>();

    final ChildModel? child = childrenProvider.selectedChild;
    final String childId = child?.id ?? '';
    final String name = child?.name ?? 'your child';
    final int completed = taskProvider.completedCount(childId);
    final int total = taskProvider.totalCount(childId);
    final double progress = total == 0 ? 0 : (completed / total).clamp(0.0, 1.0);
    final bool onTrack = progress >= 0.5;

    return Entrance(
      child: GlassCard(
        intensive: true,
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool wide = constraints.maxWidth >= 520;
            final Widget info = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today for',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: palette.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ChildAvatar(
                      name: name,
                      avatarKey: child?.avatarKey ?? 'sunshine',
                      size: 54,
                      photoUrl: child?.photoUrl ?? '',
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Baloo2',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${child?.age ?? 0} years · ${child?.grade.trim() ?? 'Pre-school'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: palette.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    StatusPill(
                      label: onTrack ? 'On track' : 'Needs attention',
                      icon: onTrack ? AppIcons.check : AppIcons.clock,
                      color: onTrack ? const Color(0xFF2FAE66) : const Color(0xFFFF9F0A),
                      backgroundColor: (onTrack ? const Color(0xFF2FAE66) : const Color(0xFFFF9F0A))
                          .withValues(alpha: 0.14),
                    ),
                    const SizedBox(width: 8),
                    StatusPill(
                      label: '${child?.coins ?? 0} coins',
                      icon: AppIcons.coin,
                      color: const Color(0xFFE8A500),
                      backgroundColor: const Color(0xFFFFC93C).withValues(alpha: 0.18),
                    ),
                  ],
                ),
                if (!wide) ...[
                  const SizedBox(height: 18),
                  _RingPanel(progress: progress, completed: completed, total: total),
                ],
                const SizedBox(height: 16),
                Text(
                  '$completed of $total daily activities completed',
                  style: theme.textTheme.bodyMedium?.copyWith(color: palette.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                LinearProgressWidget(value: progress, height: 8, color: const Color(0xFF4359E0)),
              ],
            );

            final Widget ring = _RingPanel(progress: progress, completed: completed, total: total);

            return wide
                ? Row(
                    children: [
                      Expanded(flex: 3, child: info),
                      const SizedBox(width: 20),
                      ring,
                    ],
                  )
                : info;
          },
        ),
      ),
    );
  }
}

class _RingPanel extends StatelessWidget {
  const _RingPanel({required this.progress, required this.completed, required this.total});

  final double progress;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final bool allDone = total > 0 && completed >= total;
    final String status = allDone ? 'All done!' : '${(progress * 100).round()}% complete';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressWidget(
            value: progress,
            size: 118,
            strokeWidth: 11,
            color: allDone ? const Color(0xFF2FAE66) : const Color(0xFF4359E0),
            trackColor: const Color(0xFF4359E0).withValues(alpha: 0.14),
            duration: const Duration(milliseconds: 1000),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'completed',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            status,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

/// Grid of daily activity statistic tiles.
class _StatGrid extends StatelessWidget {
  const _StatGrid();

  @override
  Widget build(BuildContext context) {
    final ChildProvider childrenProvider = context.watch<ChildProvider>();
    final String childId = childrenProvider.selectedChild?.id ?? '';
    final DateTime today = DateTime.now();

    final SleepProvider sleep = context.watch<SleepProvider>();
    final MealProvider meal = context.watch<MealProvider>();
    final HomeworkProvider homework = context.watch<HomeworkProvider>();
    final TaskProvider tasks = context.watch<TaskProvider>();

    final int studyDone = homework.completedFor(childId).length;
    final int studyTotal = homework.homeworkFor(childId).length;
    final int playDone = tasks.completedCount(childId);
    final int playTotal = tasks.totalCount(childId);

    final items = <_GlanceTileData>[
      _GlanceTileData(
        icon: AppIcons.book,
        label: 'Study',
        value: '$studyDone of $studyTotal',
        progress: studyTotal == 0 ? 0 : studyDone / studyTotal,
        gradient: const [Color(0xFF4359E0), Color(0xFF7A5BF5)],
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.homework),
      ),
      _GlanceTileData(
        icon: AppIcons.run,
        label: 'Play',
        value: '$playDone of $playTotal tasks',
        gradient: const [Color(0xFF27C48C), Color(0xFF1FBFA0)],
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.activityHub),
      ),
      _GlanceTileData(
        icon: AppIcons.bed,
        label: 'Sleep',
        value: _sleepSummary(sleep, childId, today),
        gradient: const [Color(0xFF8A5BF5), Color(0xFF6C63FF)],
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.sleepTracking),
      ),
      _GlanceTileData(
        icon: AppIcons.food,
        label: 'Meals',
        value: _mealSummary(meal, childId, today),
        gradient: const [Color(0xFFFF8A3D), Color(0xFFFFB37A)],
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.mealTracking),
      ),
      _GlanceTileData(
        icon: AppIcons.lightning,
        label: 'Active days',
        value: '${childrenProvider.selectedChild?.streakDays ?? 0} day streak',
        gradient: const [Color(0xFFFF9F0A), Color(0xFFFFC93C)],
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.reports),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = constraints.maxWidth >= 760 ? 3 : (constraints.maxWidth >= 430 ? 2 : 1);
        final double gap = 12;
        final double tileWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (int i = 0; i < items.length; i++)
              SizedBox(
                width: tileWidth,
                child: _GlanceTile(data: items[i], index: i),
              ),
          ],
        );
      },
    );
  }

  String _sleepSummary(SleepProvider p, String id, DateTime date) {
    final sleep = p.todayFor(id, date);
    if (sleep == null) return 'Not logged yet';
    return '${Formatters.hours(sleep.hours)} · ${sleep.quality.label}';
  }

  String _mealSummary(MealProvider p, String id, DateTime date) {
    final meals = p.mealsFor(id, date: date);
    final eaten = meals.where((m) => m.eaten).length;
    return '$eaten of ${meals.length} meals';
  }
}

class _GlanceTileData {
  const _GlanceTileData({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
    this.progress,
    this.onTap,
  });

  final String icon;
  final String label;
  final String value;
  final List<Color> gradient;
  final double? progress;
  final VoidCallback? onTap;
}

class _GlanceTile extends StatelessWidget {
  const _GlanceTile({required this.data, required this.index});

  final _GlanceTileData data;
  final int index;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final LinearGradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: data.gradient,
    );

    return Entrance(
      delay: Duration(milliseconds: 100 + index * 60),
      child: Pressable(
        onTap: data.onTap,
        child: GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppIcon(data.icon, size: 18, color: Colors.white),
                  ),
                  const Spacer(),
                  AppIcon(AppIcons.chevRight, size: 16, color: theme.colorScheme.outline),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                data.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 2),
              Text(data.label, style: theme.textTheme.bodySmall),
              if (data.progress != null) ...[
                const SizedBox(height: 10),
                LinearProgressWidget(value: data.progress!, height: 5, color: data.gradient.first),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Today's progress: animated ring + weekly bar chart.
class _ProgressSection extends StatelessWidget {
  const _ProgressSection();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppPalette palette = context.sch;
    final ChildProvider childrenProvider = context.watch<ChildProvider>();
    final TaskProvider tasks = context.watch<TaskProvider>();
    final ReportProvider reports = context.watch<ReportProvider>();
    final String childId = childrenProvider.selectedChild?.id ?? '';

    final int completed = tasks.completedCount(childId);
    final int total = tasks.totalCount(childId);
    final double progress = total == 0 ? 0 : (completed / total).clamp(0.0, 1.0);

    final List<ChartDatum> chart =
        reports.statsFor(childId, ReportPeriod.weekly)?.taskChart ?? const [];
    final List<ChartDatum> weekly = chart.isNotEmpty
        ? chart
        : [ChartDatum('Today', completed.toDouble())];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth >= 720;

        final Widget ringCard = GlassCard(
          padding: const EdgeInsets.all(18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressWidget(
                value: progress,
                size: 104,
                strokeWidth: 10,
                color: const Color(0xFF4359E0),
                trackColor: const Color(0xFF4359E0).withValues(alpha: 0.14),
                duration: const Duration(milliseconds: 1100),
                child: Text(
                  '${(progress * 100).round()}%',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily progress',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completed of $total tasks completed today.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: palette.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        final Widget chartCard = GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF8A5BF5), Color(0xFF6C63FF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const AppIcon(AppIcons.chart, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tasks per day',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'This week',
                        style: theme.textTheme.bodySmall?.copyWith(color: palette.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              WeeklyBarChart(data: weekly, height: 140),
            ],
          ),
        );

        if (!wide) {
          return Staggered(spacing: 14, children: [ringCard, chartCard]);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ringCard,
            const SizedBox(width: 14),
            Expanded(child: chartCard),
          ],
        );
      },
    );
  }
}

/// Today's activities as a vertical timeline.
class _TimelineSection extends StatelessWidget {
  const _TimelineSection();

  @override
  Widget build(BuildContext context) {
    final ChildProvider childrenProvider = context.watch<ChildProvider>();
    final TaskProvider tasks = context.watch<TaskProvider>();
    final AppPalette palette = context.sch;
    final ThemeData theme = Theme.of(context);
    final String childId = childrenProvider.selectedChild?.id ?? '';
    final List<TaskModel> schedule = tasks.tasksFor(childId);

    if (schedule.isEmpty) {
      return GlassCard(
        child: Text(
          'No activities scheduled yet — add some to build your child’s day.',
          style: theme.textTheme.bodyMedium?.copyWith(color: palette.onSurfaceVariant),
        ),
      );
    }

    return Staggered(
      spacing: 0,
      step: const Duration(milliseconds: 55),
      children: [
        for (int i = 0; i < schedule.length; i++)
          _TimelineTile(index: i, total: schedule.length, task: schedule[i]),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.index, required this.total, required this.task});

  final int index;
  final int total;
  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    final bool done = task.status == TaskStatus.completed;
    final Color dotColor = done ? const Color(0xFF2FAE66) : const Color(0xFF4359E0);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 46,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    task.time,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: dotColor.withValues(alpha: 0.4), blurRadius: 6)],
                  ),
                ),
                if (index < total - 1)
                  Expanded(child: Container(width: 2, color: dotColor.withValues(alpha: 0.18))),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GlassCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: dotColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AppIcon(task.icon, size: 20, color: dotColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              decoration: done ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            task.category,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusPill(label: task.status.label, color: dotColor),
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

/// Health & wellbeing summary tiles.
class _WellbeingGrid extends StatelessWidget {
  const _WellbeingGrid();

  @override
  Widget build(BuildContext context) {
    final ChildProvider childrenProvider = context.watch<ChildProvider>();
    final SleepProvider sleepProvider = context.watch<SleepProvider>();
    final MealProvider mealProvider = context.watch<MealProvider>();
    final WaterProvider waterProvider = context.watch<WaterProvider>();
    final MoodProvider moodProvider = context.watch<MoodProvider>();
    final HomeworkProvider homeworkProvider = context.watch<HomeworkProvider>();

    final String childId = childrenProvider.selectedChild?.id ?? '';
    final DateTime today = DateTime.now();

    final List<Widget> tiles = [
      _well(
        context,
        icon: AppIcons.bed,
        label: 'Sleep',
        value: _sleepSummary(sleepProvider, childId, today),
        color: const Color(0xFF8A5BF5),
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.sleepTracking),
      ),
      _well(
        context,
        icon: AppIcons.water,
        label: 'Water intake',
        value: _waterSummary(waterProvider, childId, today),
        progress: waterProvider.todayFor(childId, today)?.progress,
        color: const Color(0xFF54C3F6),
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.waterIntake),
      ),
      _well(
        context,
        icon: AppIcons.food,
        label: 'Meals',
        value: _mealSummary(mealProvider, childId, today),
        progress: _mealProgress(mealProvider, childId, today),
        color: const Color(0xFFFF8A3D),
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.mealTracking),
      ),
      _well(
        context,
        icon: AppIcons.sun,
        label: 'Mood',
        value: _moodSummary(moodProvider, childId),
        color: const Color(0xFFFFC93C),
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.moodTracking),
      ),
      _well(
        context,
        icon: AppIcons.homework,
        label: 'Homework',
        value: _homeworkSummary(homeworkProvider, childId),
        progress: homeworkProvider.progressFor(childId),
        color: const Color(0xFF4359E0),
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.homework),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = constraints.maxWidth >= 760 ? 3 : (constraints.maxWidth >= 460 ? 2 : 1);
        final double gap = 12;
        final double w = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (int i = 0; i < tiles.length; i++) SizedBox(width: w, child: tiles[i])],
        );
      },
    );
  }

  Widget _well(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    required Color color,
    double? progress,
    VoidCallback? onTap,
  }) {
    return Entrance(
      child: SummaryTile(
        icon: icon,
        label: label,
        value: value,
        color: color,
        progress: progress,
        onTap: onTap,
      ),
    );
  }

  String _sleepSummary(SleepProvider p, String id, DateTime date) {
    final sleep = p.todayFor(id, date);
    if (sleep == null) return 'Not logged yet';
    return '${Formatters.hours(sleep.hours)} · ${sleep.quality.label}';
  }

  String _mealSummary(MealProvider p, String id, DateTime date) {
    final meals = p.mealsFor(id, date: date);
    final eaten = meals.where((m) => m.eaten).length;
    return '$eaten of ${meals.length} meals';
  }

  double? _mealProgress(MealProvider p, String id, DateTime date) {
    final meals = p.mealsFor(id, date: date);
    if (meals.isEmpty) return null;
    return meals.where((m) => m.eaten).length / meals.length;
  }

  String _waterSummary(WaterProvider p, String id, DateTime date) {
    final water = p.todayFor(id, date);
    if (water == null) return '0 of 8 glasses';
    return '${water.glasses} of ${water.targetGlasses} glasses';
  }

  String _moodSummary(MoodProvider p, String id) {
    final mood = p.latestFor(id);
    return mood == null ? 'Not logged yet' : mood.mood.label;
  }

  String _homeworkSummary(HomeworkProvider p, String id) {
    final completed = p.completedFor(id).length;
    final total = p.homeworkFor(id).length;
    return '$completed of $total done';
  }
}

/// Children quick profiles.
///
/// The dashboard is built around one focused child, so tapping a card here
/// switches which child the whole dashboard is reporting on, and the selected
/// card is outlined.
class _ChildrenSection extends StatelessWidget {
  const _ChildrenSection();

  @override
  Widget build(BuildContext context) {
    final ChildProvider childrenProvider = context.watch<ChildProvider>();
    final TaskProvider taskProvider = context.watch<TaskProvider>();
    final ThemeData theme = Theme.of(context);
    final AppPalette palette = context.sch;
    final String? focusedId = childrenProvider.selectedChildId;

    return Staggered(
      spacing: 12,
      start: const Duration(milliseconds: 200),
      children: [
        Row(
          children: [
            Expanded(child: Text('Children', style: theme.textTheme.titleMedium)),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
              child: const Text('Manage profiles'),
            ),
          ],
        ),
        for (final child in childrenProvider.children)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ChildCard(
              child: child,
              selected: child.id == focusedId,
              subtitle: child.id == focusedId
                  ? 'Showing this child · '
                        '${taskProvider.completedCount(child.id)} tasks · '
                        '${child.coins} coins'
                  : 'Tap to focus · '
                        '${taskProvider.completedCount(child.id)} tasks · '
                        '${child.coins} coins',
              progress: taskProvider.progress(child.id),
              onTap: () => childrenProvider.selectChild(child.id),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: child.id == focusedId
                      ? palette.primaryContainer
                      : palette.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      child.id == focusedId
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked,
                      size: 16,
                      color: child.id == focusedId
                          ? palette.onPrimaryContainer
                          : palette.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      child.id == focusedId ? 'Viewing' : 'Focus',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: child.id == focusedId
                            ? palette.onPrimaryContainer
                            : palette.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (childrenProvider.children.isEmpty)
          Text(
            'No child profiles yet. Add one to start tracking.',
            style: theme.textTheme.bodySmall?.copyWith(color: palette.onSurfaceVariant),
          ),
      ],
    );
  }
}

/// Gradient circular quick actions.
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: AppConstants.spaceMd,
      runSpacing: AppConstants.spaceLg,
      children: [
        _QuickAction(
          label: 'Log sleep',
          icon: AppIcons.bed,
          gradient: const [Color(0xFF8A5BF5), Color(0xFF6C63FF)],
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.sleepTracking),
        ),
        _QuickAction(
          label: 'Add water',
          icon: AppIcons.plus,
          gradient: const [Color(0xFF54C3F6), Color(0xFF22C5E6)],
          onTap: () async {
            final waterProvider = context.read<WaterProvider>();
            final childId = context.read<ChildProvider>().selectedChild?.id ?? '';
            await waterProvider.addGlass(childId, DateTime.now());
            if (!context.mounted) return;
            if (waterProvider.error != null) {
              showAppError(context, waterProvider.error);
            } else {
              showAppSnackBar(context, 'Glass of water added!');
            }
          },
        ),
        _QuickAction(
          label: 'Log mood',
          icon: AppIcons.sun,
          gradient: const [Color(0xFFFFC93C), Color(0xFFFF8A3D)],
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.moodTracking),
        ),
        _QuickAction(
          label: 'Reports',
          icon: AppIcons.chart,
          gradient: const [Color(0xFF2FAE66), Color(0xFF27C48C)],
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.reports),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String label;
  final String icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final LinearGradient g = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradient,
    );
    return Pressable(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: g,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: AppIcon(icon, size: 25, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
