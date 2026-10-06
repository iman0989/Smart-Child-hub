import '../../models/homework_model.dart';
import '../../models/meal_model.dart';
import '../../models/mood_record_model.dart';
import '../../models/sleep_record_model.dart';
import '../../models/task_model.dart';
import '../../models/water_intake_model.dart';
import '../network/api_client.dart';
import '../utils/formatters.dart';

/// Data access for every child-activity endpoint under `/api/children/{id}/*`.
///
/// Methods that create or update `Y-m-d`-scoped records use the backend's
/// upsert semantics (same child + date => update, otherwise insert).
class ActivityRepository {
  ActivityRepository([ApiClient? client]) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  // --- Tasks / routine activities ------------------------------------------

  Future<List<TaskModel>> activities(String childId, {DateTime? date}) async {
    final dynamic data = await _client.get(
      '/api/children/$childId/activities',
      query: date == null ? null : {'date': Formatters.apiDate(date)},
    );
    return _list(data, TaskModel.fromJson);
  }

  Future<TaskModel> createActivity(String childId, Map<String, dynamic> payload) async {
    final dynamic data = await _client.post('/api/children/$childId/activities', body: payload);
    return TaskModel.fromJson(data as Map<String, dynamic>);
  }

  Future<TaskModel> updateActivity(
    String childId,
    String activityId,
    Map<String, dynamic> payload,
  ) async {
    final dynamic data = await _client.put(
      '/api/children/$childId/activities/$activityId',
      body: payload,
    );
    return TaskModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteActivity(String childId, String activityId) async {
    await _client.delete('/api/children/$childId/activities/$activityId');
  }

  // --- Sleep ----------------------------------------------------------------

  Future<List<SleepRecord>> sleep(String childId) async {
    final dynamic data = await _client.get('/api/children/$childId/sleep');
    return _list(data, SleepRecord.fromJson);
  }

  Future<SleepRecord> saveSleep(String childId, Map<String, dynamic> payload) async {
    final dynamic data = await _client.post('/api/children/$childId/sleep', body: payload);
    return SleepRecord.fromJson(data as Map<String, dynamic>);
  }

  // --- Meals ----------------------------------------------------------------

  Future<List<MealModel>> meals(String childId, {DateTime? date}) async {
    final dynamic data = await _client.get(
      '/api/children/$childId/meals',
      query: date == null ? null : {'date': Formatters.apiDate(date)},
    );
    return _list(data, MealModel.fromJson);
  }

  Future<MealModel> createMeal(String childId, Map<String, dynamic> payload) async {
    final dynamic data = await _client.post('/api/children/$childId/meals', body: payload);
    return MealModel.fromJson(data as Map<String, dynamic>);
  }

  Future<MealModel> updateMeal(String mealId, Map<String, dynamic> payload) async {
    final dynamic data = await _client.put('/api/meals/$mealId', body: payload);
    return MealModel.fromJson(data as Map<String, dynamic>);
  }

  // --- Water intake ---------------------------------------------------------

  Future<List<WaterIntakeModel>> water(String childId, {DateTime? date}) async {
    final dynamic data = await _client.get(
      '/api/children/$childId/water',
      query: date == null ? null : {'date': Formatters.apiDate(date)},
    );
    return _list(data, WaterIntakeModel.fromJson);
  }

  /// Upserts the water intake for a child+date and replaces the glass log.
  Future<WaterIntakeModel> saveWater(String childId, Map<String, dynamic> payload) async {
    final dynamic data = await _client.post('/api/children/$childId/water', body: payload);
    return WaterIntakeModel.fromJson(data as Map<String, dynamic>);
  }

  // --- Mood -----------------------------------------------------------------

  Future<List<MoodRecord>> moods(String childId) async {
    final dynamic data = await _client.get('/api/children/$childId/moods');
    return _list(data, MoodRecord.fromJson);
  }

  Future<MoodRecord> createMood(String childId, Map<String, dynamic> payload) async {
    final dynamic data = await _client.post('/api/children/$childId/moods', body: payload);
    return MoodRecord.fromJson(data as Map<String, dynamic>);
  }

  // --- Homework -------------------------------------------------------------

  Future<List<HomeworkModel>> homework(String childId) async {
    final dynamic data = await _client.get('/api/children/$childId/homework');
    return _list(data, HomeworkModel.fromJson);
  }

  Future<HomeworkModel> createHomework(String childId, Map<String, dynamic> payload) async {
    final dynamic data = await _client.post('/api/children/$childId/homework', body: payload);
    return HomeworkModel.fromJson(data as Map<String, dynamic>);
  }

  Future<HomeworkModel> updateHomework(String homeworkId, Map<String, dynamic> payload) async {
    final dynamic data = await _client.put('/api/homework/$homeworkId', body: payload);
    return HomeworkModel.fromJson(data as Map<String, dynamic>);
  }

  List<T> _list<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data is! List) return const [];
    return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
}
