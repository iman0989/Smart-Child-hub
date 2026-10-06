/// A homework assignment.
class HomeworkModel {
  const HomeworkModel({
    required this.id,
    required this.childId,
    required this.title,
    required this.subject,
    required this.icon,
    required this.dueDate,
    this.status = HomeworkStatus.pending,
    this.coins = 5,
    this.progress = 0,
  });

  final String id;
  final String childId;
  final String title;
  final String subject;
  final String icon;
  final DateTime dueDate;
  final HomeworkStatus status;
  final int coins;

  /// 0.0 – 1.0 completion.
  final double progress;

  bool get isCompleted => status == HomeworkStatus.completed;

  HomeworkModel copyWith({HomeworkStatus? status, double? progress}) => HomeworkModel(
    id: id,
    childId: childId,
    title: title,
    subject: subject,
    icon: icon,
    dueDate: dueDate,
    status: status ?? this.status,
    coins: coins,
    progress: progress ?? this.progress,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'childId': childId,
    'title': title,
    'subject': subject,
    'icon': icon,
    'dueDate': dueDate.toIso8601String(),
    'status': status.name,
    'coins': coins,
    'progress': progress,
  };

  factory HomeworkModel.fromJson(Map<String, dynamic> json) => HomeworkModel(
    id: json['id'] as String,
    childId: json['childId'] as String,
    title: json['title'] as String,
    subject: json['subject'] as String,
    icon: json['icon'] as String,
    dueDate: DateTime.parse(json['dueDate'] as String),
    status: HomeworkStatus.values.byName(json['status'] as String),
    coins: json['coins'] as int? ?? 5,
    progress: (json['progress'] as num? ?? 0).toDouble(),
  );
}

enum HomeworkStatus { pending, inProgress, completed }

extension HomeworkStatusX on HomeworkStatus {
  String get label {
    switch (this) {
      case HomeworkStatus.pending:
        return 'Pending';
      case HomeworkStatus.inProgress:
        return 'In progress';
      case HomeworkStatus.completed:
        return 'Completed';
    }
  }
}
