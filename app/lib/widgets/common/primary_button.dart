import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_icons.dart';
import 'app_icon.dart';

/// Primary gradient CTA with a soft glow, rounded corners, an optional asset
/// icon, loading state and a subtle press animation.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.expanded = true,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.height = AppConstants.controlHeight,
  });

  final String label;

  /// Optional icon name from [AppIcons].
  final String? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expanded;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Gradient? gradient;
  final double height;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  Gradient _resolveGradient(BuildContext context) {
    if (widget.gradient != null) return widget.gradient!;
    final Color base = widget.backgroundColor ?? Theme.of(context).colorScheme.primary;
    // Deepens towards the bottom edge only. Lightening the top stop made the
    // 14px label sit on a wash that `onPrimary` could not clear 4.5:1 against.
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [base, Color.lerp(base, Colors.black, 0.12)!],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color fg = widget.foregroundColor ?? Theme.of(context).colorScheme.onPrimary;
    final Gradient gradient = _resolveGradient(context);
    final bool enabled = widget.onPressed != null && !widget.loading;
    final BorderRadius radius = BorderRadius.circular(AppConstants.radiusButton);

    final Widget body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Center(
        child: widget.loading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    AppIcon(widget.icon!, size: 20, color: fg),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );

    return AnimatedScale(
      scale: _pressed ? 0.975 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        child: Listener(
          onPointerDown: enabled ? (event) => setState(() => _pressed = true) : null,
          onPointerUp: enabled ? (event) => setState(() => _pressed = false) : null,
          onPointerCancel: enabled ? (event) => setState(() => _pressed = false) : null,
          child: ElevatedButton(
            onPressed: widget.loading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: fg,
              disabledBackgroundColor: Colors.transparent,
              disabledForegroundColor: fg.withValues(alpha: 0.7),
              elevation: 0,
              shadowColor: Colors.transparent,
              minimumSize: Size(widget.expanded ? double.infinity : 0, widget.height),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: radius),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
            child: Ink(
              height: widget.height,
              decoration: BoxDecoration(
                gradient: enabled ? gradient : gradient.withOpacity(0.55),
                borderRadius: radius,
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: gradient.colors.first.withValues(alpha: 0.38),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : const [],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: KeyedSubtree(key: ValueKey<bool>(widget.loading), child: body),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
