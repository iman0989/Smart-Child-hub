import '../core/utils/formatters.dart';
import '../models/achievement_model.dart';
import '../models/app_notification_model.dart';
import '../models/child_model.dart';
import '../models/homework_model.dart';
import '../models/meal_model.dart';
import '../models/mood_record_model.dart';
import '../models/sleep_record_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../models/water_intake_model.dart';

/// Seeds the app with realistic offline data. In Phase 4 these factories are
/// replaced by API responses; the model layer is already JSON-ready.
class DummyData {
  DummyData._();

  static UserModel parentUser() => const UserModel(
    id: 'u-1',
    fullName: 'Dana Smith',
    email: 'dana@example.com',
    phone: '+1 555 010 2030',
    avatarKey: 'grape',
  );

  static List<ChildModel> children() => const [
    ChildModel(
      id: 'c-1',
      name: 'Mia',
      age: 7,
      grade: 'Grade 2',
      aboutChild: 'Loves drawing and story time',
      avatarKey: 'sunshine',
      pin: '',
      coins: 240,
      streakDays: 5,
    ),
    ChildModel(
      id: 'c-2',
      name: 'Leo',
      age: 5,
      grade: 'Grade 1',
      aboutChild: 'Loves building with blocks',
      avatarKey: 'sky',
      pin: '',
      coins: 180,
      streakDays: 3,
    ),
    ChildModel(
      id: 'c-3',
      name: 'Ava',
      age: 9,
      grade: 'Grade 4',
      aboutChild: 'Loves soccer and playing piano',
      avatarKey: 'mint',
      pin: '',
      coins: 95,
      streakDays: 1,
    ),
  ];

  /// Today's schedule for the child dashboard.
  static List<TaskModel> tasks(String childId) {
    final String today = Formatters.apiDate(DateTime.now());
    return [
      TaskModel(
        id: 't-1',
        childId: childId,
        title: 'Brush teeth',
        icon: 'sparkle',
        category: 'Morning routine',
        time: '7:00 AM',
        coins: 5,
        status: TaskStatus.completed,
        date: today,
      ),
      TaskModel(
        id: 't-2',
        childId: childId,
        title: 'Make the bed',
        icon: 'bed',
        category: 'Morning routine',
        time: '7:20 AM',
        coins: 5,
        status: TaskStatus.completed,
        date: today,
      ),
      TaskModel(
        id: 't-3',
        childId: childId,
        title: 'Breakfast',
        icon: 'food',
        category: 'Morning routine',
        time: '7:45 AM',
        coins: 5,
        status: TaskStatus.completed,
        date: today,
      ),
      TaskModel(
        id: 't-4',
        childId: childId,
        title: 'Reading time',
        icon: 'book',
        category: 'Learning & fun',
        time: '4:00 PM',
        coins: 10,
        status: TaskStatus.pending,
        date: today,
      ),
      TaskModel(
        id: 't-5',
        childId: childId,
        title: 'Outdoor play',
        icon: 'run',
        category: 'Learning & fun',
        time: '5:00 PM',
        coins: 10,
        status: TaskStatus.pending,
        date: today,
      ),
      TaskModel(
        id: 't-6',
        childId: childId,
        title: 'Homework',
        icon: 'homework',
        category: 'Learning & fun',
        time: '6:00 PM',
        coins: 15,
        status: TaskStatus.pending,
        date: today,
      ),
      TaskModel(
        id: 't-7',
        childId: childId,
        title: 'Evening shower',
        icon: 'water',
        category: 'Evening routine',
        time: '8:00 PM',
        coins: 5,
        status: TaskStatus.locked,
        date: today,
      ),
    ];
  }

  static List<SleepRecord> sleep(String childId) {
    DateTime day(int ago) => DateTime.now().subtract(Duration(days: ago));
    return [
      SleepRecord(
        id: 's1',
        childId: childId,
        date: day(0),
        bedtimeHour: 20,
        bedtimeMinute: 30,
        wakeHour: 6,
        wakeMinute: 30,
        hours: 9.5,
        quality: SleepQuality.restful,
      ),
      SleepRecord(
        id: 's2',
        childId: childId,
        date: day(1),
        bedtimeHour: 21,
        bedtimeMinute: 0,
        wakeHour: 6,
        wakeMinute: 45,
        hours: 9.0,
        quality: SleepQuality.good,
      ),
      SleepRecord(
        id: 's3',
        childId: childId,
        date: day(2),
        bedtimeHour: 20,
        bedtimeMinute: 45,
        wakeHour: 6,
        wakeMinute: 15,
        hours: 9.0,
        quality: SleepQuality.good,
      ),
      SleepRecord(
        id: 's4',
        childId: childId,
        date: day(3),
        bedtimeHour: 21,
        bedtimeMinute: 30,
        wakeHour: 6,
        wakeMinute: 30,
        hours: 8.5,
        quality: SleepQuality.fair,
      ),
      SleepRecord(
        id: 's5',
        childId: childId,
        date: day(4),
        bedtimeHour: 20,
        bedtimeMinute: 15,
        wakeHour: 6,
        wakeMinute: 0,
        hours: 9.0,
        quality: SleepQuality.good,
      ),
      SleepRecord(
        id: 's6',
        childId: childId,
        date: day(5),
        bedtimeHour: 20,
        bedtimeMinute: 45,
        wakeHour: 7,
        wakeMinute: 0,
        hours: 9.5,
        quality: SleepQuality.restful,
      ),
      SleepRecord(
        id: 's7',
        childId: childId,
        date: day(6),
        bedtimeHour: 21,
        bedtimeMinute: 15,
        wakeHour: 6,
        wakeMinute: 30,
        hours: 8.5,
        quality: SleepQuality.fair,
      ),
    ];
  }

  static List<MealModel> meals(String childId) {
    final DateTime today = DateTime.now();
    return [
      MealModel(
        id: 'm1',
        childId: childId,
        date: today,
        type: MealType.breakfast,
        name: 'Oatmeal with berries',
        icon: 'sun',
        time: '7:45 AM',
        calories: 260,
        protein: 9,
        carbs: 42,
        fat: 4,
        eaten: true,
      ),
      MealModel(
        id: 'm2',
        childId: childId,
        date: today,
        type: MealType.snack,
        name: 'Apple slices',
        icon: 'heart',
        time: '10:30 AM',
        calories: 80,
        protein: 0,
        carbs: 20,
        fat: 0,
        eaten: true,
      ),
      MealModel(
        id: 'm3',
        childId: childId,
        date: today,
        type: MealType.lunch,
        name: 'Chicken sandwich & salad',
        icon: 'food',
        time: '12:30 PM',
        calories: 410,
        protein: 28,
        carbs: 34,
        fat: 14,
        eaten: true,
      ),
      MealModel(
        id: 'm4',
        childId: childId,
        date: today,
        type: MealType.dinner,
        name: 'Spaghetti with meatballs',
        icon: 'moon',
        time: '6:30 PM',
        calories: 520,
        protein: 24,
        carbs: 62,
        fat: 16,
        eaten: false,
      ),
    ];
  }

  static List<WaterIntakeModel> water(String childId) {
    final DateTime today = DateTime.now();
    return [
      WaterIntakeModel(
        id: 'w1',
        childId: childId,
        date: today,
        glasses: 6,
        targetGlasses: 8,
        glassTimes: [
          DateTime(today.year, today.month, today.day, 7, 50),
          DateTime(today.year, today.month, today.day, 9, 15),
          DateTime(today.year, today.month, today.day, 10, 40),
          DateTime(today.year, today.month, today.day, 12, 30),
          DateTime(today.year, today.month, today.day, 15, 0),
          DateTime(today.year, today.month, today.day, 17, 20),
        ],
      ),
    ];
  }

  static List<MoodRecord> moods(String childId) {
    final DateTime now = DateTime.now();
    return [
      MoodRecord(
        id: 'mo1',
        childId: childId,
        date: DateTime(now.year, now.month, now.day, 13, 0),
        mood: MoodType.happy,
        note: 'Loved the drawing class today!',
      ),
      MoodRecord(
        id: 'mo2',
        childId: childId,
        date: DateTime(now.year, now.month, now.day - 1, 13, 0),
        mood: MoodType.calm,
        note: 'Quiet afternoon with books.',
      ),
      MoodRecord(
        id: 'mo3',
        childId: childId,
        date: DateTime(now.year, now.month, now.day - 2, 13, 0),
        mood: MoodType.excited,
        note: 'Play date with Ava!',
      ),
      MoodRecord(
        id: 'mo4',
        childId: childId,
        date: DateTime(now.year, now.month, now.day - 3, 13, 0),
        mood: MoodType.tired,
        note: 'Long day at school.',
      ),
      MoodRecord(
        id: 'mo5',
        childId: childId,
        date: DateTime(now.year, now.month, now.day - 4, 13, 0),
        mood: MoodType.sad,
        note: 'Lost my favourite sticker.',
      ),
    ];
  }

  static List<HomeworkModel> homework(String childId) {
    final DateTime today = DateTime.now();
    return [
      HomeworkModel(
        id: 'h1',
        childId: childId,
        title: 'Math worksheet - page 12',
        subject: 'Math',
        icon: 'book',
        dueDate: today,
        status: HomeworkStatus.completed,
        coins: 10,
        progress: 1,
      ),
      HomeworkModel(
        id: 'h2',
        childId: childId,
        title: 'Read 20 minutes',
        subject: 'English',
        icon: 'book',
        dueDate: today,
        status: HomeworkStatus.completed,
        coins: 10,
        progress: 1,
      ),
      HomeworkModel(
        id: 'h3',
        childId: childId,
        title: 'Spelling practice',
        subject: 'English',
        icon: 'edit',
        dueDate: today,
        status: HomeworkStatus.completed,
        coins: 5,
        progress: 1,
      ),
      HomeworkModel(
        id: 'h4',
        childId: childId,
        title: 'Draw your family',
        subject: 'Art',
        icon: 'paint',
        dueDate: today.add(const Duration(days: 1)),
        status: HomeworkStatus.inProgress,
        coins: 5,
        progress: 0.5,
      ),
      HomeworkModel(
        id: 'h5',
        childId: childId,
        title: 'Science: collect leaves',
        subject: 'Science',
        icon: 'plants',
        dueDate: today.add(const Duration(days: 2)),
        status: HomeworkStatus.pending,
        coins: 10,
        progress: 0,
      ),
    ];
  }

  static List<AppNotificationModel> notifications() {
    final DateTime now = DateTime.now();
    DateTime ago(int minutes) => now.subtract(Duration(minutes: minutes));
    return [
      AppNotificationModel(
        id: 'n1',
        type: NotificationType.homework,
        title: 'Homework reminder',
        message: 'Mia has 2 homework tasks due today. Help her finish them!',
        timestamp: ago(30),
        icon: 'homework',
      ),
      AppNotificationModel(
        id: 'n2',
        type: NotificationType.meal,
        title: 'Dinner time',
        message: 'It is dinner time. Mia still needs to eat her spaghetti.',
        timestamp: ago(75),
        icon: 'food',
      ),
      AppNotificationModel(
        id: 'n3',
        type: NotificationType.activity,
        title: 'Evening routine',
        message: 'Bedtime is in 30 minutes. Start the evening wind-down.',
        timestamp: ago(150),
        icon: 'moon',
      ),
      AppNotificationModel(
        id: 'n4',
        type: NotificationType.announcement,
        title: 'Parent announcement',
        message: 'Parent-teacher meeting on Friday at 4 PM. Please confirm attendance.',
        timestamp: ago(360),
        icon: 'bell',
        read: true,
      ),
      AppNotificationModel(
        id: 'n5',
        type: NotificationType.activity,
        title: 'Screen time alert',
        message: 'Mia used 65 minutes of screen time yesterday, 5 over the limit.',
        timestamp: ago(1440),
        icon: 'target',
        read: true,
      ),
      AppNotificationModel(
        id: 'n6',
        type: NotificationType.meal,
        title: 'Hydration goal',
        message: 'Mia reached 6 of 8 glasses today. Keep it going!',
        timestamp: ago(1800),
        icon: 'water',
        read: true,
      ),
    ];
  }

  static List<AchievementModel> achievements() => const [
    AchievementModel(
      id: 'ach1',
      title: 'Early Bird',
      description: 'Complete 5 morning tasks',
      icon: 'sun',
      total: 5,
      progress: 5,
      unlocked: true,
      coinsReward: 25,
    ),
    AchievementModel(
      id: 'ach2',
      title: 'Star Reader',
      description: 'Read 10 books',
      icon: 'book',
      total: 10,
      progress: 7,
      unlocked: false,
      coinsReward: 40,
    ),
    AchievementModel(
      id: 'ach3',
      title: 'Hydration Hero',
      description: 'Hit your water goal 5 days in a row',
      icon: 'water',
      total: 5,
      progress: 3,
      unlocked: false,
      coinsReward: 30,
    ),
    AchievementModel(
      id: 'ach4',
      title: 'Homework Champ',
      description: 'Finish 20 homework tasks',
      icon: 'homework',
      total: 20,
      progress: 20,
      unlocked: true,
      coinsReward: 50,
    ),
    AchievementModel(
      id: 'ach5',
      title: 'Sleepy Star',
      description: 'Sleep 9+ hours for 7 nights',
      icon: 'moon',
      total: 7,
      progress: 5,
      unlocked: false,
      coinsReward: 35,
    ),
    AchievementModel(
      id: 'ach6',
      title: 'Active Kid',
      description: 'Complete 30 outdoor activities',
      icon: 'run',
      total: 30,
      progress: 18,
      unlocked: false,
      coinsReward: 45,
    ),
  ];

  /// Tasks completed per weekday for the weekly dashboard chart.
  static List<(String, int)> weeklyTasks() {
    const List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const List<int> counts = [6, 5, 7, 4, 8, 5, 3];
    return List.generate(7, (i) => (days[i], counts[i]));
  }
}
