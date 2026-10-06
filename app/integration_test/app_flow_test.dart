import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_child_hub/core/network/api_client.dart';
import 'package:smart_child_hub/core/network/api_config.dart';
import 'package:smart_child_hub/core/network/session_manager.dart';
import 'package:smart_child_hub/main.dart';
import 'package:smart_child_hub/screens/activities/sleep_tracking_screen.dart';
import 'package:smart_child_hub/screens/authentication/login_screen.dart';
import 'package:smart_child_hub/screens/notifications/notifications_screen.dart';
import 'package:smart_child_hub/screens/onboarding/onboarding_screen.dart';
import 'package:smart_child_hub/screens/parent/parent_dashboard_screen.dart';
import 'package:smart_child_hub/screens/parent/parent_shell.dart';
import 'package:smart_child_hub/screens/reports/reports_screen.dart';
import 'package:smart_child_hub/screens/settings/settings_screen.dart';
import 'package:smart_child_hub/widgets/cards/child_card.dart';
import 'package:smart_child_hub/widgets/common/password_field.dart';

/// Phase 6 end-to-end UI flow tests running against the live PHP backend.
///
/// Run on the Android emulator with:
///   flutter test integration_test -d emulator-5554 \
///       --dart-define=API_BASE_URL=http://10.0.2.2:8080

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final DateTime deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  final texts = find
      .byType(Text)
      .evaluate()
      .map((e) => (e.widget as Text).data)
      .whereType<String>()
      .toList();
  // ignore: avoid_print
  print('VISIBLE TEXTS ON TIMEOUT: $texts');
  fail('Timed out waiting for $finder');
}

Future<void> _tapText(WidgetTester tester, String text) async {
  final Finder finder = find.text(text);
  await _waitFor(tester, finder);
  await tester.ensureVisible(finder.first);
  await tester.pump(const Duration(milliseconds: 150));
  await tester.tap(finder.first, warnIfMissed: false);
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _scrollTo(WidgetTester tester, String text) async {
  final Finder finder = find.text(text);
  if (finder.evaluate().isNotEmpty) return;
  await tester.scrollUntilVisible(finder, 150, maxScrolls: 30);
  await tester.ensureVisible(finder.first);
  await tester.pump(const Duration(milliseconds: 200));
}

/// Resets the persisted + in-memory session so each test starts signed out.
Future<void> _resetSession() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  await SessionManager.instance.clear();
  ApiClient.configure(baseUrl: ApiConfig.baseUrl);
}

Future<void> _bootToOnboarding(WidgetTester tester) async {
  await tester.pumpWidget(const SmartChildHubApp());
  // Splash auto-routes to onboarding after its timer (no session).
  await _waitFor(tester, find.byType(OnboardingScreen));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Parent flow: register, dashboard, add child, sign out, log in again',
      (WidgetTester tester) async {
    await _resetSession();

    await _bootToOnboarding(tester);

    // Skip onboarding -> login screen.
    await _tapText(tester, 'Skip');
    await _waitFor(tester, find.byType(LoginScreen));

    // Register a fresh account so the flow is repeatable.
    await _tapText(tester, 'Create account');
    await _waitFor(tester, find.widgetWithText(TextFormField, 'Full name'));

    final String email = 'uitest+${DateTime.now().millisecondsSinceEpoch}@example.com';
    await tester.enterText(find.widgetWithText(TextFormField, 'Full name'), 'QA Flow Tester');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email address'), email);
    await tester.enterText(find.widgetWithText(TextFormField, 'Phone (optional)'), '+1 555 010 999');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'Secret!123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirm password'), 'Secret!123');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(milliseconds: 200));

    // "Create account" is both the title and the submit button; target the button.
    await _waitFor(tester, find.widgetWithText(ElevatedButton, 'Create account'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create account'));
    await tester.pump(const Duration(milliseconds: 300));
    await _waitFor(tester, find.textContaining('Good morning, QA'));
    expect(find.byType(ParentShell), findsOneWidget);
    expect(find.byType(ParentDashboardScreen), findsOneWidget);

    // Bottom nav renders all five destinations.
    for (final String label in ['Home', 'Activities', 'Reports', 'Alerts', 'Settings']) {
      expect(find.text(label), findsWidgets);
    }

    // Settings -> Profile -> Add child.
    await _tapText(tester, 'Settings');
    await _waitFor(tester, find.text('Preferences & account'));
    await _scrollTo(tester, 'Profile');
    await _tapText(tester, 'Profile');
    await _waitFor(tester, find.text('Account & family'));
    await _scrollTo(tester, 'Add');
    await _tapText(tester, 'Add');

    await _waitFor(tester, find.widgetWithText(TextFormField, 'Child name'));
    await tester.enterText(find.widgetWithText(TextFormField, 'Child name'), 'Mia');
    await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '7');
    await tester.pump(const Duration(milliseconds: 200));
    await _tapText(tester, 'Add child');

    // Child appears in the family list.
    await _scrollTo(tester, 'Mia');
    expect(find.byType(ChildCard), findsWidgets);

    // Sign out -> back on login.
    await _scrollTo(tester, 'Sign out');
    await _tapText(tester, 'Sign out');
    await _waitFor(tester, find.byType(LoginScreen));

    // Log in with the freshly registered account.
    await tester.enterText(find.widgetWithText(TextFormField, 'Email address'), email);
    await tester.enterText(find.byType(PasswordField).first, 'Secret!123');
    await _tapText(tester, 'Sign in');
    await _waitFor(tester, find.textContaining('Good morning, QA'));
  });

  testWidgets('Seeded parent: dashboard data, tracker screens, reports, alerts, settings',
      (WidgetTester tester) async {
    await _resetSession();

    await _bootToOnboarding(tester);
    await _tapText(tester, 'Skip');
    await _waitFor(tester, find.byType(LoginScreen));

    // Login is pre-filled with the seeded demo account.
    await _tapText(tester, 'Sign in');
    await _waitFor(tester, find.textContaining('Good morning, Dana'));

    // Dashboard renders child cards (seeded family); they sit below the fold.
    await tester.dragUntilVisible(
      find.byType(ChildCard),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.byType(ChildCard), findsWidgets);
    expect(find.text('Family Dashboard'), findsOneWidget);

    // Activities hub -> open a tracker (sleep).
    await _tapText(tester, 'Activities');
    await _waitFor(tester, find.text('Track your day'));
    await _tapText(tester, 'Sleep');
    await _waitFor(tester, find.byType(SleepTrackingScreen));

    // Back to the shell via the hub, then Reports.
    await tester.pageBack();
    await _waitFor(tester, find.text('Track your day'));
    await _tapText(tester, 'Reports');
    await _waitFor(tester, find.byType(ReportsScreen));

    // Alerts (notifications).
    await _tapText(tester, 'Alerts');
    await _waitFor(tester, find.byType(NotificationsScreen));

    // Settings toggles and screen render.
    await _tapText(tester, 'Settings');
    await _waitFor(tester, find.byType(SettingsScreen));
    await _waitFor(tester, find.text('Dark mode'));
    await tester.tap(find.text('Dark mode'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 600));

    // Back Home and scroll back to the top (pull-to-refresh smoke gesture).
    await _tapText(tester, 'Home');
    await _waitFor(tester, find.text('Family Dashboard'));
    await tester.drag(find.byType(ListView).last, const Offset(0, 800));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Family Dashboard'), findsOneWidget);
  });
}
