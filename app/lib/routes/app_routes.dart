/// Central route table. All screen navigation goes through these names.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String chooseProfile = '/choose-profile';

  static const String parentShell = '/parent';
  static const String childShell = '/child';

  static const String activityHub = '/activities';
  static const String sleepTracking = '/activities/sleep';
  static const String mealTracking = '/activities/meals';
  static const String waterIntake = '/activities/water';
  static const String moodTracking = '/activities/mood';
  static const String homework = '/activities/homework';

  static const String reports = '/reports';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String profile = '/profile';
  static const String changePassword = '/change-password';
  static const String childTasks = '/child-tasks';
  static const String childPin = '/child-pin';
}
