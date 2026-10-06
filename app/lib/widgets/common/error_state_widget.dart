import 'package:flutter/material.dart';

import '../../core/constants/app_icons.dart';
import '../../core/network/api_exception.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/formatters.dart';
import 'app_illustration.dart';
import 'app_icon.dart';
import 'secondary_button.dart';

/// Error state with an optional retry action.
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({super.key, required this.message, this.onRetry, this.compact = false});

  final String message;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIllustration(IllustrationAssets.errorState, width: compact ? 110 : 160),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: 180,
                child: SecondaryButton(
                  label: 'Try again',
                  icon: AppIcons.chevRight,
                  expanded: false,
                  onPressed: onRetry,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Snackbar helper.
void showAppSnackBar(BuildContext context, String message, {bool error = false}) {
  final ThemeData theme = Theme.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            AppIcon(error ? AppIcons.cross : AppIcons.check, size: 18, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: error ? theme.colorScheme.error : const Color(0xFF2FAE66),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
}

/// Shows a friendly snackbar for any thrown error (network, timeout,
/// auth, validation). Use in `catch` blocks around async provider calls.
/// Also handles plain String error messages from providers.
void showAppError(BuildContext context, Object? error) {
  final String message = switch (error) {
    ApiException e => e.userMessage,
    AuthException e => e.message,
    String s => s.isNotEmpty ? s : 'Something went wrong. Please try again.',
    _ => 'Something went wrong. Please try again.',
  };
  showAppSnackBar(context, message, error: true);
}

/// Confirmation dialog helper returning `true` when confirmed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool danger = false,
}) async {
  final ThemeData theme = Theme.of(context);
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, style: theme.textTheme.titleLarge),
      content: Text(message, style: theme.textTheme.bodyMedium),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(cancelLabel)),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: danger ? theme.colorScheme.error : theme.colorScheme.primary,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Small info dialog.
Future<void> showInfoDialog(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, style: Theme.of(context).textTheme.titleLarge),
      content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
    ),
  );
}

/// Timestamp-aware date formatting helper re-export for convenience.
String formatTimestamp(DateTime t) => Formatters.timeAgo(t);
