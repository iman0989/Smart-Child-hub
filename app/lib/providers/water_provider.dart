import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/repositories/activity_repository.dart';
import '../models/water_intake_model.dart';
import '../core/utils/formatters.dart';

/// Water intake tracking, backed by the REST API.
class WaterProvider extends ChangeNotifier {
  WaterProvider({ActivityRepository? repository})
    : _repository = repository ?? ActivityRepository();

  final ActivityRepository _repository;
  final Map<String, List<WaterIntakeModel>> _byChild = {};

  String? _loadingChild;
  String? _error;

  bool get isLoading => _loadingChild != null;
  String? get error => _error;

  Future<void> loadFor(String childId, {DateTime? date}) async {
    if (_loadingChild == childId) return;
    _loadingChild = childId;
    _error = null;
    notifyListeners();
    try {
      _byChild[childId] = await _repository.water(childId, date: date);
    } on ApiException catch (e) {
      _error = e.userMessage;
    }
    _loadingChild = null;
    notifyListeners();
  }

  Future<void> refresh(String childId, {DateTime? date}) => loadFor(childId, date: date);

  /// Clears all cached records. Used when switching accounts.
  void reset() {
    _byChild.clear();
    _loadingChild = null;
    _error = null;
    notifyListeners();
  }

  List<WaterIntakeModel> get logs {
    final List<WaterIntakeModel> all = [];
    for (final List<WaterIntakeModel> list in _byChild.values) {
      all.addAll(list);
    }
    return List.unmodifiable(all);
  }

  WaterIntakeModel? todayFor(String childId, DateTime date) {
    for (final WaterIntakeModel log in _byChild[childId] ?? const []) {
      if (_sameDay(log.date, date)) return log;
    }
    return null;
  }

  Future<void> addGlass(String childId, DateTime date) async {
    final WaterIntakeModel current = _local(childId, date);
    await _save(childId, date, current.glasses + 1, current.targetGlasses, [
      ...current.glassTimes,
      DateTime.now(),
    ]);
  }

  Future<void> removeGlass(String childId, DateTime date) async {
    final WaterIntakeModel current = _local(childId, date);
    if (current.glasses <= 0) return;
    final List<DateTime> times = [...current.glassTimes];
    if (times.isNotEmpty) times.removeLast();
    await _save(childId, date, current.glasses - 1, current.targetGlasses, times);
  }

  Future<void> resetGlasses(String childId, DateTime date) async {
    await _save(childId, date, 0, 8, const []);
  }

  Future<void> _save(
    String childId,
    DateTime date,
    int glasses,
    int target,
    List<DateTime> times,
  ) async {
    final WaterIntakeModel updated = WaterIntakeModel(
      id: 'w-${DateTime.now().millisecondsSinceEpoch}',
      childId: childId,
      date: date,
      glasses: glasses,
      targetGlasses: target,
      glassTimes: times,
    );
    _upsertLocal(updated);
    notifyListeners();
    try {
      final WaterIntakeModel saved = await _repository.saveWater(childId, {
        'date': Formatters.apiDate(date),
        'glasses': glasses,
        'targetGlasses': target,
        'glassTimes': times.map((t) => t.toIso8601String()).toList(),
      });
      _upsertLocal(saved);
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
    }
  }

  WaterIntakeModel _local(String childId, DateTime date) {
    final WaterIntakeModel? existing = todayFor(childId, date);
    return existing ??
        WaterIntakeModel(
          id: 'w-${DateTime.now().millisecondsSinceEpoch}',
          childId: childId,
          date: date,
        );
  }

  void _upsertLocal(WaterIntakeModel log) {
    final List<WaterIntakeModel> list = _byChild.putIfAbsent(log.childId, () => []);
    final int index = list.indexWhere((l) => _sameDay(l.date, log.date));
    if (index == -1) {
      list.add(log);
    } else {
      list[index] = log;
    }
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
