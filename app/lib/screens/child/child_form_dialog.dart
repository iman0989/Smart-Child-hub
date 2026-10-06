import 'package:flutter/material.dart';

import '../../core/constants/app_icons.dart';
import '../../core/constants/child_profile_rules.dart';
import '../../core/repositories/child_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../models/child_model.dart';
import '../../widgets/common/child_avatar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';

/// Create / edit child dialog. Returns the resulting [ChildModel] or null.
class ChildFormDialog extends StatefulWidget {
  const ChildFormDialog({super.key, this.child});

  final ChildModel? child;

  @override
  State<ChildFormDialog> createState() => _ChildFormDialogState();
}

class _ChildFormDialogState extends State<ChildFormDialog> {
  static const List<String> _avatarKeys = ['sunshine', 'candy', 'sky', 'grape', 'mint', 'peach'];

  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _aboutChildController;
  late final TextEditingController _pinController;
  late String _avatarKey;

  /// Grade 1 - 9. Null until a parent picks one.
  String? _grade;

  /// The two security-question rows (question key + answer typed for it).
  final List<_QuestionDraft> _questions = [_QuestionDraft(), _QuestionDraft()];

  /// True while the configured question keys are being fetched on edit.
  bool _loadingQuestions = false;

  @override
  void initState() {
    super.initState();
    final ChildModel? c = widget.child;
    _nameController = TextEditingController(text: c?.name ?? '');
    _ageController = TextEditingController(text: c?.age.toString() ?? '');
    _aboutChildController = TextEditingController(text: c?.aboutChild ?? '');
    // Never pre-fill a stored PIN: the API does not expose it and editing a
    // profile must not reveal it. Leave blank on edit to keep the current PIN.
    _pinController = TextEditingController();
    _avatarKey = c?.avatarKey ?? 'sunshine';

    // A grade stored before the Grade 1-9 rule is kept selectable so an edit
    // does not silently reset it.
    final String? stored = c?.grade;
    _grade = stored == null ? null : ChildProfileRules.normalizeGrade(stored) ?? stored;

    if (c != null) {
      _loadSecurityQuestions(c);
    }
  }

  /// Pull the configured question keys so the form can show them again. The
  /// answers are never returned by the API, so those fields stay blank and
  /// blank means "keep what is already stored".
  Future<void> _loadSecurityQuestions(ChildModel child) async {
    setState(() => _loadingQuestions = true);

    List<String> keys = child.securityQuestionKeys;
    try {
      keys = await ChildRepository().securityQuestions(child.id);
    } catch (_) {
      // Keep whatever the child payload already carried.
    }

    if (!mounted) return;
    setState(() {
      _loadingQuestions = false;
      for (int i = 0; i < _questions.length && i < keys.length; i++) {
        _questions[i].key = keys[i];
        _questions[i].kept = true;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _aboutChildController.dispose();
    _pinController.dispose();
    for (final _QuestionDraft question in _questions) {
      question.answerController.dispose();
    }
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _save() {
    final String name = _nameController.text.trim();

    final String? nameError = name.isEmpty ? 'Please enter the child\'s name.' : null;
    final String? ageError = ChildProfileRules.validateAge(_ageController.text);
    final String? gradeError = ChildProfileRules.validateGrade(_grade);

    final String? fieldError = nameError ?? ageError ?? gradeError;
    if (fieldError != null) {
      _showError(fieldError);
      return;
    }

    final int age = ChildProfileRules.parseAge(_ageController.text)!;
    final String grade = ChildProfileRules.normalizeGrade(_grade)!;

    final String aboutChild = _aboutChildController.text.trim();
    if (aboutChild.length > ChildProfileRules.aboutChildMaxLength) {
      _showError(
        'About child must be ${ChildProfileRules.aboutChildMaxLength} characters or fewer.',
      );
      return;
    }

    final String pin = _pinController.text.trim();
    final bool isNew = widget.child == null;
    if (pin.isEmpty && isNew) {
      _showError('Please set a 4-digit PIN for the child.');
      return;
    }
    if (pin.isNotEmpty && !RegExp(r'^\d{4}$').hasMatch(pin)) {
      _showError('The PIN must be exactly 4 digits.');
      return;
    }

    // Build the security questions: a question with a blank answer keeps the
    // answer already stored for it.
    final List<String> questionKeys = <String>[];
    final Map<String, String> answers = <String, String>{};
    for (final _QuestionDraft draft in _questions) {
      final String? key = draft.key;
      if (key == null) continue;
      final String answer = draft.answerController.text.trim();
      if (answer.isEmpty && !draft.kept) {
        // A newly chosen question needs an answer.
        _showError('Please enter an answer for the security question.');
        return;
      }
      if (questionKeys.contains(key)) continue;
      questionKeys.add(key);
      answers[key] = answer;
    }
    if (questionKeys.length > ChildProfileRules.maxSecurityQuestions) {
      _showError('You can set up to ${ChildProfileRules.maxSecurityQuestions} security questions.');
      return;
    }

    final ChildModel result = ChildModel(
      id: widget.child?.id ?? 'c-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      age: age,
      grade: grade,
      aboutChild: aboutChild,
      securityQuestionKeys: questionKeys,
      securityQuestionAnswers: answers,
      avatarKey: _avatarKey,
      hasPin: widget.child?.hasPin ?? false,
      pin: pin,
      photoUrl: widget.child?.photoUrl ?? '',
      coins: widget.child?.coins ?? 0,
      streakDays: widget.child?.streakDays ?? 0,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppPalette palette = context.sch;

    return AlertDialog(
      title: Text(
        widget.child == null ? 'Add a new child' : 'Edit child',
        style: theme.textTheme.titleLarge,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  ChildAvatar(
                    name: _nameController.text.isEmpty ? '?' : _nameController.text,
                    avatarKey: _avatarKey,
                    size: 72,
                    photoUrl: widget.child?.photoUrl ?? '',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children: [
                      for (final String key in _avatarKeys)
                        InkWell(
                          onTap: () => setState(() => _avatarKey = key),
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: avatarColorFromKey(palette, key),
                              shape: BoxShape.circle,
                              border: _avatarKey == key
                                  ? Border.all(color: palette.primary, width: 3)
                                  : Border.all(color: Colors.transparent),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _nameController,
              label: 'Child name',
              hint: 'e.g. Mia',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _ageController,
              label: 'Age',
              hint: ChildProfileRules.ageHint,
              helperText:
                  'Children aged ${ChildProfileRules.ageMin} to ${ChildProfileRules.ageMax}',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            _gradeSelector(theme, palette),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _aboutChildController,
              label: 'About child (optional)',
              hint: 'e.g. Loves painting and soccer',
              helperText: 'Anything you would like to remember about your child',
              maxLength: ChildProfileRules.aboutChildMaxLength,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _pinController,
              label: widget.child == null ? 'Child PIN (required)' : 'New child PIN (optional)',
              hint: widget.child == null ? '4-digit PIN' : 'Leave blank to keep the current PIN',
              prefixIcon: AppIcons.lock,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _securityQuestionsSection(theme, palette),
          ],
        ),
      ),
      actions: [
        SecondaryButton(
          label: 'Cancel',
          expanded: false,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 8),
        PrimaryButton(
          label: widget.child == null ? 'Add child' : 'Save',
          expanded: false,
          onPressed: _save,
        ),
      ],
    );
  }

  /// Constrained Grade 1 - 9 picker. A chip selector (not free text) so an
  /// out-of-range grade cannot be entered here at all.
  Widget _gradeSelector(ThemeData theme, AppPalette palette) {
    final String? error = ChildProfileRules.validateGrade(_grade);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Grade / class', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final String grade in ChildProfileRules.grades)
              ChoiceChip(
                label: Text(grade),
                selected: _grade == grade,
                onSelected: (_) => setState(() => _grade = grade),
                selectedColor: palette.primary,
                labelStyle: theme.textTheme.labelLarge?.copyWith(
                  color: _grade == grade ? Colors.white : palette.onSurface,
                ),
                showCheckmark: false,
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          error ?? ChildProfileRules.gradeHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: error != null ? theme.colorScheme.error : palette.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _securityQuestionsSection(ThemeData theme, AppPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PIN recovery questions (optional)', style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(
          'Set up at most ${ChildProfileRules.maxSecurityQuestions} questions so '
          '${widget.child?.name ?? 'your child'} can recover a forgotten PIN. '
          'Answers are stored securely and are never shown again.',
          style: theme.textTheme.bodySmall?.copyWith(color: palette.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        if (_loadingQuestions)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  'Loading saved questions...',
                  style: theme.textTheme.bodySmall?.copyWith(color: palette.onSurfaceVariant),
                ),
              ],
            ),
          ),
        for (int i = 0; i < _questions.length; i++) _questionRow(i, theme, palette),
      ],
    );
  }

  Widget _questionRow(int index, ThemeData theme, AppPalette palette) {
    final _QuestionDraft draft = _questions[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: draft.key,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Question ${index + 1}',
              border: const OutlineInputBorder(),
            ),
            hint: Text(
              'Choose a question',
              style: theme.textTheme.bodyMedium?.copyWith(color: palette.onSurfaceVariant),
            ),
            items: [
              for (final ChildSecurityQuestion question in ChildProfileRules.securityQuestions)
                DropdownMenuItem<String>(
                  value: question.key,
                  child: Text(question.question, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (String? value) => setState(() {
              // Changing the question invalidates the stored answer, so it has
              // to be typed again.
              if (value != draft.key) {
                draft.kept = false;
                draft.answerController.clear();
              }
              draft.key = value;
            }),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: draft.answerController,
            label: 'Answer ${index + 1}',
            hint: draft.kept
                ? 'Leave blank to keep the current answer'
                : 'The answer your child knows',
            obscureText: true,
          ),
        ],
      ),
    );
  }
}

/// One editable security-question row.
class _QuestionDraft {
  _QuestionDraft() : answerController = TextEditingController();

  final TextEditingController answerController;

  /// Selected question key, or null when the row is unused.
  String? key;

  /// True when the question was already stored, so a blank answer means
  /// "keep it" rather than "missing answer".
  bool kept = false;
}
