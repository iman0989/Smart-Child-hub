import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/repositories/activity_repository.dart';
import '../models/meal_model.dart';
import '../core/utils/formatters.dart';

/// Meal tracking records, backed by the REST API.
class MealProvider extends ChangeNotifier {
  MealProvider({ActivityRepository? repository}) : _repository = repository ?? ActivityRepository();

  final ActivityRepository _repository;
  final Map<String, List<MealModel>> _byChild = {};

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
      _byChild[childId] = await _repository.meals(childId, date: date);
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

  List<MealModel> get meals {
    final List<MealModel> all = [];
    for (final List<MealModel> list in _byChild.values) {
      all.addAll(list);
    }
    return List.unmodifiable(all);
  }

  List<MealModel> mealsFor(String childId, {DateTime? date}) =>
      _byChild[childId]?.where((m) {
        if (date != null && !_sameDay(m.date, date)) return false;
        return true;
      }).toList() ??
      const [];

  MealModel? mealOfType(String childId, MealType type, DateTime date) {
    for (final MealModel meal in _byChild[childId] ?? const []) {
      if (meal.type == type && _sameDay(meal.date, date)) return meal;
    }
    return null;
  }

  int totalCalories(String childId, DateTime date) {
    int total = 0;
    for (final MealModel meal in mealsFor(childId, date: date)) {
      if (meal.eaten) total += meal.calories;
    }
    return total;
  }

  Future<void> toggleEaten(String id) async {
    final String? childId = _childOf(id);
    if (childId == null) return;
    final int index = _byChild[childId]!.indexWhere((m) => m.id == id);
    if (index == -1) return;

    final MealModel meal = _byChild[childId]![index];
    final MealModel updated = meal.copyWith(eaten: !meal.eaten);
    _byChild[childId]![index] = updated;
    notifyListeners();

    try {
      await _repository.updateMeal(id, {'eaten': updated.eaten});
    } on ApiException catch (e) {
      _byChild[childId]![index] = meal;
      _error = e.userMessage;
      notifyListeners();
    }
  }

  Future<void> addMeal(MealModel meal) async {
    final String childId = meal.childId;
    try {
      final MealModel created = await _repository.createMeal(childId, {
        'date': Formatters.apiDate(meal.date),
        'type': meal.type.name,
        'name': meal.name,
        'icon': meal.icon,
        'time': meal.time,
        'calories': meal.calories,
        'protein': meal.protein,
        'carbs': meal.carbs,
        'fat': meal.fat,
        'eaten': meal.eaten,
      });
      final List<MealModel> list = _byChild.putIfAbsent(childId, () => []);
      list.add(created);
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.userMessage;
      notifyListeners();
    }
  }

  String? _childOf(String id) {
    for (final MapEntry<String, List<MealModel>> entry in _byChild.entries) {
      if (entry.value.any((m) => m.id == id)) return entry.key;
    }
    return null;
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
