import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// A mood snapshot recorded by the child.
class MoodRecord {
  const MoodRecord({
    required this.id,
    required this.childId,
    required this.date,
    required this.mood,
    this.note = '',
  });

  final String id;
  final String childId;
  final DateTime date;
  final MoodType mood;
  final String note;

  Map<String, dynamic> toJson() => {
    'id': id,
    'childId': childId,
    'date': date.toIso8601String(),
    'mood': mood.name,
    'note': note,
  };

  factory MoodRecord.fromJson(Map<String, dynamic> json) => MoodRecord(
    id: json['id'] as String,
    childId: json['childId'] as String,
    date: DateTime.parse(json['date'] as String),
    mood: MoodType.values.byName(json['mood'] as String),
    note: json['note'] as String? ?? '',
  );
}

enum MoodType { happy, excited, calm, tired, sad, angry }

extension MoodTypeX on MoodType {
  String get label {
    switch (this) {
      case MoodType.happy:
        return 'Happy';
      case MoodType.excited:
        return 'Excited';
      case MoodType.calm:
        return 'Calm';
      case MoodType.tired:
        return 'Tired';
      case MoodType.sad:
        return 'Sad';
      case MoodType.angry:
        return 'Angry';
    }
  }

  IconData get icon {
    switch (this) {
      case MoodType.happy:
        return Icons.sentiment_very_satisfied;
      case MoodType.excited:
        return Icons.emoji_emotions;
      case MoodType.calm:
        return Icons.sentiment_satisfied_alt;
      case MoodType.tired:
        return Icons.bedtime_outlined;
      case MoodType.sad:
        return Icons.sentiment_dissatisfied;
      case MoodType.angry:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  Color colorOf(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return switch (this) {
      MoodType.happy => resolveAccent(const Color(0xFFFFC93C), brightness),
      MoodType.excited => resolveAccent(const Color(0xFFFF8A3D), brightness),
      MoodType.calm => resolveAccent(const Color(0xFF1FBFA0), brightness),
      MoodType.tired => resolveAccent(const Color(0xFF9AA4B5), brightness),
      MoodType.sad => resolveAccent(const Color(0xFF54C3F6), brightness),
      MoodType.angry => resolveAccent(AppPalette.light.error, brightness),
    };
  }
}
