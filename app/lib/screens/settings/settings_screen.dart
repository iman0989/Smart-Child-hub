import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_icons.dart';
import '../../core/services/session_reset.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/cards/dashboard_card.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/error_state_widget.dart' show showAppSnackBar;
import '../../widgets/common/section_header.dart';
import '../../widgets/common/world_screen.dart';

/// Settings: appearance, notifications, privacy and account.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.sch;
    final SettingsProvider settings = context.watch<SettingsProvider>();

    return WorldScreen(
      title: 'Settings',
      subtitle: 'Preferences & account',
      child: ListView(
        children: [
          SectionHeader(title: 'Appearance'),
          DashboardCard(
            icon: AppIcons.moon,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Dark mode'),
              subtitle: const Text('Reduce glare at night'),
              value: settings.isDarkMode,
              onChanged: (value) {
                settings.setDarkMode(value);
                showAppSnackBar(context, 'Theme updated');
              },
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: 'Notifications'),
          DashboardCard(
            icon: AppIcons.bell,
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable notifications'),
                  value: settings.notificationsEnabled,
                  onChanged: settings.setNotificationsEnabled,
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Activity reminders'),
                  value: settings.activityReminders,
                  onChanged: settings.setActivityReminders,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Meal reminders'),
                  value: settings.mealReminders,
                  onChanged: settings.setMealReminders,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Homework reminders'),
                  value: settings.homeworkReminders,
                  onChanged: settings.setHomeworkReminders,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: 'Privacy'),
          DashboardCard(
            icon: AppIcons.shield,
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Share anonymous analytics'),
                  subtitle: const Text('Help improve the app'),
                  value: settings.shareAnalytics,
                  onChanged: settings.setShareAnalytics,
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Kids can add their own tasks'),
                  value: settings.kidsCanAddTasks,
                  onChanged: settings.setKidsCanAddTasks,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: 'Account'),
          DashboardCard(
            icon: AppIcons.person,
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const AppIcon(AppIcons.person, size: 22),
                  title: const Text('Profile'),
                  subtitle: const Text('Name, phone and family'),
                  trailing: const AppIcon(AppIcons.chevRight, size: 20),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const AppIcon(AppIcons.info, size: 22),
                  title: const Text('About'),
                  subtitle: const Text('App version & credits'),
                  trailing: const AppIcon(AppIcons.chevRight, size: 20),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.about),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.error,
              side: BorderSide(color: palette.error.withValues(alpha: 0.5)),
            ),
            icon: const AppIcon(AppIcons.cross, size: 18),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    resetSessionData(context);
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }
}
