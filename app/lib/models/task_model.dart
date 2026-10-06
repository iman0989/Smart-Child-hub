import '../core/utils/formatters.dart';

/// A scheduled task on a child's daily routine.
///
/// Every row belongs to exactly one calendar day ([date], `YYYY-MM-DD`) and its
/// [status] describes completion **for that day only**. A routine task that
/// repeats daily therefore has one independent row — and one independent
/// completion — per date, so yesterday's tick can never leak into today.
class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.category,
    required this.time,
    required this.coins,
    this.status = TaskStatus.pending,
    this.childId = '',
    this.date = '',
  });

  /// Id prefix for a routine task that has been projected onto a day but has
  /// no stored row of its own yet.
  static const String plannedPrefix = 'planned:';

  final String id;
  final String title;
  final String icon;
  final String category;
  final String time;
  final int coins;

  /// Completion state of this row for [date] — never a permanent flag.
  final TaskStatus status;

  final String childId;

  /// Calendar day this row belongs to, `YYYY-MM-DD` (local app date).
  final String date;

  /// True while this task is only a projection of the child's routine onto
  /// [date]; it becomes a real record the moment it is completed or edited.
  bool get isPlanned => id.startsWith(plannedPrefix);

  /// Whether this task counts as done on the given `YYYY-MM-DD` day.
  ///
  /// Deliberately date-scoped: a task completed yesterday is *not* completed
  /// today, which is what keeps the tick from sticking to a new day.
  bool isCompletedOn(String dayKey) => status == TaskStatus.completed && date == dayKey;

  /// Same check for a [DateTime], compared in the app's local calendar.
  bool isCompletedOnDay(DateTime day) => isCompletedOn(Formatters.apiDate(day));

  /// Projects a stored routine task onto [dayKey] as a fresh, uncompleted task.
  ///
  /// Used to show a daily recurring task on a day that has no rows yet without
  /// writing a duplicate record for that day.
  TaskModel projectedOn(String dayKey) => TaskModel(
    id: '$plannedPrefix$id:$dayKey',
    title: title,
    icon: icon,
    category: category,
    time: time,
    coins: coins,
    status: TaskStatus.pending,
    childId: childId,
    date: dayKey,
  );

  TaskModel copyWith({TaskStatus? status, String? date}) => TaskModel(
    id: id,
    title: title,
    icon: icon,
    category: category,
    time: time,
    coins: coins,
    status: status ?? this.status,
    childId: childId,
    date: date ?? this.date,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'icon': icon,
    'category': category,
    'time': time,
    'coins': coins,
    'status': status.name,
    'childId': childId,
    'date': date,
  };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json['id'] as String,
    title: json['title'] as String,
    icon: json['icon'] as String,
    category: json['category'] as String,
    time: json['time'] as String,
    coins: json['coins'] as int,
    status: TaskStatus.values.byName(json['status'] as String),
    childId: json['childId'] as String? ?? '',
    date: json['date'] as String? ?? '',
  );
}

enum TaskStatus { pending, completed, inProgress, locked }

extension TaskStatusX on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.inProgress:
        return 'In progress';
      case TaskStatus.locked:
        return 'Locked';
    }
  }
}
