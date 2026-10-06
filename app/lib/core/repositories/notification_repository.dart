import '../../models/app_notification_model.dart';
import '../network/api_client.dart';

/// Data access for the `/api/notifications*` endpoints.
class NotificationRepository {
  NotificationRepository([ApiClient? client]) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<AppNotificationModel>> notifications({int page = 1, int perPage = 50}) async {
    final dynamic data = await _client.get(
      '/api/notifications',
      query: {'page': '$page', 'perPage': '$perPage'},
    );
    final Map<String, dynamic> map = data as Map<String, dynamic>;
    final List<dynamic> items = map['items'] as List<dynamic>? ?? const [];
    return items.map((e) => AppNotificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<int> unreadCount() async {
    final dynamic data = await _client.get('/api/notifications/unread-count');
    return ((data as Map<String, dynamic>)['unread'] as num?)?.toInt() ?? 0;
  }

  Future<void> markRead(String id) async {
    await _client.put('/api/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _client.put('/api/notifications/read-all');
  }

  Future<void> delete(String id) async {
    await _client.delete('/api/notifications/$id');
  }
}
