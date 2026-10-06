import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_icons.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/auth_scaffold.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/password_field.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/error_state_widget.dart' show showAppSnackBar;

/// Password reset: enter the reset token (shown in the forgot-password
/// response for dev) plus a new password.
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key, required this.email, this.token});

  final String email;
  final String? token;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController tokenController = TextEditingController(text: token ?? '');
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();
    String? error;

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      FocusScope.of(context).unfocus();

      final AuthProvider auth = context.read<AuthProvider>();
      final bool ok = await auth.completePasswordReset(
        email: email,
        token: tokenController.text.trim(),
        password: passwordController.text,
      );
      if (!context.mounted) return;
      if (ok) {
        showAppSnackBar(context, 'Password reset. You can log in now.');
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      } else {
        error = auth.error;
      }
    }

    return StatefulBuilder(
      builder: (context, setState) => AuthScaffold(
        title: 'Reset password',
        subtitle: 'Enter the reset code and a new password for $email',
        children: [
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: tokenController,
                  label: 'Reset code',
                  hint: '6-digit code from the email',
                  prefixIcon: AppIcons.shield,
                  textInputAction: TextInputAction.next,
                  validator: (final v) =>
                      v == null || v.trim().isEmpty ? 'Enter the reset code' : null,
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: passwordController,
                  label: 'New password',
                  hint: 'At least 6 characters',
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: confirmController,
                  label: 'Confirm password',
                  hint: 'Repeat your password',
                  validator: (value) => Validators.confirmPassword(value, passwordController.text),
                ),
                if (error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    ),
                    child: Text(
                      error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Reset password',
                  icon: AppIcons.sparkle,
                  loading: context.watch<AuthProvider>().isLoading,
                  onPressed: submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
