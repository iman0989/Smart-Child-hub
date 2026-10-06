import '../../core/constants/child_profile_rules.dart';

/// Child profile model.
class ChildModel {
  const ChildModel({
    required this.id,
    required this.name,
    required this.age,
    required this.grade,
    required this.avatarKey,
    this.hasPin = false,
    this.pin = '',
    this.photoUrl = '',
    this.coins = 0,
    this.streakDays = 0,
    this.aboutChild = '',
    this.securityQuestionKeys = const <String>[],
    this.securityQuestionAnswers = const <String, String>{},
  });

  final String id;
  final String name;

  /// Age in years. Must be between [ChildProfileRules.ageMin] and
  /// [ChildProfileRules.ageMax]; the API rejects anything outside that range.
  final int age;

  /// School grade. Canonical values are "Grade 1" .. "Grade 9", but profiles
  /// stored before those rules existed can still hold an older label, so the
  /// raw value is kept as-is for display.
  final String grade;

  /// Optional free-form note about the child. Replaces the old "School" field.
  final String aboutChild;

  /// Keys of the security questions a parent configured for this child. The
  /// answers are hashed server-side and are never part of any response.
  final List<String> securityQuestionKeys;

  /// Transient answers typed in the add/edit child form, keyed by question.
  ///
  /// Write-only like [pin]: sent on save, never serialized, never read from a
  /// response. An entry with a blank value keeps the answer already stored for
  /// that question.
  final Map<String, String> securityQuestionAnswers;

  /// Accent token name used for the avatar background: one of
  /// sunshine / candy / sky / grape / mint / peach.
  final String avatarKey;

  /// Whether the child profile has a 4-digit PIN set. The PIN value itself is
  /// never exposed by the API (see `hasPin` on the backend).
  final bool hasPin;

  /// Transient 4-digit PIN entered by the parent in the add/edit child form.
  /// Write-only: the server never returns it and it is never trusted from a
  /// response.
  final String pin;

  /// Uploaded profile photo URL (empty = use avatarKey).
  final String photoUrl;

  final int coins;
  final int streakDays;

  String get initials {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return parts[0][0] + parts[1][0];
    return name.isNotEmpty ? name[0] : '?';
  }

  /// The security questions configured for this child.
  List<ChildSecurityQuestion> get securityQuestions => securityQuestionKeys
      .map(ChildProfileRules.questionForKey)
      .whereType<ChildSecurityQuestion>()
      .toList(growable: false);

  ChildModel copyWith({
    String? name,
    int? age,
    String? grade,
    String? aboutChild,
    List<String>? securityQuestionKeys,
    Map<String, String>? securityQuestionAnswers,
    String? avatarKey,
    bool? hasPin,
    String? pin,
    String? photoUrl,
    int? coins,
    int? streakDays,
  }) {
    return ChildModel(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      grade: grade ?? this.grade,
      aboutChild: aboutChild ?? this.aboutChild,
      securityQuestionKeys: securityQuestionKeys ?? this.securityQuestionKeys,
      securityQuestionAnswers: securityQuestionAnswers ?? this.securityQuestionAnswers,
      avatarKey: avatarKey ?? this.avatarKey,
      hasPin: hasPin ?? this.hasPin,
      pin: pin ?? this.pin,
      photoUrl: photoUrl ?? this.photoUrl,
      coins: coins ?? this.coins,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'grade': grade,
    'aboutChild': aboutChild,
    'avatarKey': avatarKey,
    'hasPin': hasPin,
    'photoUrl': photoUrl,
    'coins': coins,
    'streakDays': streakDays,
  };

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    final String? rawPin = json['pin'] as String?;
    final bool serverHasPin = json['hasPin'] as bool? ?? false;
    return ChildModel(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      grade: json['grade'] as String,
      aboutChild: json['aboutChild'] as String? ?? '',
      securityQuestionKeys:
          (json['securityQuestions'] as List<dynamic>?)?.whereType<String>().toList(
            growable: false,
          ) ??
          const <String>[],
      avatarKey: json['avatarKey'] as String,
      photoUrl: json['photoUrl'] as String? ?? '',
      hasPin: serverHasPin || (rawPin != null && rawPin.isNotEmpty),
      coins: json['coins'] as int? ?? 0,
      streakDays: json['streakDays'] as int? ?? 0,
    );
  }
}
