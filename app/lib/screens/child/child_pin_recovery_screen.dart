import 'package:flutter/material.dart';

import '../../core/constants/child_profile_rules.dart';
import '../../core/network/api_exception.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../models/child_model.dart';
import '../../widgets/common/child_avatar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/responsive_content.dart';
import 'child_pin_reset_screen.dart';

/// Child PIN recovery: identify the child, answer the security questions the
/// parent configured, then hand a single-use token to the reset screen.
///
/// The existing PIN is never shown or hinted at - a forgotten PIN can only be
/// replaced, never read back.
class ChildPinRecoveryScreen extends StatefulWidget {
  const ChildPinRecoveryScreen({super.key, required this.child, this.repository});

  final ChildModel child;

  /// Overridable for tests; defaults to the live repository.
  final AuthRepository? repository;

  @override
  State<ChildPinRecoveryScreen> createState() => _ChildPinRecoveryScreenState();
}

class _ChildPinRecoveryScreenState extends State<ChildPinRecoveryScreen> {
  late final AuthRepository _repository;

  late final TextEditingController _nameController;
  final Map<String, TextEditingController> _answerControllers = <String, TextEditingController>{};

  bool _loadingQuestions = false;
  bool _verifying = false;
  String? _error;

  /// Question keys, once the server has confirmed the child.
  List<String> _questionKeys = const <String>[];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? AuthRepository();
    _nameController = TextEditingController(text: widget.child.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final TextEditingController controller in _answerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showError(String message) => setState(() => _error = message);

  /// Step 1: fetch the questions configured for this child.
  Future<void> _loadQuestions() async {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Please enter the child\'s name.');
      return;
    }

    setState(() {
      _loadingQuestions = true;
      _error = null;
    });

    try {
      final ChildRecoveryChallenge challenge = await _repository.childRecoveryQuestions(
        childId: widget.child.id,
        name: name,
      );

      if (!mounted) return;
      setState(() {
        _questionKeys = challenge.questions;
        for (final String key in challenge.questions) {
          _answerControllers.putIfAbsent(key, TextEditingController.new);
        }
        _loadingQuestions = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loadingQuestions = false;
          _error = e.userMessage;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingQuestions = false;
          _error = 'Something went wrong. Please try again.';
        });
      }
    }
  }

  /// Step 2: check the answers and move on to choosing a new PIN.
  Future<void> _submitAnswers() async {
    final String name = _nameController.text.trim();

    final Map<String, String> answers = <String, String>{};
    for (final String key in _questionKeys) {
      final String answer = _answerControllers[key]?.text.trim() ?? '';
      if (answer.isEmpty) {
        _showError('Please answer every security question.');
        return;
      }
      if (answer.length < ChildProfileRules.minAnswerLength) {
        _showError('Each answer must be at least ${ChildProfileRules.minAnswerLength} characters.');
        return;
      }
      answers[key] = answer;
    }

    setState(() {
      _verifying = true;
      _error = null;
    });

    try {
      final ChildRecoveryGrant grant = await _repository.verifyChildRecovery(
        childId: widget.child.id,
        name: name,
        answers: answers,
      );

      if (!mounted) return;
      setState(() => _verifying = false);

      final bool? reset = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => ChildPinResetScreen(
            child: widget.child,
            recoveryToken: grant.recoveryToken,
            repository: widget.repository,
          ),
        ),
      );

      if (!mounted) return;

      // The PIN was changed: hand control back to the PIN screen so the new
      // PIN can be typed straight away.
      if (reset == true) {
        Navigator.of(context).pop(true);
        return;
      }

      // The questions were used up: clear them so a retry starts from the name.
      setState(() {
        _questionKeys = const <String>[];
        for (final TextEditingController controller in _answerControllers.values) {
          controller.clear();
        }
        _answerControllers.clear();
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _verifying = false;
          _error = e.userMessage;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _verifying = false;
          _error = 'Something went wrong. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppPalette palette = context.sch;
    final bool askingQuestions = _questionKeys.isEmpty;

    return Scaffold(
      appBar: AppBar(title: Text('Recover PIN', style: theme.textTheme.titleLarge)),
      body: ResponsiveContent(
        padding: const EdgeInsets.all(24),
        child: _ScrollableBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Center(
                child: ChildAvatar(
                  name: widget.child.name,
                  avatarKey: widget.child.avatarKey,
                  photoUrl: widget.child.photoUrl,
                  size: 72,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                askingQuestions ? 'Who needs help?' : 'Answer your security questions',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Baloo2',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                askingQuestions
                    ? 'Ask a grown-up for your full name. We will show the questions a parent set up for you.'
                    : 'Your grown-up set these up for you. Ask them if you cannot remember.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: palette.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _nameController,
                label: 'Child name',
                hint: 'Enter the full name',
                enabled: askingQuestions,
                onChanged: (_) => setState(() => _error = null),
              ),
              if (!askingQuestions) ...[
                const SizedBox(height: 16),
                for (final String key in _questionKeys) ...[
                  CustomTextField(
                    controller: _answerControllers[key]!,
                    label: ChildProfileRules.questionText(key),
                    hint: 'Type the answer',
                    obscureText: true,
                    onChanged: (_) => setState(() => _error = null),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_error!, style: TextStyle(color: theme.colorScheme.onErrorContainer)),
                ),
              ],
              const Spacer(flex: 3),
              PrimaryButton(
                label: askingQuestions
                    ? (_loadingQuestions ? 'Checking...' : 'Show my questions')
                    : (_verifying ? 'Checking answers...' : 'Continue'),
                loading: _loadingQuestions || _verifying,
                onPressed: askingQuestions
                    ? (_loadingQuestions ? null : _loadQuestions)
                    : (_verifying ? null : _submitAnswers),
              ),
              if (!askingQuestions) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _loadingQuestions || _verifying
                      ? null
                      : () => setState(() {
                          _questionKeys = const <String>[];
                          _error = null;
                        }),
                  child: const Text('Start over'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Keeps the form usable on short screens while still spreading the content
/// out on tall ones, so [Spacer] children keep working.
class _ScrollableBody extends StatelessWidget {
  const _ScrollableBody({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(child: child),
          ),
        );
      },
    );
  }
}
