import 'dart:typed_data';

import '../../models/child_model.dart';
import '../network/api_client.dart';

/// Parent dashboard summary from `GET /api/parent/dashboard`.
class ParentDashboard {
  const ParentDashboard({
    required this.childrenCount,
    required this.totalCoins,
    required this.todayTasksDone,
    required this.todayTasksTotal,
    required this.pendingHomework,
    required this.unreadNotifications,
    required this.averageSleepHours,
    required this.waterGoalProgress,
    required this.childSummaries,
  });

  final int childrenCount;
  final int totalCoins;
  final int todayTasksDone;
  final int todayTasksTotal;
  final int pendingHomework;
  final int unreadNotifications;
  final double averageSleepHours;
  final double waterGoalProgress;

  /// Per-child today progress keyed by child id.
  final Map<String, (int done, int total)> childSummaries;

  factory ParentDashboard.fromJson(Map<String, dynamic> json) {
    final Map<String, (int, int)> summaries = {};
    for (final dynamic item in json['children'] as List<dynamic>? ?? const []) {
      final Map<String, dynamic> m = item as Map<String, dynamic>;
      final String id = (m['child'] as Map<String, dynamic>)['id'] as String;
      summaries[id] = (
        (m['todayTasksDone'] as num?)?.toInt() ?? 0,
        (m['todayTasksTotal'] as num?)?.toInt() ?? 0,
      );
    }
    return ParentDashboard(
      childrenCount: (json['childrenCount'] as num?)?.toInt() ?? 0,
      totalCoins: (json['totalCoins'] as num?)?.toInt() ?? 0,
      todayTasksDone: (json['todayTasksDone'] as num?)?.toInt() ?? 0,
      todayTasksTotal: (json['todayTasksTotal'] as num?)?.toInt() ?? 0,
      pendingHomework: (json['pendingHomework'] as num?)?.toInt() ?? 0,
      unreadNotifications: (json['unreadNotifications'] as num?)?.toInt() ?? 0,
      averageSleepHours: (json['averageSleepHours'] as num?)?.toDouble() ?? 0,
      waterGoalProgress: (json['waterGoalProgress'] as num?)?.toDouble() ?? 0,
      childSummaries: summaries,
    );
  }
}

/// Data access for parent profile, children CRUD and the dashboard endpoint.
class ChildRepository {
  ChildRepository([ApiClient? client]) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<ChildModel>> children() async {
    final dynamic data = await _client.get('/api/parent/children');
    final Map<String, dynamic> map = data as Map<String, dynamic>;
    final List<dynamic> items = map['items'] as List<dynamic>? ?? const [];
    return items.map((e) => ChildModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ChildModel> create(Map<String, dynamic> payload) async {
    final dynamic data = await _client.post('/api/parent/children', body: payload);
    return ChildModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ChildModel> update(String id, Map<String, dynamic> payload) async {
    final dynamic data = await _client.put('/api/parent/children/$id', body: payload);
    return ChildModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _client.delete('/api/parent/children/$id');
  }

  /// Security question keys configured for a child. Only the keys come back -
  /// the answers stay hashed on the server.
  Future<List<String>> securityQuestions(String childId) async {
    final dynamic data = await _client.get('/api/parent/children/$childId/security-questions');
    final Map<String, dynamic> map = data as Map<String, dynamic>;
    return (map['items'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> item) => item['questionKey'] as String? ?? '')
        .where((String key) => key.isNotEmpty)
        .toList(growable: false);
  }

  /// Uploads a child profile photo via multipart. Returns the updated child.
  ///
  /// The image travels as bytes so the same call works on Web, where the picked
  /// file has no readable filesystem path.
  Future<ChildModel> uploadPhoto({
    required String childId,
    required Uint8List bytes,
    required String filename,
  }) async {
    final dynamic data = await _client.postMultipart(
      '/api/parent/children/$childId/photo',
      fileField: 'photo',
      bytes: bytes,
      filename: filename,
    );
    return ChildModel.fromJson(data as Map<String, dynamic>);
  }

  /// Clears a child's photo. Idempotent on the server, so this is safe to call
  /// even when no photo is set. Returns the updated child.
  Future<ChildModel> removePhoto(String childId) async {
    final dynamic data = await _client.delete('/api/parent/children/$childId/photo');
    return ChildModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ChildModel> changePin({
    required String childId,
    required String currentPin,
    required String newPin,
    required String newPinConfirmation,
  }) async {
    final dynamic data = await _client.put(
      '/api/parent/children/$childId/pin',
      body: {'currentPin': currentPin, 'newPin': newPin, 'newPinConfirmation': newPinConfirmation},
    );
    return ChildModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ParentDashboard> dashboard() async {
    final dynamic data = await _client.get('/api/parent/dashboard');
    return ParentDashboard.fromJson(data as Map<String, dynamic>);
  }
}
