import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'core/network/api_config.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/child_provider.dart';
import 'providers/homework_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/mood_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/report_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/sleep_provider.dart';
import 'providers/task_provider.dart';
import 'providers/water_provider.dart';
import 'routes/app_router.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.configure(baseUrl: ApiConfig.baseUrl);
  runApp(const SmartChildHubApp());
}

class SmartChildHubApp extends StatelessWidget {
  const SmartChildHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChildProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => SleepProvider()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => WaterProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => HomeworkProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final SettingsProvider settings = context.watch<SettingsProvider>();
    final AuthProvider auth = context.watch<AuthProvider>();
    final bool dark = settings.isDarkMode;
    final ThemeData theme = auth.isChildMode
        ? (dark ? AppTheme.childDark() : AppTheme.childLight())
        : (dark ? AppTheme.dark() : AppTheme.light());

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: theme,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
