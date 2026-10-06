import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_icons.dart';
import '../../core/services/dashboard_loader.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/sleep_record_model.dart';
import '../../providers/child_provider.dart';
import '../../providers/sleep_provider.dart';
import '../../widgets/cards/dashboard_card.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/error_state_widget.dart' show showAppError;
import '../../widgets/common/status_pill.dart';
import '../../widgets/common/world_screen.dart';

/// Sleep tracking: today's record, quality, history.
class SleepTrackingScreen extends StatefulWidget {
  const SleepTrackingScreen({super.key});

  @override
  State<SleepTrackingScreen> createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen> {
  Future<void> _openLogSheet(BuildContext context, SleepProvider provider, String childId) async {
    final result = await showModalBottomSheet<SleepRecord>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _SleepLogSheet(),
    );
    if (result == null) return;
    await provider.upsertToday(result);
    if (context.mounted) {
      if (provider.error != null) {
        showAppError(context, provider.error);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sleep record saved')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final SleepProvider provider = context.watch<SleepProvider>();
    final String childId = context.watch<ChildProvider>().selectedChildId ?? '';
    final SleepRecord? today = provider.todayFor(childId, DateTime.now());

    return WorldScreen(
      title: 'Sleep',
      subtitle: 'Bedtime & rest',
      actions: const [NotificationBellAction()],
      child: RefreshIndicator(
        onRefresh: () => loadDashboardData(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _TodaySleepCard(record: today, onLog: () => _openLogSheet(context, provider, childId)),
            const SizedBox(height: 20),
            DashboardCard(
              title: 'Sleep history',
              subtitle: 'Last 7 nights',
              icon: AppIcons.chart,
              child: Column(
                children: [
                  for (final record in provider.historyFor(childId).take(7))
                    _HistoryRow(record: record),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodaySleepCard extends StatelessWidget {
  const _TodaySleepCard({required this.record, required this.onLog});

  final SleepRecord? record;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SleepRecord? r = record;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // Both stops are deepened from the original violet. White copy only
          // reached 4.29:1 on #8A5BF5 and the softer #DDE5FF labels cleared just
          // 4.5:1, so neither had any headroom left on the lighter half.
          colors: [Color(0xFF6D3FD6), Color(0xFF5B2CC0)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(AppIcons.moon, size: 22, color: Colors.white),
              const SizedBox(width: 10),
              Text('Last night', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
              const Spacer(),
              if (r != null)
                StatusPill(
                  label: r.quality.label,
                  color: const Color(0xFFFFC93C),
                  // Seated on the violet hero, so the pill needs a light label
                  // on a darkened scrim rather than the accent-derived one.
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black.withValues(alpha: 0.22),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _TimeStat(
                label: 'Bedtime',
                value: r == null ? '--' : Formatters.hourMinute(r.bedtimeHour, r.bedtimeMinute),
              ),
              _divider(),
              _TimeStat(
                label: 'Wake-up',
                value: r == null ? '--' : Formatters.hourMinute(r.wakeHour, r.wakeMinute),
              ),
              _divider(),
              _TimeStat(label: 'Total', value: r == null ? '--' : Formatters.hours(r.hours)),
            ],
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onLog,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white38),
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const AppIcon(AppIcons.plus, size: 18, color: Colors.white),
            label: Text(r == null ? 'Log tonight’s sleep' : 'Update sleep'),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 44,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    color: Colors.white24,
  );
}

class _TimeStat extends StatelessWidget {
  const _TimeStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              // The softer #DDE5FF tint had no headroom left on this gradient;
              // white clears 6:1 on every stop.
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.record});

  final SleepRecord record;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color qualityColor = switch (record.quality) {
      SleepQuality.restful || SleepQuality.good => context.sch.success,
      SleepQuality.fair => context.sch.warning,
      SleepQuality.poor => context.sch.error,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: qualityColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: AppIcon(AppIcons.moon, size: 18, color: qualityColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Formatters.shortDate(record.date), style: theme.textTheme.titleSmall),
                Text(
                  '${Formatters.hourMinute(record.bedtimeHour, record.bedtimeMinute)} – '
                  '${Formatters.hourMinute(record.wakeHour, record.wakeMinute)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            Formatters.hours(record.hours),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 10),
          StatusPill(label: record.quality.label, color: qualityColor),
        ],
      ),
    );
  }
}

class _SleepLogSheet extends StatefulWidget {
  const _SleepLogSheet();

  @override
  State<_SleepLogSheet> createState() => _SleepLogSheetState();
}

class _SleepLogSheetState extends State<_SleepLogSheet> {
  TimeOfDay _bedtime = const TimeOfDay(hour: 20, minute: 30);
  TimeOfDay _wake = const TimeOfDay(hour: 6, minute: 30);
  SleepQuality _quality = SleepQuality.good;

  Future<void> _pickTime(TimeOfDay initial, bool isWake) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      if (isWake) {
        _wake = picked;
      } else {
        _bedtime = picked;
      }
    });
  }

  double _computeHours() {
    int bedMinutes = _bedtime.hour * 60 + _bedtime.minute;
    int wakeMinutes = _wake.hour * 60 + _wake.minute;
    int diff = wakeMinutes - bedMinutes;
    if (diff <= 0) diff += 24 * 60;
    return (diff / 60);
  }

  void _save() {
    final SleepRecord record = SleepRecord(
      id: 's-${DateTime.now().millisecondsSinceEpoch}',
      childId: context.read<ChildProvider>().selectedChildId ?? '',
      date: DateTime.now(),
      bedtimeHour: _bedtime.hour,
      bedtimeMinute: _bedtime.minute,
      wakeHour: _wake.hour,
      wakeMinute: _wake.minute,
      hours: double.parse(_computeHours().toStringAsFixed(1)),
      quality: _quality,
    );
    Navigator.of(context).pop(record);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Log sleep', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TimeButton(
                  label: 'Bedtime',
                  value: Formatters.hourMinute(_bedtime.hour, _bedtime.minute),
                  onTap: () => _pickTime(_bedtime, false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeButton(
                  label: 'Wake-up',
                  value: Formatters.hourMinute(_wake.hour, _wake.minute),
                  onTap: () => _pickTime(_wake, true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Sleep quality', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final SleepQuality quality in SleepQuality.values)
                ChoiceChip(
                  label: Text(quality.label),
                  selected: _quality == quality,
                  onSelected: (_) => setState(() => _quality = quality),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Total: ${Formatters.hours(double.parse(_computeHours().toStringAsFixed(1)))}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            child: const Text('Save sleep'),
          ),
        ],
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
