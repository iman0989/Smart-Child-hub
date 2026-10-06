/// A meal logged for a child on a given day.
class MealModel {
  const MealModel({
    required this.id,
    required this.childId,
    required this.date,
    required this.type,
    required this.name,
    required this.icon,
    required this.time,
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.eaten = true,
  });

  final String id;
  final String childId;
  final DateTime date;
  final MealType type;
  final String name;
  final String icon;
  final String time;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final bool eaten;

  MealModel copyWith({bool? eaten, int? calories}) => MealModel(
    id: id,
    childId: childId,
    date: date,
    type: type,
    name: name,
    icon: icon,
    time: time,
    calories: calories ?? this.calories,
    protein: protein,
    carbs: carbs,
    fat: fat,
    eaten: eaten ?? this.eaten,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'childId': childId,
    'date': date.toIso8601String(),
    'type': type.name,
    'name': name,
    'icon': icon,
    'time': time,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'eaten': eaten,
  };

  factory MealModel.fromJson(Map<String, dynamic> json) => MealModel(
    id: json['id'] as String,
    childId: json['childId'] as String,
    date: DateTime.parse(json['date'] as String),
    type: MealType.values.byName(json['type'] as String),
    name: json['name'] as String,
    icon: json['icon'] as String,
    time: json['time'] as String,
    calories: json['calories'] as int? ?? 0,
    protein: json['protein'] as int? ?? 0,
    carbs: json['carbs'] as int? ?? 0,
    fat: json['fat'] as int? ?? 0,
    eaten: json['eaten'] as bool? ?? true,
  );
}

enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeX on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String get icon {
    switch (this) {
      case MealType.breakfast:
        return 'sun';
      case MealType.lunch:
        return 'food';
      case MealType.dinner:
        return 'moon';
      case MealType.snack:
        return 'heart';
    }
  }
}
