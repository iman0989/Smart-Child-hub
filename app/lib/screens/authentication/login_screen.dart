import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_icons.dart';
import '../../core/services/session_reset.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/animated_background.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/error_state_widget.dart' show showAppSnackBar;
import '../../widgets/common/motion.dart';
import '../../widgets/common/password_field.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';
import 'login_brand_panel.dart';

/// Parent sign-in.
///
/// Layout is a 55/45 split on expanded widths — brand panel on the left, form
/// on the right — and collapses to a compact brand banner above the form on
/// phones and tablets. Authentication behaviour is unchanged: the form still
/// calls [AuthProvider.login] and routes to the parent shell on success.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  bool _rememberMe = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final AuthProvider auth = context.read<AuthProvider>();
    final bool ok = await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;

    if (ok) {
      resetSessionData(context);
      if (_rememberMe) {
        showAppSnackBar(context, 'Welcome back, ${auth.user?.fullName}!');
      }
      Navigator.of(context).pushReplacementNamed(AppRoutes.parentShell);
    } else {
      setState(() => _error = auth.error);
    }
  }

  void _openCreateAccount() => Navigator.of(context).pushNamed(AppRoutes.register);

  void _openKidsMode() => Navigator.of(context).pushNamed(AppRoutes.chooseProfile);

  void _notAvailableYet(String provider) {
    showAppSnackBar(
      context,
      'Signing in with $provider is coming soon. '
      'Please use your email and password.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool split = Responsive.isExpanded(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: AnimatedBackground()),
          SafeArea(child: split ? _buildSplit(context) : _buildStacked(context)),
        ],
      ),
    );
  }

  /// Desktop / expanded: 55% artwork panel, 45% form column.
  Widget _buildSplit(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Expanded(flex: 55, child: LoginBrandPanel()),
        Expanded(
          flex: 45,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surface
                  : kLoginPanelLight,
            ),
            child: SafeArea(
              left: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceSection,
                  vertical: AppConstants.spaceXl,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppConstants.authMaxWidth),
                    child: _FormColumn(child: _buildForm(context)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Compact: banner above a single scrolling form column.
  Widget _buildStacked(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const LoginCompactBanner(),
              const SizedBox(height: AppConstants.spaceXl),
              _FormColumn(framed: true, showBrandHeader: false, child: _buildForm(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CustomTextField(
              controller: _emailController,
              label: 'Email address',
              prefixIcon: AppIcons.mail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.email,
              autofillHints: const <String>[AutofillHints.username],
            ),
            const SizedBox(height: AppConstants.spaceLg),
            PasswordField(
              controller: _passwordController,
              hint: 'Enter your password',
              textInputAction: TextInputAction.done,
              validator: Validators.required,
              autofillHints: const <String>[AutofillHints.password],
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            _RememberMeRow(
              value: _rememberMe,
              onChanged: (bool next) => setState(() => _rememberMe = next),
            ),
            _ErrorBanner(message: _error),
            PrimaryButton(
              label: 'Sign in',
              icon: AppIcons.lock,
              gradient: kLoginCtaGradient,
              height: kLoginCtaHeight,
              // The design's button is a saturated blue/violet fill, so the
              // label stays white in both brightness modes (dark mode's default
              // onPrimary is a dark navy and would drop below 4.5:1 here).
              foregroundColor: Colors.white,
              loading: context.watch<AuthProvider>().isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: AppConstants.spaceLg),
            const _OrDivider(),
            const SizedBox(height: AppConstants.spaceLg),
            _SocialButtons(
              onGoogle: () => _notAvailableYet('Google'),
              onApple: () => _notAvailableYet('Apple'),
            ),
            const SizedBox(height: AppConstants.spaceLg),
            SecondaryButton(label: 'Kids mode', icon: AppIcons.child, onPressed: _openKidsMode),
            const SizedBox(height: AppConstants.spaceSm),
            TextButton.icon(
              onPressed: _openCreateAccount,
              icon: const AppIcon(AppIcons.person, size: 18),
              label: const Text('Create a parent account'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Seats the form: on desktop it sits directly on the flat near-white panel,
/// on compact widths it is framed by a rounded plate so the inputs stay
/// readable over the animated world.
class _FormColumn extends StatelessWidget {
  const _FormColumn({required this.child, this.framed = false, this.showBrandHeader = true});

  final Widget child;
  final bool framed;
  final bool showBrandHeader;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Widget column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (showBrandHeader)
          const LoginFormHeader()
        else ...<Widget>[
          Semantics(
            header: true,
            child: Text(
              'Sign in to your account',
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: 'Baloo2',
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            'Use the email address linked to your family account.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppConstants.spaceLg),
        ],
        child,
      ],
    );

    return Entrance(
      delay: const Duration(milliseconds: 120),
      child: framed
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: dark ? theme.colorScheme.surface : kLoginPanelLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                border: Border.all(
                  color: dark ? theme.colorScheme.outlineVariant : kLoginBorderLight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.cardPadding),
                child: column,
              ),
            )
          : column,
    );
  }
}

class _RememberMeRow extends StatelessWidget {
  const _RememberMeRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppPalette palette = context.sch;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppConstants.spaceSm,
      runSpacing: AppConstants.spaceXs,
      children: <Widget>[
        Semantics(
          toggled: value,
          label: 'Remember me',
          child: InkWell(
            onTap: () => onChanged(!value),
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: value ? palette.primary : Colors.transparent,
                      border: Border.all(
                        color: value ? palette.primary : palette.outlineVariant,
                        width: 2,
                      ),
                    ),
                    child: value ? Icon(Icons.check, size: 15, color: palette.onPrimary) : null,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'Remember me',
                      style: theme.textTheme.bodyMedium?.copyWith(color: palette.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
          child: const Text('Forgot password?'),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final String? text = message;
    if (text == null || text.isEmpty) return const SizedBox.shrink();

    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceLg),
      child: Semantics(
        liveRegion: true,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(AppConstants.radiusInput),
            border: Border.all(color: theme.colorScheme.error, width: 1.2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.error_outline, size: 20, color: theme.colorScheme.onErrorContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color line = theme.colorScheme.outlineVariant;

    return Semantics(
      label: 'or sign in with',
      child: Row(
        children: <Widget>[
          Expanded(child: Divider(color: line)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'or',
              style: theme.textTheme.bodySmall?.copyWith(color: context.sch.onSurfaceVariant),
            ),
          ),
          Expanded(child: Divider(color: line)),
        ],
      ),
    );
  }
}

class _SocialButtons extends StatelessWidget {
  const _SocialButtons({required this.onGoogle, required this.onApple});

  final VoidCallback onGoogle;
  final VoidCallback onApple;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Row(
      children: <Widget>[
        Expanded(
          child: _SocialButton(
            label: 'Google',
            icon: Icons.g_translate,
            foreground: scheme.onSurface,
            onPressed: onGoogle,
          ),
        ),
        const SizedBox(width: AppConstants.spaceMd),
        Expanded(
          child: _SocialButton(
            label: 'Apple',
            icon: Icons.apple,
            foreground: scheme.onSurface,
            onPressed: onApple,
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: foreground),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: foreground,
        minimumSize: const Size(0, AppConstants.controlHeight),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        backgroundColor: foreground.withValues(alpha: 0.06),
        side: BorderSide(color: foreground.withValues(alpha: 0.28)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusButton),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
