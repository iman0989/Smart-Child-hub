import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';
import '../../core/services/dashboard_loader.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/nav_shell.dart';
import '../activities/activity_hub_screen.dart';
import '../notifications/notifications_screen.dart';
import '../reports/reports_screen.dart';
import 'child_dashboard_screen.dart';
import 'child_profile_screen.dart';
import 'parent_verification_dialog.dart';

/// Child zone shell: Home · Activities · Reports · Alerts · Me.
class ChildShell extends StatefulWidget {
  const ChildShell({super.key});

  @override
  State<ChildShell> createState() => _ChildShellState();
}

class _ChildShellState extends State<ChildShell> {
  bool _booting = true;
  bool _redirecting = false;
  int _tab = 0;

  static const List<NavDest> _dests = [
    NavDest(label: 'Home', icon: 'home', color: Color(0xFF4359E0)),
    NavDest(label: 'Activities', icon: 'run', color: Color(0xFF1FBFA0)),
    NavDest(label: 'Reports', icon: 'chart', color: Color(0xFF8A5BF5)),
    NavDest(label: 'Alerts', icon: 'bell', color: Color(0xFFFF7BA9)),
    NavDest(label: 'Me', icon: 'person', color: Color(0xFFFFC93C)),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // The child zone is only reachable through an explicit profile pick, so a
      // missing selection means we were routed here directly or the session
      // expired — send the user back to the picker instead of guessing.
      if (!context.read<ChildProvider>().hasSelection) {
        _goToChooseProfile();
        return;
      }
      await loadDashboardData(context, loadChildren: false);
      if (mounted) setState(() => _booting = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_booting && !_redirecting) {
      return Scaffold(body: const LoadingWidget(message: 'Loading…'));
    }
    if (_redirecting) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return AppShell(
      destinations: _dests,
      headerNote: 'Kids · fun zone',
      index: _tab,
      onIndexChanged: (int index) => _tab = index,
      builder: (context, index) {
        switch (index) {
          case 0:
            return ChildDashboardScreen(
              onSwitchToParent: _switchToParent,
              onOpenProfile: () => _goToTab(_dests.length - 1),
            );
          case 1:
            return const ActivityHubScreen();
          case 2:
            return const ReportsScreen();
          case 3:
            return const NotificationsScreen();
          default:
            return ChildProfileScreen(onSwitchToParent: _switchToParent);
        }
      },
    );
  }

  void _goToTab(int index) {
    if (index == _tab) return;
    setState(() => _tab = index);
  }

  void _goToChooseProfile() {
    setState(() => _redirecting = true);
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.chooseProfile, (route) => false);
  }

  Future<void> _switchToParent() async {
    // A child session token must not be enough to reach the parent zone, so
    // the parent password is verified before handing control back.
    final bool verified = await ParentVerificationDialog.show(context);
    if (!verified || !mounted) return;

    // Leave the child session so requests use the parent credential again.
    ApiClient.instance.useParentSession();
    context.read<ChildProvider>().clearSelection();
    context.read<AuthProvider>().setMode(AppMode.parent);
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.parentShell, (route) => false);
  }
}
