import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/child_model.dart';
import '../../providers/child_provider.dart';
import '../../widgets/common/error_state_widget.dart' show showAppError, showAppSnackBar;
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';

/// Dialog for changing a child's 4-digit PIN.
class PinChangeDialog extends StatefulWidget {
  const PinChangeDialog({super.key, required this.child});

  final ChildModel child;

  @override
  State<PinChangeDialog> createState() => _PinChangeDialogState();
}

class _PinChangeDialogState extends State<PinChangeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _currentPinController;
  late final TextEditingController _newPinController;
  late final TextEditingController _confirmPinController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _currentPinController = TextEditingController();
    _newPinController = TextEditingController();
    _confirmPinController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final bool success = await context.read<ChildProvider>().changePin(
      childId: widget.child.id,
      currentPin: _currentPinController.text.trim(),
      newPin: _newPinController.text.trim(),
      newPinConfirmation: _confirmPinController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _loading = false);

    if (success) {
      Navigator.of(context).pop();
      showAppSnackBar(context, 'PIN updated successfully!');
    } else {
      showAppError(context, context.read<ChildProvider>().error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPin = widget.child.hasPin;

    return AlertDialog(
      title: const Text('Change PIN'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasPin) ...[
                TextFormField(
                  controller: _currentPinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Current PIN',
                    counterText: '',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.length != 4) {
                      return 'Enter your current 4-digit PIN';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
              ],
              TextFormField(
                controller: _newPinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'New PIN',
                  counterText: '',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.length != 4) {
                    return 'PIN must be exactly 4 digits';
                  }
                  if (!RegExp(r'^\d{4}$').hasMatch(value)) {
                    return 'PIN must contain only numbers';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmPinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Confirm New PIN',
                  counterText: '',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value != _newPinController.text) {
                    return 'PINs do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
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
          label: _loading ? 'Saving...' : 'Save PIN',
          expanded: false,
          onPressed: _loading ? null : _save,
        ),
      ],
    );
  }
}
