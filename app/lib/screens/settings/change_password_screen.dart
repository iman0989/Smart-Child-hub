import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_icons.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/error_state_widget.dart' show showAppError, showAppSnackBar;
import '../../widgets/common/password_field.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/world_screen.dart';

/// Parent change-password screen.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final bool ok = await context.read<AuthProvider>().changePassword(
      currentPassword: _currentController.text,
      newPassword: _newController.text,
    );
    if (!mounted) return;

    if (ok) {
      showAppSnackBar(context, 'Password updated');
      Navigator.of(context).pop();
    } else {
      showAppError(context, context.read<AuthProvider>().error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool loading = context.watch<AuthProvider>().isLoading;

    return WorldScreen(
      title: 'Change Password',
      subtitle: 'Keep your account secure',
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            PasswordField(
              controller: _currentController,
              label: 'Current password',
              hint: 'Enter your current password',
              validator: Validators.required,
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _newController,
              label: 'New password',
              hint: 'At least 6 characters',
              validator: Validators.password,
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _confirmController,
              label: 'Confirm new password',
              hint: 'Repeat your new password',
              validator: (value) => Validators.confirmPassword(value, _newController.text),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Update password',
              icon: AppIcons.shield,
              loading: loading,
              onPressed: loading ? null : _submit,
            ),
            const SizedBox(height: 8),
            Text(
              'After changing your password, other sessions will be signed '
              'out automatically.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
