import 'package:flutter/material.dart';

import 'app_icon.dart';

/// A destination for [AppBottomNav].
class AppNavItem {
  const AppNavItem({required this.label, required this.icon, this.selectedIcon});

  final String label;
  final String icon;
  final String? selectedIcon;
}

/// Bottom navigation bar using the custom icon set.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppNavItem> items;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: [
        for (final AppNavItem item in items)
          NavigationDestination(
            icon: AppIcon(item.icon, size: 24, color: scheme.onSurfaceVariant),
            selectedIcon: AppIcon(item.selectedIcon ?? item.icon, size: 24, color: scheme.primary),
            label: item.label,
          ),
      ],
    );
  }
}
