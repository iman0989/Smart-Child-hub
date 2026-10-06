import 'package:flutter/material.dart';

import '../../core/constants/app_icons.dart';
import 'app_illustration.dart';

/// Friendly empty state for lists with no content.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.action,
    this.illustration = IllustrationAssets.emptyTasks,
    this.compact = false,
  });

  final String title;
  final String message;
  final Widget? action;
  final String illustration;
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
            AppIllustration(illustration, width: compact ? 120 : 180),
            const SizedBox(height: 20),
            Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}
