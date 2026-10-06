import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_exception.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/services/session_reset.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart' show AppMode;
import '../../models/child_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/child_avatar.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/responsive_content.dart';
import 'child_pin_recovery_screen.dart';

/// PIN entry screen for child login. Verifies the 4-digit PIN against the
/// backend, which then issues a child-scoped session token for the child zone.
class ChildPinScreen extends StatefulWidget {
  const ChildPinScreen({super.key, required this.child, this.repository});

  final ChildModel child;

  /// Overridable for tests; defaults to the live repository.
  final AuthRepository? repository;

  @override
  State<ChildPinScreen> createState() => _ChildPinScreenState();
}

class _ChildPinScreenState extends State<ChildPinScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  late final AuthRepository _repository;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? AuthRepository();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _pin => _controllers.map((c) => c.text).join();

  /// Opens the security-question recovery flow and clears the boxes on success
  /// so the new PIN can be typed straight away.
  Future<void> _recoverPin() async {
    final bool? recovered = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ChildPinRecoveryScreen(child: widget.child, repository: widget.repository),
      ),
    );

    if (recovered != true || !mounted) return;

    for (final TextEditingController controller in _controllers) {
      controller.clear();
    }
    setState(() {
      _error = null;
      _focusNodes.first.requestFocus();
    });
  }

  Future<void> _submit() async {
    final String pin = _pin;
    if (pin.length < 4) {
      setState(() => _error = 'Please enter your 4-digit PIN');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ChildModel loggedIn = await _repository.childLogin(childId: widget.child.id, pin: pin);

      if (!mounted) return;

      // Drop any previous account's cached data before the child session.
      resetSessionData(context);
      context.read<ChildProvider>().seedChild(loggedIn);
      context.read<AuthProvider>().setMode(AppMode.child);
      Navigator.of(context).pushReplacementNamed(AppRoutes.childShell);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.userMessage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Something went wrong. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.sch;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Enter PIN', style: theme.textTheme.titleLarge)),
      body: ResponsiveContent(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(flex: 2),
            ChildAvatar(
              name: widget.child.name,
              avatarKey: widget.child.avatarKey,
              size: 80,
              photoUrl: widget.child.photoUrl,
            ),
            const SizedBox(height: 16),
            Text(
              widget.child.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: 'Baloo2',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your 4-digit PIN',
              style: theme.textTheme.bodyMedium?.copyWith(color: palette.onSurfaceVariant),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                return Container(
                  width: 56,
                  height: 64,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: (event) {
                      if (event is KeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.backspace &&
                          _controllers[i].text.isEmpty &&
                          i > 0) {
                        _controllers[i - 1].clear();
                        _focusNodes[i - 1].requestFocus();
                      }
                    },
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: palette.surfaceContainer,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: _error != null
                                ? theme.colorScheme.error
                                : palette.outlineVariant,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: palette.primary, width: 2),
                        ),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        if (value.isNotEmpty && i < 3) {
                          _focusNodes[i + 1].requestFocus();
                        }
                        if (value.isEmpty && i > 0) {
                          _focusNodes[i - 1].requestFocus();
                        }
                        if (_pin.length == 4) {
                          _submit();
                        }
                      },
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _error!,
                  style: TextStyle(color: theme.colorScheme.error, fontSize: 14),
                ),
              ),
            const Spacer(flex: 2),
            PrimaryButton(
              label: _loading ? 'Verifying...' : 'Continue',
              onPressed: _loading ? null : _submit,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loading ? null : _recoverPin,
              child: const Text('Forgot your PIN?'),
            ),
          ],
        ),
      ),
    );
  }
}
