import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/repositories/notification_repository.dart';
import '../models/app_notification_model.dart';

/// Notification center state, backed by the REST API.
class NotificationProvider extends ChangeNotifier {
  NotificationProvider({NotificationRepository? repository})
    : _repository = repository ?? NotificationRepository();

  final NotificationRepository _repository;
  final List<AppNotificationModel> _notifications = [];

  bool _isLoading = false;
  int _unreadCount = 0;
  String? _error;

  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;
  String? get error => _error;

  List<AppNotificationModel> get notifications => List.unmodifiable(_notifications);

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _notifications
        ..clear()
        ..addAll(await _repository.notifications());
      _unreadCount = await _repository.unreadCount();
    } on ApiException catch (e) {
      _error = e.userMessage;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => load();

  /// Clears all cached notifications + unread badge. Used when switching
  /// accounts so the next account never sees the previous notifications.
  void reset() {
    _notifications.clear();
    _unreadCount = 0;
    _error = null;
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    final int index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1 || _notifications[index].read) return;
    _notifications[index] = _notifications[index].copyWith(read: true);
    _decrementUnread();
    notifyListeners();
    try {
      await _repository.markRead(id);
    } on ApiException catch (e) {
      _notifications[index] = _notifications[index].copyWith(read: false);
      _unreadCount++;
      _error = e.userMessage;
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    if (_notifications.every((n) => n.read)) return;
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(read: true);
    }
    _unreadCount = 0;
    notifyListeners();
    try {
      await _repository.markAllRead();
    } on ApiException catch (e) {
      _error = e.userMessage;
      await load();
    }
  }

  Future<void> dismiss(String id) async {
    final int index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;
    final AppNotificationModel removed = _notifications.removeAt(index);
    if (!removed.read) _decrementUnread();
    notifyListeners();
    try {
      await _repository.delete(id);
    } on ApiException catch (e) {
      _notifications.insert(index, removed);
      if (!removed.read) _unreadCount++;
      _error = e.userMessage;
      notifyListeners();
    }
  }

  void add({required NotificationType type, required String title, required String message}) {
    _notifications.insert(
      0,
      AppNotificationModel(
        id: 'n-${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        title: title,
        message: message,
        timestamp: DateTime.now(),
        icon: type.icon,
      ),
    );
    _unreadCount++;
    notifyListeners();
  }

  void _decrementUnread() {
    if (_unreadCount > 0) _unreadCount--;
  }
}
