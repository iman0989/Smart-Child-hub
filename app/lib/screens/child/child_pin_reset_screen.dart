import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_icons.dart';
import '../../core/network/api_exception.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../models/child_model.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/responsive_content.dart';

/// Final recovery step: choose and confirm a new 4-digit PIN.
///
/// The [recoveryToken] was issued by the security-question step and is bound to
/// this one child, so the reset cannot land on another profile.
class ChildPinResetScreen extends StatefulWidget {
  const ChildPinResetScreen({
    super.key,
    required this.child,
    required this.recoveryToken,
    this.repository,
  });

  final ChildModel child;
  final String recoveryToken;

  /// Overridable for tests; defaults to the live repository.
  final AuthRepository? repository;

  @override
  State<ChildPinResetScreen> createState() => _ChildPinResetScreenState();
}

class _ChildPinResetScreenState extends State<ChildPinResetScreen> {
  static final RegExp _pinPattern = RegExp(r'^\d{4}$');

  late final AuthRepository _repository;
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? AuthRepository();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String pin = _pinController.text.trim();
    final String confirmation = _confirmController.text.trim();

    final String? error = _validate(pin, confirmation);
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ChildRecoveryResult result = await _repository.resetChildPin(
        recoveryToken: widget.recoveryToken,
        newPin: pin,
        newPinConfirmation: confirmation,
      );

      if (!mounted) return;

      // Stop the spinner before the dialog appears, otherwise the button would
      // keep animating behind it.
      setState(() => _loading = false);

      final String name = result.name.isNotEmpty ? result.name : widget.child.name;
      await showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('New PIN saved'),
          content: Text(
            '$name can now use the new PIN to sign in. Keep it safe and do not '
            'share it with anyone.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('OK')),
          ],
        ),
      );

      if (!mounted) return;
      // Back to the PIN screen, which now holds the new PIN.
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.userMessage;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Something went wrong. Please try again.';
        });
      }
    }
  }

  String? _validate(String pin, String confirmation) {
    if (pin.isEmpty) return 'Please enter a new PIN.';
    if (!_pinPattern.hasMatch(pin)) return 'The PIN must be exactly 4 digits.';
    if (confirmation.isEmpty) return 'Please confirm the new PIN.';
    if (pin != confirmation) return 'The two PINs do not match.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppPalette palette = context.sch;

    return Scaffold(
      appBar: AppBar(title: Text('Choose a new PIN', style: theme.textTheme.titleLarge)),
      body: ResponsiveContent(
        padding: const EdgeInsets.all(24),
        child: _ScrollableBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Text(
                'New 4-digit PIN',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Baloo2',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick four numbers you will remember, and do not show them to anyone.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: palette.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _pinController,
                label: 'New PIN',
                hint: '4 digits',
                prefixIcon: AppIcons.lock,
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() => _error = null),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _confirmController,
                label: 'Confirm new PIN',
                hint: 'Type the same four digits',
                prefixIcon: AppIcons.lock,
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() => _error = null),
              ),
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
                label: _loading ? 'Saving...' : 'Save new PIN',
                loading: _loading,
                onPressed: _loading ? null : _submit,
              ),
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
