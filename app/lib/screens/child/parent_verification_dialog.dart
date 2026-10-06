import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_icons.dart';
import '../../core/network/api_exception.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../models/child_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/child_avatar.dart';
import '../../widgets/common/password_field.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';

/// Gate for leaving the child zone.
///
/// The child session token is not enough to reach the parent zone, so this
/// dialog re-authenticates the parent account. The credentials are only used
/// to verify the password against the API — the active session token is left
/// untouched, so returning to the parent zone continues on the existing
/// parent session instead of swapping in a new one.
class ParentVerificationDialog extends StatefulWidget {
  const ParentVerificationDialog({super.key});

  /// Shows the dialog and resolves to `true` when the parent was verified.
  static Future<bool> show(BuildContext context) async {
    final bool? verified = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ParentVerificationDialog(),
    );
    return verified ?? false;
  }

  @override
  State<ParentVerificationDialog> createState() => _ParentVerificationDialogState();
}

class _ParentVerificationDialogState extends State<ParentVerificationDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final AuthRepository _repository = AuthRepository();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final String password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _error = 'Enter the parent password to continue.');
      return;
    }

    final String? email = context.read<AuthProvider>().user?.email;
    if (email == null || email.isEmpty) {
      Navigator.of(context).pop(false);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _repository.login(email: email, password: password);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.userMessage;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppPalette palette = context.sch;
    final String? email = context.watch<AuthProvider>().user?.email;
    final ChildModel? child = context.watch<ChildProvider>().selectedChild;

    return AlertDialog(
      title: const Text('Parent zone'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ChildAvatar(
                  name: child?.name ?? 'Explorer',
                  avatarKey: child?.avatarKey ?? 'sunshine',
                  photoUrl: child?.photoUrl ?? '',
                  size: 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'A parent password is needed to leave the kids zone.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: palette.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (email != null && email.isNotEmpty)
              Row(
                children: [
                  const AppIcon(AppIcons.person, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: palette.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            if (email != null && email.isNotEmpty) const SizedBox(height: 12),
            PasswordField(
              controller: _passwordController,
              label: 'Parent password',
              hint: 'Enter the parent password',
              textInputAction: TextInputAction.go,
              autofillHints: const <String>[AutofillHints.password],
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              onFieldSubmitted: (_) => _verify(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, size: 18, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        SecondaryButton(
          label: 'Stay here',
          expanded: false,
          onPressed: _loading ? null : () => Navigator.of(context).pop(false),
        ),
        const SizedBox(width: 8),
        PrimaryButton(
          label: _loading ? 'Checking…' : 'Unlock',
          expanded: false,
          onPressed: _loading ? null : _verify,
        ),
      ],
    );
  }
}
