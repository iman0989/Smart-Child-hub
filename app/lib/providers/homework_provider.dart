import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/repositories/activity_repository.dart';
import '../models/homework_model.dart';
import '../core/utils/formatters.dart';

/// Homework tracking, backed by the REST API.
class HomeworkProvider extends ChangeNotifier {
  HomeworkProvider({ActivityRepository? repository})
    : _repository = repository ?? ActivityRepository();

  final ActivityRepository _repository;
  final Map<String, List<HomeworkModel>> _byChild = {};

  String? _loadingChild;
  String? _error;

  bool get isLoading => _loadingChild != null;
  String? get error => _error;

  Future<void> loadFor(String childId) async {
    if (_loadingChild == childId) return;
    _loadingChild = childId;
    _error = null;
    notifyListeners();
    try {
      _byChild[childId] = await _repository.homework(childId);
    } on ApiException catch (e) {
      _error = e.userMessage;
    }
    _loadingChild = null;
    notifyListeners();
  }

  Future<void> refresh(String childId) => loadFor(childId);

  /// Clears all cached records. Used when switching accounts.
  void reset() {
    _byChild.clear();
    _loadingChild = null;
    _error = null;
    notifyListeners();
  }

  List<HomeworkModel> get homework {
    final List<HomeworkModel> all = [];
    for (final List<HomeworkModel> list in _byChild.values) {
      all.addAll(list);
    }
    return List.unmodifiable(all);
  }

  List<HomeworkModel> homeworkFor(String childId) => _byChild[childId] ?? const [];

  List<HomeworkModel> completedFor(String childId) =>
      homeworkFor(childId).where((h) => h.isCompleted).toList();

  List<HomeworkModel> pendingFor(String childId) =>
      homeworkFor(childId).where((h) => !h.isCompleted).toList();

  double progressFor(String childId) {
    final List<HomeworkModel> list = homeworkFor(childId);
    if (list.isEmpty) return 0;
    return list.where((h) => h.isCompleted).length / list.length;
  }

  Future<void> toggleComplete(String id) async {
    final String? childId = _childOf(id);
    if (childId == null) return;
    final int index = _byChild[childId]!.indexWhere((h) => h.id == id);
    if (index == -1) return;

    final HomeworkModel h = _byChild[childId]![index];
    final bool done = !h.isCompleted;
    final HomeworkModel updated = h.copyWith(
      status: done ? HomeworkStatus.completed : HomeworkStatus.pending,
      progress: done ? 1 : 0,
    );
    _byChild[childId]![index] = updated;
    notifyListeners();

    try {
      await _repository.updateHomework(id, {
        'status': updated.status.name,
        'progress': updated.progress,
      });
    } on ApiException catch (e) {
      _byChild[childId]![index] = h;
      _error = e.userMessage;
      notifyListeners();
    }
  }

  Future<void> addHomework(HomeworkModel model) async {
    final String childId = model.childId;
    try {
      final HomeworkModel created = await _repository.createHomework(childId, {
        'title': model.title,
        'subject': model.subject,
        'icon': model.icon,
        'dueDate': Formatters.apiDate(model.dueDate),
        'status': model.status.name,
        'coins': model.coins,
        'progress': model.progress,
      });
      final List<HomeworkModel> list = _byChild.putIfAbsent(childId, () => []);
      list.add(created);
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
    }
  }

  String? _childOf(String id) {
    for (final MapEntry<String, List<HomeworkModel>> entry in _byChild.entries) {
      if (entry.value.any((h) => h.id == id)) return entry.key;
    }
    return null;
  }
}
