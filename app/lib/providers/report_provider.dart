import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/repositories/report_repository.dart';
import '../models/report_model.dart';

/// Aggregated report stats per child + period, backed by the REST API.
class ReportProvider extends ChangeNotifier {
  ReportProvider({ReportRepository? repository}) : _repository = repository ?? ReportRepository();

  final ReportRepository _repository;
  final Map<String, Map<ReportPeriod, ReportStatsModel>> _byChild = {};

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Clears all cached reports. Used when switching accounts.
  void reset() {
    _byChild.clear();
    _error = null;
    notifyListeners();
  }

  /// Fetches (or returns the cached) stats for a child + period.
  Future<ReportStatsModel> load(String childId, ReportPeriod period) async {
    final ReportStatsModel? cached = statsFor(childId, period);
    if (cached != null) return cached;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final ReportStatsModel stats = await _repository.report(childId, period);
      _byChild.putIfAbsent(childId, () => {})[period] = stats;
      _isLoading = false;
      notifyListeners();
      return stats;
    } on ApiException catch (e) {
      _isLoading = false;
      _error = e.userMessage;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refresh(String childId, ReportPeriod period) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final ReportStatsModel stats = await _repository.report(childId, period);
      _byChild.putIfAbsent(childId, () => {})[period] = stats;
    } on ApiException catch (e) {
      _error = e.userMessage;
    }
    _isLoading = false;
    notifyListeners();
  }

  ReportStatsModel? statsFor(String childId, ReportPeriod period) => _byChild[childId]?[period];

  /// Tasks completed per weekday (Mon–Sun) for the weekly dashboard chart.
  List<(String, int)> weeklyTasks(String childId) {
    final ReportStatsModel? stats = statsFor(childId, ReportPeriod.weekly);
    if (stats == null) return const [];
    return stats.taskChart.map((c) => (c.label, c.value.toInt())).toList();
  }
}
