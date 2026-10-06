import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../models/report_model.dart';
import '../../providers/child_provider.dart';
import '../../providers/homework_provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/sleep_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/water_provider.dart';

/// Loads every dashboard dataset for the currently selected child.
///
/// Used once after sign-in (shell bootstrap) and by pull-to-refresh on the
/// parent dashboard and tracking screens. Never throws — each provider keeps
/// its own error state, so one failing request does not block the others.
Future<void> loadDashboardData(BuildContext context, {bool loadChildren = true}) async {
  final ChildProvider children = context.read<ChildProvider>();
  final TaskProvider tasks = context.read<TaskProvider>();
  final SleepProvider sleep = context.read<SleepProvider>();
  final MealProvider meals = context.read<MealProvider>();
  final WaterProvider water = context.read<WaterProvider>();
  final MoodProvider moods = context.read<MoodProvider>();
  final HomeworkProvider homework = context.read<HomeworkProvider>();
  final NotificationProvider notifications = context.read<NotificationProvider>();
  final ReportProvider reports = context.read<ReportProvider>();

  // Always reload the children list so a freshly signed-in parent starts from
  // their own (possibly empty) family instead of a previous account's cache.
  if (loadChildren) {
    await children.load();
    // The parent dashboard reports on one focused child; focus the first one
    // until the parent picks another.
    children.ensureSelection();
  }
  final String? childId = children.selectedChildId;
  if (childId == null) return;

  try {
    await Future.wait([
      // Day-keyed: refetches when the calendar day rolled over since the last
      // load, so a long-lived session never shows yesterday's ticks.
      tasks.loadFor(childId),
      sleep.loadFor(childId),
      meals.loadFor(childId),
      water.loadFor(childId),
      moods.loadFor(childId),
      homework.loadFor(childId),
      notifications.load(),
    ]);
  } catch (_) {
    // Individual providers already surface their own error message.
  }

  try {
    await reports.load(childId, ReportPeriod.weekly);
  } catch (_) {
    // Charts fall back to today's task data when the report is unavailable.
  }
}
