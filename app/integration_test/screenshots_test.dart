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
import 'package:smart_child_hub/screens/reports/reports_screen.dart';
import 'package:smart_child_hub/screens/settings/settings_screen.dart';

/// Drives the app through every major screen and captures a screenshot of
/// each. Run with:
///
///   flutter drive --driver=test_driver/integration_test.dart \
///       --target=integration_test/screenshots_test.dart \
///       -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8080
///
/// Screenshots are written to `app/screenshots/` by the driver.

late IntegrationTestWidgetsFlutterBinding _binding;

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

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.pump(const Duration(milliseconds: 400));
  await _binding.takeScreenshot(name);
}

void main() {
  _binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Capture screenshots of every major screen', (WidgetTester tester) async {
    await _binding.convertFlutterSurfaceToImage();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await SessionManager.instance.clear();
    ApiClient.configure(baseUrl: ApiConfig.baseUrl);

    await tester.pumpWidget(const SmartChildHubApp());
    await _waitFor(tester, find.byType(OnboardingScreen));
    await _shot(tester, '01-onboarding');

    await _tapText(tester, 'Skip');
    await _waitFor(tester, find.byType(LoginScreen));
    await _shot(tester, '02-login');

    await _tapText(tester, 'Create account');
    await _waitFor(tester, find.widgetWithText(TextFormField, 'Full name'));
    await _shot(tester, '03-register');

    await _tapText(tester, 'Sign in');
    await _waitFor(tester, find.byType(LoginScreen));
    await _tapText(tester, 'Sign in');
    await _waitFor(tester, find.textContaining(', Dana'));
    await _shot(tester, '04-dashboard');

    await _tapText(tester, 'Activities');
    await _waitFor(tester, find.text('Track your day'));
    await _shot(tester, '05-activities-hub');

    await _tapText(tester, 'Sleep');
    await _waitFor(tester, find.byType(SleepTrackingScreen));
    await _shot(tester, '06-sleep');

    await tester.pageBack();
    await _waitFor(tester, find.text('Track your day'));
    await _tapText(tester, 'Reports');
    await _waitFor(tester, find.byType(ReportsScreen));
    await _shot(tester, '07-reports');

    await _tapText(tester, 'Alerts');
    await _waitFor(tester, find.byType(NotificationsScreen));
    await _shot(tester, '08-alerts');

    await _tapText(tester, 'Settings');
    await _waitFor(tester, find.byType(SettingsScreen));
    await _shot(tester, '09-settings');

    await tester.scrollUntilVisible(find.text('Profile'), 150, maxScrolls: 30);
    await tester.ensureVisible(find.text('Profile'));
    await tester.pump(const Duration(milliseconds: 200));
    await _tapText(tester, 'Profile');
    await _waitFor(tester, find.text('Account & family'));
    await _shot(tester, '10-profile');
  });
}
