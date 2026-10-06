/// Daily water intake for a child.
class WaterIntakeModel {
  const WaterIntakeModel({
    required this.id,
    required this.childId,
    required this.date,
    this.glasses = 0,
    this.targetGlasses = 8,
    this.glassTimes = const [],
  });

  final String id;
  final String childId;
  final DateTime date;
  final int glasses;
  final int targetGlasses;

  /// Timestamps of each logged glass.
  final List<DateTime> glassTimes;

  double get progress => targetGlasses == 0 ? 0 : (glasses / targetGlasses).clamp(0, 1);

  bool get reachedTarget => glasses >= targetGlasses;

  WaterIntakeModel copyWith({int? glasses, List<DateTime>? glassTimes}) => WaterIntakeModel(
    id: id,
    childId: childId,
    date: date,
    glasses: glasses ?? this.glasses,
    targetGlasses: targetGlasses,
    glassTimes: glassTimes ?? this.glassTimes,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'childId': childId,
    'date': date.toIso8601String(),
    'glasses': glasses,
    'targetGlasses': targetGlasses,
    'glassTimes': glassTimes.map((t) => t.toIso8601String()).toList(),
  };

  factory WaterIntakeModel.fromJson(Map<String, dynamic> json) => WaterIntakeModel(
    id: json['id'] as String,
    childId: json['childId'] as String,
    date: DateTime.parse(json['date'] as String),
    glasses: json['glasses'] as int? ?? 0,
    targetGlasses: json['targetGlasses'] as int? ?? 8,
    glassTimes: (json['glassTimes'] as List<dynamic>? ?? [])
        .map((t) => DateTime.parse(t as String))
        .toList(),
  );
}
