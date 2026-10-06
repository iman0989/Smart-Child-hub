import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/repositories/activity_repository.dart';
import '../models/mood_record_model.dart';
import '../core/utils/formatters.dart';

/// Mood tracking records, backed by the REST API.
class MoodProvider extends ChangeNotifier {
  MoodProvider({ActivityRepository? repository}) : _repository = repository ?? ActivityRepository();

  final ActivityRepository _repository;
  final Map<String, List<MoodRecord>> _byChild = {};

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
      _byChild[childId] = await _repository.moods(childId);
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

  List<MoodRecord> get records {
    final List<MoodRecord> all = [];
    for (final List<MoodRecord> list in _byChild.values) {
      all.addAll(list);
    }
    return List.unmodifiable(all);
  }

  List<MoodRecord> moodsFor(String childId) => _byChild[childId] ?? const [];

  MoodRecord? latestFor(String childId) {
    final List<MoodRecord> list = moodsFor(childId);
    return list.isEmpty ? null : list.first;
  }

  Future<void> addMood({required String childId, required MoodType mood, String note = ''}) async {
    try {
      final MoodRecord created = await _repository.createMood(childId, {
        'date': Formatters.apiDateTime(DateTime.now()),
        'mood': mood.name,
        'note': note,
      });
      final List<MoodRecord> list = _byChild.putIfAbsent(childId, () => []);
      list.insert(0, created);
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
    }
  }
}
