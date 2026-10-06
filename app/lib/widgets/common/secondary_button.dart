import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import 'app_icon.dart';

/// Outlined (secondary) button with an optional asset icon and a frosted
/// translucent fill so it stays readable on the animated world.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
    this.danger = false,
  });

  final String label;
  final String? icon;
  final VoidCallback? onPressed;
  final bool expanded;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color fg = danger ? scheme.error : scheme.primary;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: fg,
        minimumSize: Size(expanded ? double.infinity : 0, AppConstants.controlHeight),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        backgroundColor: fg.withValues(alpha: 0.06),
        side: BorderSide(color: danger ? scheme.error : scheme.primary.withValues(alpha: 0.35)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusButton),
        ),
        textStyle: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, color: fg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[AppIcon(icon!, size: 20, color: fg), const SizedBox(width: 10)],
          Text(label),
        ],
      ),
    );
  }
}
