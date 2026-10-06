import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/repositories/activity_repository.dart';
import '../models/sleep_record_model.dart';
import '../core/utils/formatters.dart';

/// Sleep tracking records, backed by the REST API.
class SleepProvider extends ChangeNotifier {
  SleepProvider({ActivityRepository? repository})
    : _repository = repository ?? ActivityRepository();

  final ActivityRepository _repository;
  final Map<String, List<SleepRecord>> _byChild = {};

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
      _byChild[childId] = await _repository.sleep(childId);
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

  List<SleepRecord> get records {
    final List<SleepRecord> all = [];
    for (final List<SleepRecord> list in _byChild.values) {
      all.addAll(list);
    }
    return List.unmodifiable(all.reversed.toList());
  }

  List<SleepRecord> historyFor(String childId) => _byChild[childId] ?? const [];

  SleepRecord? todayFor(String childId, DateTime date) {
    for (final SleepRecord record in _byChild[childId] ?? const []) {
      if (_sameDay(record.date, date)) return record;
    }
    return null;
  }

  SleepRecord? latestFor(String childId) {
    final List<SleepRecord> list = historyFor(childId);
    return list.isEmpty ? null : list.first;
  }

  /// Upserts today's record (same child+date => server update).
  Future<void> upsertToday(SleepRecord record) async {
    final String childId = record.childId;
    try {
      final SleepRecord saved = await _repository.saveSleep(childId, {
        'date': Formatters.apiDate(record.date),
        'bedtimeHour': record.bedtimeHour,
        'bedtimeMinute': record.bedtimeMinute,
        'wakeHour': record.wakeHour,
        'wakeMinute': record.wakeMinute,
        'hours': record.hours,
        'quality': record.quality.name,
        'notes': record.notes,
      });
      _upsertLocal(saved);
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
    }
  }

  void _upsertLocal(SleepRecord record) {
    final List<SleepRecord> list = _byChild.putIfAbsent(record.childId, () => []);
    final int index = list.indexWhere((r) => _sameDay(r.date, record.date));
    if (index == -1) {
      list.add(record);
    } else {
      list[index] = record;
    }
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
