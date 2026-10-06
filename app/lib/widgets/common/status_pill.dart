import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'app_icon.dart';

/// Colour + icon + label status pill (task / record status).
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.outlined = false,
  });

  final String label;
  final Color color;
  final String? icon;
  final Color? backgroundColor;

  /// Overrides the readable-accent foreground. Needed when the pill is seated
  /// on a mid-tone container (a brand-gradient hero) where the accent itself
  /// cannot carry the label.
  final Color? foregroundColor;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    // A 15% tint of the accent is too close to the accent itself once the
    // accent is a dark-palette tone, so dark mode seats the label on a neutral
    // dark container instead. Light mode keeps its original tinted pill.
    final Color bg =
        backgroundColor ??
        (dark ? theme.colorScheme.surfaceContainerHigh : color.withValues(alpha: 0.15));
    // The label and icon ride on that tint, so the accent is only used as a
    // hue here; the readable variant carries the text.
    final Color fg = foregroundColor ?? onTintAccent(color, theme.brightness);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : bg,
        borderRadius: BorderRadius.circular(999),
        border: outlined ? Border.all(color: color.withValues(alpha: 0.5)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[AppIcon(icon!, size: 14, color: fg), const SizedBox(width: 5)],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
