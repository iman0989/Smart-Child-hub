import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/report_model.dart';
import '../../providers/child_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/cards/dashboard_card.dart';
import '../../widgets/cards/statistics_card.dart';
import '../../widgets/charts/weekly_bar_chart.dart';
import '../../widgets/common/animated_background.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_state_widget.dart' show ErrorStateWidget;
import '../../widgets/common/glass_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/motion.dart';
import '../../widgets/common/responsive_content.dart';
import '../../widgets/common/status_pill.dart';

/// Reports: period selector, headline stats and weekly charts.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportPeriod _period = ReportPeriod.weekly;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureLoaded();
    });
  }

  Future<void> _ensureLoaded() async {
    final ReportProvider reports = context.read<ReportProvider>();
    final String childId = context.read<ChildProvider>().selectedChildId ?? '';
    if (childId.isEmpty) return;
    if (reports.statsFor(childId, _period) != null) return;
    try {
      await reports.load(childId, _period);
    } catch (_) {
      // ReportProvider already surfaced the error via `reports.error`.
    }
    if (mounted) setState(() {});
  }

  Future<void> _refresh() async {
    final String childId = context.read<ChildProvider>().selectedChildId ?? '';
    if (childId.isEmpty) return;
    await context.read<ReportProvider>().refresh(childId, _period);
    if (mounted) setState(() {});
  }

  void _selectPeriod(ReportPeriod period) {
    if (_period == period) return;
    setState(() => _period = period);
    _ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.sch;
    final ChildProvider childrenProvider = context.watch<ChildProvider>();
    final ReportProvider reports = context.watch<ReportProvider>();
    final String childId = childrenProvider.selectedChild?.id ?? '';
    final ReportStatsModel? stats = reports.statsFor(childId, _period);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: AnimatedBackground(opacity: 0.9)),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const GlassAppBar(title: 'Reports', subtitle: 'How the week went'),
                Expanded(
                  child: ResponsiveContent(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          _PeriodSelector(current: _period, onSelected: _selectPeriod),
                          const SizedBox(height: 16),
                          if (stats == null && reports.isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 60),
                              child: LoadingWidget(message: 'Crunching the numbers…'),
                            )
                          else if (stats == null && reports.error != null)
                            ErrorStateWidget(message: reports.error!, onRetry: _ensureLoaded)
                          else if (stats == null)
                            const EmptyStateWidget(
                              title: 'No data yet',
                              message:
                                  'Reports will appear once there is '
                                  'activity to summarize.',
                            )
                          else
                            _buildReportsBody(stats: stats, palette: palette),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsBody({required ReportStatsModel stats, required AppPalette palette}) {
    final ThemeData theme = Theme.of(context);
    return Staggered(
      spacing: 14,
      children: [
        Row(
          children: [
            Expanded(
              child: StatisticCard(
                label: 'Tasks done',
                value: stats.tasksDone,
                icon: AppIcons.tasks,
                color: const Color(0xFF4359E0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatisticCard(
                label: 'Completion',
                value: (stats.completionRate * 100).round(),
                suffix: '%',
                icon: AppIcons.target,
                color: context.sch.success,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: StatisticCard(
                label: 'Coins',
                value: stats.coins,
                icon: AppIcons.coin,
                color: const Color(0xFFE8A500),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatisticCard(
                label: 'Day streak',
                value: stats.dayStreak,
                icon: AppIcons.lightning,
                color: const Color(0xFFFF8A3D),
              ),
            ),
          ],
        ),
        DashboardCard(
          title: 'Tasks per day',
          icon: AppIcons.chart,
          iconColor: context.sch.grape,
          child: stats.taskChart.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'No task data for this period.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: palette.onSurfaceVariant),
                  ),
                )
              : WeeklyBarChart(data: stats.taskChart, height: 170),
        ),
        DashboardCard(
          title: 'Health highlights',
          icon: AppIcons.heart,
          iconColor: const Color(0xFFFF7BA9),
          child: Column(
            children: [
              _HighlightRow(
                icon: AppIcons.bed,
                label: 'Sleep',
                value: stats.sleepHours > 0 ? Formatters.hours(stats.sleepHours) : 'Not logged',
                color: const Color(0xFF8A5BF5),
              ),
              _HighlightRow(
                icon: AppIcons.water,
                label: 'Water',
                value: '${stats.waterGlasses} glasses',
                color: const Color(0xFF54C3F6),
              ),
              _HighlightRow(
                icon: AppIcons.tasks,
                label: 'Category split',
                value: '${stats.categoryChart.length} categories',
                color: const Color(0xFF4359E0),
              ),
            ],
          ),
        ),
        Text(
          'Reports are generated from the family’s daily activity.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: palette.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.current, required this.onSelected});

  final ReportPeriod current;
  final ValueChanged<ReportPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    // Light mode keeps its translucent white chip; dark mode must not paint a
    // near-white chip behind `onSurfaceVariant` label text.
    final Color chipFill = theme.brightness == Brightness.dark
        ? scheme.surfaceContainerHigh
        : Colors.white.withValues(alpha: 0.6);
    return Wrap(
      spacing: 8,
      children: [
        for (final ReportPeriod period in ReportPeriod.values)
          ChoiceChip(
            label: Text(period.label),
            selected: current == period,
            showCheckmark: false,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w700,
              color: current == period ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
            selectedColor: scheme.primary,
            backgroundColor: chipFill,
            side: BorderSide(color: current == period ? scheme.primary : scheme.outlineVariant),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            onSelected: (_) => onSelected(period),
          ),
      ],
    );
  }
}

class _HighlightRow extends StatelessWidget {
  const _HighlightRow({required this.icon, required this.label, required this.value, this.color});

  final String icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = resolveAccent(color ?? const Color(0xFF8A5BF5), theme.brightness);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: AppIcon(icon, size: 18, color: onTintAccent(accent, theme.brightness)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          const SizedBox(width: 8),
          StatusPill(label: value, color: accent),
        ],
      ),
    );
  }
}
