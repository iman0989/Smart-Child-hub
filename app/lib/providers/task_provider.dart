import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/repositories/activity_repository.dart';
import '../core/utils/formatters.dart';
import '../models/task_model.dart';

/// A child's task list for one calendar day, backed by the REST API.
///
/// The backend stores one `activities` row per child, per day, so completion is
/// inherently per-day. This provider keeps only the **current** day's rows in
/// `_byChild` and remembers which day they belong to, which is what stops a
/// tick from yesterday leaking into today.
class TaskProvider extends ChangeNotifier {
  TaskProvider({ActivityRepository? repository, DateTime Function()? now})
    : _repository = repository ?? ActivityRepository(),
      _now = now ?? DateTime.now;

  final ActivityRepository _repository;

  /// Returns the app's current local time; injectable so day rollover and
  /// date handling can be tested deterministically.
  final DateTime Function() _now;

  /// Today's rows (stored + projected) per child.
  final Map<String, List<TaskModel>> _byChild = {};

  /// The `YYYY-MM-DD` day each child's list represents.
  final Map<String, String> _dayByChild = {};

  String? _loadingChild;
  String? _error;

  bool get isLoading => _loadingChild != null;
  String? get error => _error;

  /// Clears all cached tasks. Used when switching accounts so the next
  /// account never sees the previous family's data.
  void reset() {
    _byChild.clear();
    _dayByChild.clear();
    _loadingChild = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  List<TaskModel> get tasks {
    final List<TaskModel> all = [];
    for (final List<TaskModel> list in _byChild.values) {
      all.addAll(list);
    }
    return List.unmodifiable(all);
  }

  /// Loads the tasks for [childId] on [date] (defaults to today).
  ///
  /// Refetches automatically once the calendar day has changed, so closing and
  /// reopening the app, pulling to refresh, or signing back in on a new day
  /// always yields that day's completions.
  Future<void> loadFor(String childId, {DateTime? date}) async {
    final String dayKey = Formatters.apiDate(date ?? _now());
    if (_loadingChild == childId) return;
    if (_dayByChild[childId] == dayKey) return;
    _loadingChild = childId;
    _error = null;
    notifyListeners();
    try {
      final List<TaskModel> rows = await _repository.activities(childId);
      _byChild[childId] = _tasksForDay(rows, dayKey);
      _dayByChild[childId] = dayKey;
    } on ApiException catch (e) {
      _error = e.userMessage;
    }
    _loadingChild = null;
    notifyListeners();
  }

  Future<void> refresh(String childId) => loadFor(childId);

  /// The `YYYY-MM-DD` day the cached list for [childId] belongs to.
  String? dayFor(String childId) => _dayByChild[childId];

  /// True when the cached list belongs to an earlier day than the app's
  /// current local date.
  bool isStale(String childId) => _dayByChild[childId] != Formatters.apiDate(_now());

  /// Reloads only when the calendar day has rolled over since the last load.
  Future<void> ensureCurrentDay(String childId) async {
    if (isStale(childId)) await loadFor(childId);
  }

  List<TaskModel> tasksFor(String childId) => _byChild[childId] ?? const [];

  int completedCount(String childId) =>
      tasksFor(childId).where((TaskModel t) => t.isCompletedOn(_currentDayKey(childId))).length;

  int totalCount(String childId) => tasksFor(childId).length;

  double progress(String childId) {
    final int total = totalCount(childId);
    if (total == 0) return 0;
    return completedCount(childId) / total;
  }

  String _currentDayKey(String childId) => _dayByChild[childId] ?? Formatters.apiDate(_now());

  /// Optimistically toggles a task's completion for the day it belongs to,
  /// then syncs to the server. The server awards coins when a task becomes
  /// completed.
  ///
  /// Returns the task in its new state, or null when nothing changed (unknown
  /// task, or a row belonging to a different day).
  Future<TaskModel?> toggle(String id) async {
    final String? childId = _childOf(id);
    if (childId == null) return null;
    final List<TaskModel> list = _byChild[childId]!;
    final int index = list.indexWhere((t) => t.id == id);
    if (index == -1) return null;

    final TaskModel task = list[index];
    final String dayKey = _currentDayKey(childId);

    // Never flip a row from another calendar day: yesterday's completion must
    // not mark (or re-award coins for) today's task.
    if (task.date != dayKey) return null;

    // A projected routine task has no row yet, so completing it creates the
    // record for today instead of duplicating a template row.
    if (task.isPlanned) {
      return _completePlanned(childId, index, task, dayKey);
    }

    final bool isDone = task.status == TaskStatus.completed;
    final TaskModel updated = task.copyWith(
      status: isDone ? TaskStatus.pending : TaskStatus.completed,
    );

    list[index] = updated;
    notifyListeners();

    try {
      await _repository.updateActivity(childId, id, {'status': updated.status.name});
      return updated;
    } on ApiException catch (e) {
      list[index] = task;
      _error = e.userMessage;
      notifyListeners();
      return null;
    }
  }

  /// Creates a new task for a specific child.
  Future<void> createTask(String childId, Map<String, dynamic> payload) async {
    _error = null;
    notifyListeners();
    try {
      final TaskModel created = await _repository.createActivity(childId, payload);
      final String dayKey = (created.date.isNotEmpty ? created.date : Formatters.apiDate(_now()));
      final List<TaskModel> list = _byChild.putIfAbsent(childId, () => []);
      if (dayKey == _dayByChild[childId]) {
        list.add(created);
      }
      _dayByChild.putIfAbsent(childId, () => dayKey);
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
    }
  }

  /// Updates an existing task for a specific child.
  Future<void> updateTask(String childId, String taskId, Map<String, dynamic> payload) async {
    _error = null;
    notifyListeners();
    try {
      final List<TaskModel>? list = _byChild[childId];
      final int idx = list == null ? -1 : list.indexWhere((t) => t.id == taskId);
      final TaskModel? existing = (list == null || idx == -1) ? null : list[idx];

      final TaskModel updated;
      if (existing != null && existing.isPlanned) {
        // Editing a projected task materialises it as a real row for that day.
        updated = await _repository.createActivity(childId, {...payload, 'date': existing.date});
      } else {
        updated = await _repository.updateActivity(childId, taskId, payload);
      }

      if (list != null && idx != -1) list[idx] = updated;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
    }
  }

  /// Deletes a task for a specific child.
  Future<void> deleteTask(String childId, String taskId) async {
    _error = null;
    notifyListeners();
    try {
      final List<TaskModel>? list = _byChild[childId];
      final int idx = list == null ? -1 : list.indexWhere((t) => t.id == taskId);
      final TaskModel? existing = (list == null || idx == -1) ? null : list[idx];

      // A projected task has no stored record, so dropping it from today's
      // list is the whole delete — the routine template stays untouched.
      if (existing != null && existing.isPlanned) {
        list!.removeAt(idx);
        notifyListeners();
        return;
      }

      await _repository.deleteActivity(childId, taskId);
      list?.removeWhere((t) => t.id == taskId);
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
    }
  }

  /// Completes a projected routine task, creating its record for [dayKey].
  Future<TaskModel?> _completePlanned(
    String childId,
    int index,
    TaskModel task,
    String dayKey,
  ) async {
    final List<TaskModel> list = _byChild[childId]!;
    try {
      final TaskModel created = await _repository.createActivity(childId, {
        'title': task.title,
        'icon': task.icon,
        'category': task.category,
        'time': task.time,
        'coins': task.coins,
        'status': TaskStatus.completed.name,
        'date': dayKey,
      });
      list[index] = created;
      notifyListeners();
      return created;
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
      return null;
    }
  }

  /// Picks the rows that belong to [dayKey].
  ///
  /// When the day has no rows yet, the most recent earlier day is re-created as
  /// a pending routine so a daily task appears unchecked instead of vanishing.
  /// Nothing is persisted here — a row is only written once the child actually
  /// completes (or edits) the projected task, so no duplicate records are
  /// created and earlier days keep their own completion history.
  static List<TaskModel> _tasksForDay(List<TaskModel> rows, String dayKey) {
    final List<TaskModel> today = rows.where((TaskModel t) => t.date == dayKey).toList();
    if (today.isNotEmpty) return today;

    // `YYYY-MM-DD` sorts chronologically, and future rows are ignored so a
    // scheduled task never leaks backwards into an earlier day.
    final List<TaskModel> past = rows
        .where((TaskModel t) => t.date.isNotEmpty && t.date.compareTo(dayKey) < 0)
        .toList();
    if (past.isEmpty) return const [];

    String latest = past.first.date;
    for (final TaskModel t in past) {
      if (t.date.compareTo(latest) > 0) latest = t.date;
    }
    return past
        .where((TaskModel t) => t.date == latest)
        .map((TaskModel t) => t.projectedOn(dayKey))
        .toList();
  }

  String? _childOf(String id) {
    for (final MapEntry<String, List<TaskModel>> entry in _byChild.entries) {
      if (entry.value.any((TaskModel t) => t.id == id)) return entry.key;
    }
    return null;
  }
}
