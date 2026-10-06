import 'package:flutter/material.dart';

import '../screens/activities/activity_hub_screen.dart';
import '../screens/activities/homework_screen.dart';
import '../screens/activities/meal_tracking_screen.dart';
import '../screens/activities/mood_tracking_screen.dart';
import '../screens/activities/sleep_tracking_screen.dart';
import '../screens/activities/water_intake_screen.dart';
import '../screens/authentication/forgot_password_screen.dart';
import '../screens/authentication/login_screen.dart';
import '../screens/authentication/register_screen.dart';
import '../screens/child/child_pin_screen.dart';
import '../screens/child/child_shell.dart';
import '../screens/child/child_task_management_screen.dart';
import '../screens/child/choose_profile_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/parent/parent_shell.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/settings/about_screen.dart';
import '../screens/settings/change_password_screen.dart';
import '../screens/settings/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../models/child_model.dart';
import 'app_routes.dart';

/// Builds the widget for a named route.
class AppRouter {
  AppRouter._();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final WidgetBuilder? builder = _routes[settings.name];
    if (builder == null) {
      // Handle argument-based routes
      if (settings.name == AppRoutes.childTasks) {
        final ChildModel? child = settings.arguments is ChildModel
            ? settings.arguments as ChildModel
            : null;
        final String? childId = child?.id ?? settings.arguments as String?;
        if (childId != null) {
          return MaterialPageRoute(
            builder: (_) => ChildTaskManagementScreen(childId: childId, child: child),
            settings: settings,
          );
        }
      }
      if (settings.name == AppRoutes.childPin) {
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => ChildPinScreen(child: args['child']),
            settings: settings,
          );
        }
      }
      return null;
    }
    return MaterialPageRoute(builder: builder, settings: settings);
  }

  static final Map<String, WidgetBuilder> _routes = {
    AppRoutes.splash: (_) => const SplashScreen(),
    AppRoutes.onboarding: (_) => const OnboardingScreen(),
    AppRoutes.login: (_) => const LoginScreen(),
    AppRoutes.register: (_) => const RegisterScreen(),
    AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
    AppRoutes.chooseProfile: (_) => const ChooseProfileScreen(),
    AppRoutes.parentShell: (_) => const ParentShell(),
    AppRoutes.childShell: (_) => const ChildShell(),
    AppRoutes.activityHub: (_) => const ActivityHubScreen(),
    AppRoutes.sleepTracking: (_) => const SleepTrackingScreen(),
    AppRoutes.mealTracking: (_) => const MealTrackingScreen(),
    AppRoutes.waterIntake: (_) => const WaterIntakeScreen(),
    AppRoutes.moodTracking: (_) => const MoodTrackingScreen(),
    AppRoutes.homework: (_) => const HomeworkScreen(),
    AppRoutes.reports: (_) => const ReportsScreen(),
    AppRoutes.notifications: (_) => const NotificationsScreen(),
    AppRoutes.settings: (_) => const SettingsScreen(),
    AppRoutes.about: (_) => const AboutScreen(),
    AppRoutes.profile: (_) => const ProfileScreen(),
    AppRoutes.changePassword: (_) => const ChangePasswordScreen(),
  };
}
