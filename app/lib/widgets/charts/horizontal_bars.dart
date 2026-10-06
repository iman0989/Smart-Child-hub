import 'package:flutter/material.dart';

import '../common/linear_progress_widget.dart';

/// Horizontal category bars built from linear progress widgets.
class HorizontalBars extends StatelessWidget {
  const HorizontalBars({super.key, required this.items});

  /// Each item is (label, value 0-1, color, optional detail text).
  final List<(String, double, Color, String)> items;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: [
        for (int i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(items[i].$1, style: theme.textTheme.bodyMedium)),
                    Text(
                      items[i].$4,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressWidget(value: items[i].$2, height: 10, color: items[i].$3),
              ],
            ),
          ),
      ],
    );
  }
}
