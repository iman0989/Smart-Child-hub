import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_icons.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import 'reset_password_screen.dart';
import '../../widgets/common/auth_scaffold.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/primary_button.dart';

/// Forgot-password entry: requests the reset code and then moves to the
/// reset screen so the parent can set a new password.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final AuthProvider auth = context.read<AuthProvider>();
    final String email = _emailController.text.trim();

    // Request the reset token (dev flow: backend returns it in the body).
    final String? token = await auth.requestResetToken(email: email);
    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // Token is available — go straight to the reset screen.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: email, token: token),
        ),
      );
      return;
    }

    // Fallback: navigate to the reset screen and let the parent enter the code.
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => ResetPasswordScreen(email: email)));
  }

  @override
  Widget build(BuildContext context) {
    final bool loading = context.watch<AuthProvider>().isLoading;

    return AuthScaffold(
      title: 'Forgot password?',
      subtitle: 'Enter your email and we will send you a reset link',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _emailController,
                label: 'Email address',
                prefixIcon: AppIcons.mail,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                validator: Validators.email,
                onFieldSubmitted: (_) => _submit(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Send reset link',
                icon: AppIcons.send,
                loading: loading,
                onPressed: loading ? null : _submit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
