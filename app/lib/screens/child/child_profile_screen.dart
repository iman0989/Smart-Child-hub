import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../models/child_model.dart';
import '../../providers/child_provider.dart';
import '../../widgets/cards/dashboard_card.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/child_avatar.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/status_pill.dart';
import '../../widgets/common/world_screen.dart';

/// Read-only "Me" tab for the child zone.
///
/// This is a child-facing view only: it shows the child's avatar, grade,
/// "About child" note, coins and streak. No profile editing, PIN changes,
/// password or account management options are exposed here — those are
/// parent-only and enforced on the backend for child sessions.
class ChildProfileScreen extends StatelessWidget {
  const ChildProfileScreen({super.key, this.onSwitchToParent});

  /// Asks a parent to unlock the parent zone. Hidden when null.
  final Future<void> Function()? onSwitchToParent;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.sch;
    final ThemeData theme = Theme.of(context);
    final ChildModel? child = context.watch<ChildProvider>().selectedChild;

    final String name = child?.name ?? 'there';
    final String avatarKey = child?.avatarKey ?? 'sunshine';
    final String grade = child?.grade.trim() ?? '';
    final String aboutChild = child?.aboutChild.trim() ?? '';

    return WorldScreen(
      title: 'Me',
      subtitle: 'My profile',
      showBack: false,
      child: ListView(
        children: [
          DashboardCard(
            icon: AppIcons.person,
            child: Row(
              children: [
                ChildAvatar(
                  name: name,
                  avatarKey: avatarKey,
                  size: 56,
                  photoUrl: child?.photoUrl ?? '',
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'My profile',
                        style: theme.textTheme.bodySmall?.copyWith(color: palette.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: 'My rewards', subtitle: 'Coins & streak'),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _RewardCard(
                  icon: AppIcons.coin,
                  value: '${child?.coins ?? 0}',
                  label: 'Coins earned',
                  iconColor: const Color(0xFFE8A500),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RewardCard(
                  icon: AppIcons.lightning,
                  value: '${child?.streakDays ?? 0}',
                  label: 'Day streak',
                  iconColor: const Color(0xFF7A5BF5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionHeader(title: 'About me', subtitle: 'What you and your family told us'),
          const SizedBox(height: 4),
          DashboardCard(
            icon: AppIcons.child,
            child: Column(
              children: [
                _InfoRow(label: 'Grade', value: grade.isEmpty ? 'Pre-school' : grade),
                _InfoRow(label: 'About me', value: aboutChild.isEmpty ? 'Not set yet' : aboutChild),
              ],
            ),
          ),
          const SizedBox(height: 16),
          StatusPill(
            label: 'Your profile and PIN are managed by a parent',
            icon: AppIcons.shield,
            color: palette.primary,
            backgroundColor: palette.primaryContainer,
          ),
          if (onSwitchToParent != null) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => onSwitchToParent!(),
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.onSurface,
                side: BorderSide(color: palette.outlineVariant),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const AppIcon(AppIcons.lock, size: 20),
              label: const Text('Back to Parent Zone'),
            ),
          ],
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  final String icon;
  final String value;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.sch;
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The raw accents sit on `secondaryContainer`, which is peach in light
          // mode and dark brown in dark mode, so each needs shifting to stay
          // legible on the container it is painted on.
          AppIcon(icon, size: 24, color: onTintAccent(iconColor, theme.brightness)),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: palette.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: palette.onSecondaryContainer),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.sch;
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
