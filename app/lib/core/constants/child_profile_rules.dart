/// Child profile rules shared by the add/edit child form, the child profile
/// screen and the child PIN recovery flow.
///
/// The API enforces the same limits, so these constants mirror the backend
/// (`backend/app/config/config.php` + `ChildModel`).
library;

/// A security question a parent can set for a child, used to recover a
/// forgotten 4-digit PIN. Answers are hashed server-side and never returned.
class ChildSecurityQuestion {
  const ChildSecurityQuestion({required this.key, required this.question});

  /// Stable identifier sent to and received from the API.
  final String key;

  /// Parent-facing wording shown in the form and to the child during recovery.
  final String question;

  @override
  bool operator ==(Object other) => other is ChildSecurityQuestion && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

/// Age, grade and recovery rules for a child profile.
class ChildProfileRules {
  ChildProfileRules._();

  /// Supported age range for the kids zone.
  static const int ageMin = 4;
  static const int ageMax = 14;

  /// Hint shown under the age field.
  static const String ageHint = 'Age $ageMin - $ageMax';

  /// Supported school grades, lowest first.
  static const int gradeMin = 1;
  static const int gradeMax = 9;

  /// Maximum length of the optional "About child" note.
  static const int aboutChildMaxLength = 255;

  /// How many security questions a single child may have.
  static const int maxSecurityQuestions = 2;

  /// Shortest answer the API accepts.
  static const int minAnswerLength = 2;

  /// Longest answer the API accepts.
  static const int maxAnswerLength = 80;

  /// Canonical grade labels, "Grade 1" through "Grade 9".
  static List<String> get grades =>
      List<String>.generate(gradeMax - gradeMin + 1, (int index) => 'Grade ${index + gradeMin}');

  /// Neutral, child-friendly recovery questions. The keys must match the
  /// backend bank in `backend/app/models/ChildSecurityQuestion.php`.
  static const List<ChildSecurityQuestion> securityQuestions = [
    ChildSecurityQuestion(key: 'favorite_book', question: 'What is your favorite book?'),
    ChildSecurityQuestion(key: 'best_friend', question: 'Who is your best friend?'),
    ChildSecurityQuestion(key: 'favorite_animal', question: 'What is your favorite animal?'),
    ChildSecurityQuestion(key: 'favorite_food', question: 'What is your favorite food?'),
    ChildSecurityQuestion(key: 'favorite_color', question: 'What is your favorite color?'),
    ChildSecurityQuestion(
      key: 'favorite_cartoon',
      question: 'Who is your favorite cartoon character?',
    ),
    ChildSecurityQuestion(key: 'birth_city', question: 'Which city were you born in?'),
    ChildSecurityQuestion(key: 'teacher_name', question: "What is your teacher's first name?"),
    ChildSecurityQuestion(key: 'pet_name', question: 'What is the name of your pet?'),
  ];

  /// The question matching [key], or null when the key is unknown.
  static ChildSecurityQuestion? questionForKey(String key) {
    for (final ChildSecurityQuestion question in securityQuestions) {
      if (question.key == key) return question;
    }
    return null;
  }

  /// The wording for [key], falling back to a neutral label.
  static String questionText(String key) => questionForKey(key)?.question ?? 'Security question';

  /// True when [age] is a whole number inside the supported range.
  static bool isValidAge(int? age) => age != null && age >= ageMin && age <= ageMax;

  /// Validates a typed age and returns an error message, or null when valid.
  static String? validateAge(String? raw) {
    final String value = (raw ?? '').trim();
    if (value.isEmpty) return 'Please enter the age';
    final int? age = int.tryParse(value);
    if (age == null) return 'Please enter a valid age';
    if (!isValidAge(age)) return 'Age must be between $ageMin and $ageMax.';
    return null;
  }

  /// Parses a typed age, returning null when it is missing or malformed.
  static int? parseAge(String? raw) {
    final String value = (raw ?? '').trim();
    if (value.isEmpty) return null;
    return int.tryParse(value);
  }

  /// Normalizes a grade to its canonical label, e.g. "3" -> "Grade 3".
  ///
  /// Returns null when the value is not a grade between Grade 1 and Grade 9.
  /// Matches `ChildModel::normalizeGrade()` on the backend.
  static String? normalizeGrade(String? raw) {
    String cleaned = (raw ?? '').trim().toLowerCase();
    cleaned = cleaned.replaceFirst(RegExp(r'^(grade|g)\s*'), '').trim();
    if (!RegExp(r'^\d{1,2}$').hasMatch(cleaned)) return null;
    final int grade = int.parse(cleaned);
    if (grade < gradeMin || grade > gradeMax) return null;
    return 'Grade $grade';
  }

  /// True when [grade] resolves to Grade 1 - Grade 9.
  static bool isValidGrade(String? grade) => normalizeGrade(grade) != null;

  /// The grade number for [grade], or null when it is not a Grade 1-9 value.
  static int? gradeNumber(String? grade) {
    final String? normalized = normalizeGrade(grade);
    if (normalized == null) return null;
    return int.tryParse(normalized.substring('Grade '.length));
  }

  /// Validates a typed grade and returns an error message, or null when valid.
  static String? validateGrade(String? raw) {
    final String value = (raw ?? '').trim();
    if (value.isEmpty) return 'Please choose a grade';
    if (!isValidGrade(value)) {
      return 'Grade must be between Grade $gradeMin and Grade $gradeMax.';
    }
    return null;
  }

  /// Human readable grade range, e.g. "Grade 1 - Grade 9".
  static String get gradeHint => 'Grade $gradeMin - Grade $gradeMax';
}
