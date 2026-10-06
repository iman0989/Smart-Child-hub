import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../providers/child_provider.dart';
import '../../providers/homework_provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/sleep_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/water_provider.dart';

/// Clears every parent-owned dataset from the in-memory providers.
///
/// Called when signing out or right after a new account signs in so the next
/// session can never see stale children, tasks, coins, reports, notifications
/// or tracking records that belonged to a previous account.
void resetSessionData(BuildContext context) {
  context.read<ChildProvider>().reset();
  context.read<TaskProvider>().reset();
  context.read<SleepProvider>().reset();
  context.read<MealProvider>().reset();
  context.read<WaterProvider>().reset();
  context.read<MoodProvider>().reset();
  context.read<HomeworkProvider>().reset();
  context.read<NotificationProvider>().reset();
  context.read<ReportProvider>().reset();
}
