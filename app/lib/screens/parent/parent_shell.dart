import 'package:flutter/material.dart';

import '../../core/services/dashboard_loader.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/nav_shell.dart';
import '../activities/activity_hub_screen.dart';
import '../notifications/notifications_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';
import 'parent_dashboard_screen.dart';

/// Parent zone shell: Dashboard · Activities · Reports · Notifications · Settings.
///
/// Uses the responsive [AppShell] — frosted sidebar on desktop, floating glass
/// bottom nav on phones — over the animated world background.
class ParentShell extends StatefulWidget {
  const ParentShell({super.key});

  @override
  State<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends State<ParentShell> {
  bool _booting = true;

  static const List<NavDest> _dests = [
    NavDest(label: 'Dashboard', icon: 'home', color: Color(0xFF4359E0)),
    NavDest(label: 'Activities', icon: 'tasks', color: Color(0xFF1FBFA0)),
    NavDest(label: 'Reports', icon: 'chart', color: Color(0xFF8A5BF5)),
    NavDest(label: 'Alerts', icon: 'bell', color: Color(0xFFFF7BA9)),
    NavDest(label: 'Settings', icon: 'gear', color: Color(0xFFFF8A3D)),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await loadDashboardData(context);
      if (mounted) setState(() => _booting = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_booting) {
      return Scaffold(body: const LoadingWidget(message: 'Loading your family…'));
    }

    return AppShell(
      destinations: _dests,
      headerNote: 'Family dashboard',
      footerLabel: 'Smart Child Daily Activity Tracking System',
      onAccountTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
      builder: (context, index) {
        switch (index) {
          case 0:
            return const ParentDashboardScreen();
          case 1:
            return const ActivityHubScreen();
          case 2:
            return const ReportsScreen();
          case 3:
            return const NotificationsScreen();
          default:
            return const SettingsScreen();
        }
      },
    );
  }
}
