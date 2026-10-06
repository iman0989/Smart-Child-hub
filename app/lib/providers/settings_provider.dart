import 'package:flutter/material.dart';

/// App settings: theme, language, notification and privacy preferences.
class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  String _languageCode = 'en';

  bool _notificationsEnabled = true;
  bool _activityReminders = true;
  bool _mealReminders = true;
  bool _homeworkReminders = true;

  bool _shareAnalytics = false;
  bool _kidsCanAddTasks = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get languageCode => _languageCode;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get activityReminders => _activityReminders;
  bool get mealReminders => _mealReminders;
  bool get homeworkReminders => _homeworkReminders;
  bool get shareAnalytics => _shareAnalytics;
  bool get kidsCanAddTasks => _kidsCanAddTasks;

  void setDarkMode(bool value) {
    if (_themeMode == (value ? ThemeMode.dark : ThemeMode.light)) return;
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleDarkMode() => setDarkMode(!isDarkMode);

  void setLanguage(String code) {
    if (_languageCode == code) return;
    _languageCode = code;
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void setActivityReminders(bool value) {
    _activityReminders = value;
    notifyListeners();
  }

  void setMealReminders(bool value) {
    _mealReminders = value;
    notifyListeners();
  }

  void setHomeworkReminders(bool value) {
    _homeworkReminders = value;
    notifyListeners();
  }

  void setShareAnalytics(bool value) {
    _shareAnalytics = value;
    notifyListeners();
  }

  void setKidsCanAddTasks(bool value) {
    _kidsCanAddTasks = value;
    notifyListeners();
  }
}
