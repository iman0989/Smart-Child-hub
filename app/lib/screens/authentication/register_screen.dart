import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_icons.dart';
import '../../core/services/session_reset.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/auth_scaffold.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/password_field.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/error_state_widget.dart' show showAppSnackBar;

/// Registration with local validation (dummy backend).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final AuthProvider auth = context.read<AuthProvider>();
    final bool ok = await auth.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;

    if (ok) {
      resetSessionData(context);
      showAppSnackBar(context, 'Account created. Welcome aboard!');
      Navigator.of(context).pushReplacementNamed(AppRoutes.parentShell);
    } else {
      setState(() => _error = auth.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool loading = context.watch<AuthProvider>().isLoading;

    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Join Smart Child Hub as a Family Manager',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Full name',
                prefixIcon: AppIcons.person,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: Validators.name,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                label: 'Email address',
                prefixIcon: AppIcons.mail,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone (optional)',
                prefixIcon: AppIcons.message,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: Validators.phone,
              ),
              const SizedBox(height: 16),
              PasswordField(
                controller: _passwordController,
                label: 'Password',
                hint: 'At least 6 characters',
                validator: Validators.password,
              ),
              const SizedBox(height: 16),
              PasswordField(
                controller: _confirmController,
                label: 'Confirm password',
                hint: 'Repeat your password',
                validator: (value) => Validators.confirmPassword(value, _passwordController.text),
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
                label: 'Create account',
                icon: AppIcons.sparkle,
                loading: loading,
                onPressed: loading ? null : _submit,
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Already have an account?'),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Sign in')),
          ],
        ),
      ],
    );
  }
}
