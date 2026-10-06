/// An achievement / badge a child can unlock.
class AchievementModel {
  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.total,
    this.progress = 0,
    this.coinsReward = 0,
    this.unlocked = false,
  });

  final String id;
  final String title;
  final String description;
  final String icon;
  final int total;

  /// 0..total progress toward unlock.
  final int progress;
  final int coinsReward;
  final bool unlocked;

  double get progressValue => total == 0 ? 0 : (progress / total).clamp(0, 1);

  AchievementModel copyWith({int? progress, bool? unlocked}) => AchievementModel(
    id: id,
    title: title,
    description: description,
    icon: icon,
    total: total,
    progress: progress ?? this.progress,
    coinsReward: coinsReward,
    unlocked: unlocked ?? this.unlocked,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon,
    'total': total,
    'progress': progress,
    'coinsReward': coinsReward,
    'unlocked': unlocked,
  };

  factory AchievementModel.fromJson(Map<String, dynamic> json) => AchievementModel(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    icon: json['icon'] as String,
    total: json['total'] as int,
    progress: json['progress'] as int? ?? 0,
    coinsReward: json['coinsReward'] as int? ?? 0,
    unlocked: json['unlocked'] as bool? ?? false,
  );
}
