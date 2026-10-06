import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_icons.dart';
import '../../core/services/dashboard_loader.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/water_intake_model.dart';
import '../../providers/child_provider.dart';
import '../../providers/water_provider.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/circular_progress_widget.dart';
import '../../widgets/common/error_state_widget.dart' show showAppError, showAppSnackBar;
import '../../widgets/common/world_screen.dart';

/// Ink for content drawn on the light sky-blue water hero.
///
/// The hero gradient stays as designed, but white (and `#D6ECFF`) copy and
/// glyphs only reach ~2:1 on its lightest stop. The palette's deep
/// `onPrimaryContainer` navy clears 4.5:1 on every stop of that gradient.
const Color _kWaterHeroInk = Color(0xFF0E1E5C);

/// Water intake: glass counter, daily target, progress.
class WaterIntakeScreen extends StatelessWidget {
  const WaterIntakeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppPalette palette = context.sch;
    final WaterProvider provider = context.watch<WaterProvider>();
    final String childId = context.watch<ChildProvider>().selectedChildId ?? '';
    final DateTime today = DateTime.now();
    final WaterIntakeModel? log = provider.todayFor(childId, today);
    final int glasses = log?.glasses ?? 0;
    final int target = log?.targetGlasses ?? 8;
    final double progress = log?.progress ?? 0;

    return WorldScreen(
      title: 'Water intake',
      subtitle: 'Daily hydration',
      actions: const [NotificationBellAction()],
      child: RefreshIndicator(
        onRefresh: () => loadDashboardData(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  // The deep end is lifted so the navy ink clears 4.5:1 across
                  // the whole hero; white could not, and the original #2E7BF6
                  // left the caption near 4.1:1.
                  colors: [Color(0xFF54C3F6), Color(0xFF4093FA)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    'Daily goal',
                    style: theme.textTheme.titleMedium?.copyWith(color: _kWaterHeroInk),
                  ),
                  const SizedBox(height: 16),
                  CircularProgressWidget(
                    value: progress,
                    size: 160,
                    strokeWidth: 14,
                    color: _kWaterHeroInk,
                    trackColor: _kWaterHeroInk.withValues(alpha: 0.22),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppIcon(AppIcons.water, size: 26, color: _kWaterHeroInk),
                        const SizedBox(height: 4),
                        Text(
                          '$glasses',
                          style: const TextStyle(
                            color: _kWaterHeroInk,
                            fontFamily: 'Nunito',
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'of $target glasses',
                          style: const TextStyle(
                            color: _kWaterHeroInk,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _GlassButton(
                        icon: AppIcons.minus,
                        onTap: glasses > 0
                            ? () async {
                                await provider.removeGlass(childId, today);
                                if (!context.mounted) return;
                                if (provider.error != null) {
                                  showAppError(context, provider.error);
                                }
                              }
                            : null,
                      ),
                      const SizedBox(width: 16),
                      _GlassButton(
                        icon: AppIcons.plus,
                        onTap: () async {
                          await provider.addGlass(childId, today);
                          if (!context.mounted) return;
                          if (provider.error != null) {
                            showAppError(context, provider.error);
                          } else {
                            showAppSnackBar(context, 'Glass added!');
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    log == null || log.glassTimes.isEmpty
                        ? 'Tap + to log a glass of water'
                        : 'Last glass ${Formatters.timeAgo(log.glassTimes.last)}',
                    style: const TextStyle(color: _kWaterHeroInk, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: glasses > 0
                        ? () async {
                            await provider.resetGlasses(childId, today);
                            if (!context.mounted) return;
                            if (provider.error != null) {
                              showAppError(context, provider.error);
                            }
                          }
                        : null,
                    child: const Text('Reset today'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _GlassTracker(glassTimes: log?.glassTimes ?? const []),
            const SizedBox(height: 16),
            Text(
              progress >= 1
                  ? 'Goal reached! Great hydration, keep it up.'
                  : '${(progress * 100).round()}% of today’s goal',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: progress >= 1 ? context.sch.success : palette.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});

  final String icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: AppIcon(icon, size: 26, color: _kWaterHeroInk),
      ),
    );
  }
}

class _GlassTracker extends StatelessWidget {
  const _GlassTracker({required this.glassTimes});

  final List<DateTime> glassTimes;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Logged glasses', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        if (glassTimes.isEmpty)
          Text(
            'No glasses logged yet today.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          )
        else
          for (int i = glassTimes.length - 1; i >= 0; i--)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  AppIcon(AppIcons.water, size: 18, color: context.sch.info),
                  const SizedBox(width: 10),
                  Text('Glass ${i + 1}', style: theme.textTheme.bodyMedium),
                  const Spacer(),
                  Text(
                    Formatters.timeOfDay(glassTimes[i]),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}
