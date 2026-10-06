/// A nightly sleep record.
class SleepRecord {
  const SleepRecord({
    required this.id,
    required this.childId,
    required this.date,
    required this.bedtimeHour,
    required this.bedtimeMinute,
    required this.wakeHour,
    required this.wakeMinute,
    required this.hours,
    this.quality = SleepQuality.good,
    this.notes = '',
  });

  final String id;
  final String childId;
  final DateTime date;
  final int bedtimeHour;
  final int bedtimeMinute;
  final int wakeHour;
  final int wakeMinute;
  final double hours;
  final SleepQuality quality;
  final String notes;

  SleepRecord copyWith({
    int? bedtimeHour,
    int? bedtimeMinute,
    int? wakeHour,
    int? wakeMinute,
    double? hours,
    SleepQuality? quality,
    String? notes,
  }) {
    return SleepRecord(
      id: id,
      childId: childId,
      date: date,
      bedtimeHour: bedtimeHour ?? this.bedtimeHour,
      bedtimeMinute: bedtimeMinute ?? this.bedtimeMinute,
      wakeHour: wakeHour ?? this.wakeHour,
      wakeMinute: wakeMinute ?? this.wakeMinute,
      hours: hours ?? this.hours,
      quality: quality ?? this.quality,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'childId': childId,
    'date': date.toIso8601String(),
    'bedtimeHour': bedtimeHour,
    'bedtimeMinute': bedtimeMinute,
    'wakeHour': wakeHour,
    'wakeMinute': wakeMinute,
    'hours': hours,
    'quality': quality.name,
    'notes': notes,
  };

  factory SleepRecord.fromJson(Map<String, dynamic> json) => SleepRecord(
    id: json['id'] as String,
    childId: json['childId'] as String,
    date: DateTime.parse(json['date'] as String),
    bedtimeHour: json['bedtimeHour'] as int,
    bedtimeMinute: json['bedtimeMinute'] as int,
    wakeHour: json['wakeHour'] as int,
    wakeMinute: json['wakeMinute'] as int,
    hours: (json['hours'] as num).toDouble(),
    quality: SleepQuality.values.byName(json['quality'] as String),
    notes: json['notes'] as String? ?? '',
  );
}

enum SleepQuality { restful, good, fair, poor }

extension SleepQualityX on SleepQuality {
  String get label {
    switch (this) {
      case SleepQuality.restful:
        return 'Restful';
      case SleepQuality.good:
        return 'Good';
      case SleepQuality.fair:
        return 'Fair';
      case SleepQuality.poor:
        return 'Poor';
    }
  }
}
