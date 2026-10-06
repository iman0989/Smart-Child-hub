/// A notification shown in the notification center.
class AppNotificationModel {
  const AppNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.read = false,
    this.icon = '',
  });

  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool read;
  final String icon;

  AppNotificationModel copyWith({bool? read}) => AppNotificationModel(
    id: id,
    type: type,
    title: title,
    message: message,
    timestamp: timestamp,
    read: read ?? this.read,
    icon: icon,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'read': read,
    'icon': icon,
  };

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) => AppNotificationModel(
    id: json['id'] as String,
    type: NotificationType.values.byName(json['type'] as String),
    title: json['title'] as String,
    message: json['message'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    read: json['read'] as bool? ?? false,
    icon: json['icon'] as String? ?? '',
  );
}

enum NotificationType { activity, meal, homework, announcement }

extension NotificationTypeX on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.activity:
        return 'Activity';
      case NotificationType.meal:
        return 'Meal';
      case NotificationType.homework:
        return 'Homework';
      case NotificationType.announcement:
        return 'Announcement';
    }
  }

  String get icon {
    switch (this) {
      case NotificationType.activity:
        return 'run';
      case NotificationType.meal:
        return 'food';
      case NotificationType.homework:
        return 'homework';
      case NotificationType.announcement:
        return 'bell';
    }
  }
}
