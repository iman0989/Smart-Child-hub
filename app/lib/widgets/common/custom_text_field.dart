import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_icons.dart';
import 'app_icon.dart';

/// Reusable text field styled with the app input theme.
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.onFieldSubmitted,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;

  /// Small note under the field, e.g. the accepted range.
  final String? helperText;

  /// Icon name from [AppIcons].
  final String? prefixIcon;
  final Widget? suffix;
  final bool obscureText;

  /// When false the field is read-only and rendered greyed out.
  final bool enabled;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onFieldSubmitted;

  /// Platform autofill hints, e.g. [AutofillHints.username].
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        prefixIcon: prefixIcon == null
            ? null
            : Padding(
                padding: const EdgeInsets.all(14),
                child: AppIcon(
                  prefixIcon!,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
        suffixIcon: suffix,
      ),
    );
  }
}
