import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_icons.dart';
import '../../core/theme/app_gradients.dart';
import '../../providers/auth_provider.dart';
import 'animated_background.dart';
import 'app_icon.dart';
import 'app_illustration.dart';
import 'glass_card.dart';

/// A single destination in the app shell navigation.
class NavDest {
  const NavDest({
    required this.label,
    required this.icon,
    this.activeIcon,
    this.color = const Color(0xFF4359E0),
  });

  final String label;
  final String icon;
  final String? activeIcon;
  final Color color;
}

/// Responsive application shell.
///
/// Renders the animated world behind everything, a frosted-glass **sidebar**
/// on wide screens (≥ [desktopBreakpoint]) and a floating glass **bottom
/// navigation bar** on compact screens. Tab switches cross-fade + slide.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.destinations,
    required this.builder,
    this.initialIndex = 0,
    this.index,
    this.onIndexChanged,
    this.desktopBreakpoint = 860,
    this.footerLabel,
    this.headerNote = 'Your family’s smart hub',
    this.onAccountTap,
  });

  final List<NavDest> destinations;
  final Widget Function(BuildContext context, int index) builder;

  /// Starting tab when [index] is not used to drive the shell.
  final int initialIndex;

  /// When non-null the shell becomes a controlled component: the parent owns
  /// the selected tab and can jump to it (e.g. tapping the avatar to open the
  /// profile tab).
  final int? index;
  final ValueChanged<int>? onIndexChanged;

  final double desktopBreakpoint;
  final String? footerLabel;
  final String headerNote;

  /// Opens the account/profile screen. Hidden when null.
  final VoidCallback? onAccountTap;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.index ?? widget.initialIndex;

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int? next = widget.index;
    if (next != null && next != _index) {
      setState(() => _index = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= widget.desktopBreakpoint;

    return Scaffold(
      body: AnimatedBackground(
        child: Theme(
          data: Theme.of(context).copyWith(
            scaffoldBackgroundColor: Colors.transparent,
            appBarTheme: Theme.of(context).appBarTheme.copyWith(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
          ),
          child: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (wide) {
                  return Row(
                    children: [
                      _Sidebar(
                        destinations: widget.destinations,
                        index: _index,
                        headerNote: widget.headerNote,
                        footerLabel: widget.footerLabel,
                        onAccountTap: widget.onAccountTap,
                        onSelect: (index) => _goTo(index),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _page()),
                    ],
                  );
                }
                return Column(
                  children: [
                    Expanded(child: _page()),
                    _BottomNav(
                      destinations: widget.destinations,
                      index: _index,
                      onSelect: (index) => _goTo(index),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _goTo(int index) {
    if (index == _index) {
      widget.onIndexChanged?.call(index);
      return;
    }
    setState(() => _index = index);
    widget.onIndexChanged?.call(index);
  }

  Widget _page() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.02, 0.02),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(key: ValueKey<int>(_index), child: widget.builder(context, _index)),
    );
  }
}

/// Frosted-glass sidebar used on desktop / tablet.
class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.destinations,
    required this.index,
    required this.headerNote,
    required this.onSelect,
    this.footerLabel,
    this.onAccountTap,
  });

  final List<NavDest> destinations;
  final int index;
  final String headerNote;
  final String? footerLabel;
  final ValueChanged<int> onSelect;
  final VoidCallback? onAccountTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final AuthProvider auth = context.watch<AuthProvider>();

    return Container(
      width: 250,
      margin: const EdgeInsets.fromLTRB(14, 14, 0, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.35 : 0.12),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? [const Color(0x66161930), const Color(0x55161930)]
                    : [const Color(0xCCFFFFFF), const Color(0xB3FFFFFF)],
              ),
              border: Border.all(
                color: dark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.white.withValues(alpha: 0.8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      const AppIllustration(IllustrationAssets.logoMark, width: 44, height: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.appName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              headerNote,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Container(height: 1, color: theme.colorScheme.outlineVariant),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      for (int i = 0; i < destinations.length; i++)
                        _SidebarItem(
                          destination: destinations[i],
                          selected: i == index,
                          onTap: () => onSelect(i),
                        ),
                    ],
                  ),
                ),
                const Spacer(),
                if (footerLabel != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Text(
                      footerLabel!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
                  child: Semantics(
                    button: true,
                    label: 'Open profile',
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: onAccountTap,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: dark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.white.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: dark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  gradient: AppGradients.brand,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  _initials(auth.user?.fullName ?? '?'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      auth.user?.fullName ?? 'Guest',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      auth.isChildMode ? 'Child view' : 'View profile',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (onAccountTap != null) const AppIcon('chev_right', size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.destination, required this.selected, required this.onTap});

  final NavDest destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 240),
      style: theme.textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w700),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: selected ? AppGradients.brand : null,
                borderRadius: BorderRadius.circular(18),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF7E92FF).withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : const [],
              ),
              child: Row(
                children: [
                  AppIcon(
                    selected ? (destination.activeIcon ?? destination.icon) : destination.icon,
                    size: 21,
                    color: selected ? Colors.white : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    destination.label,
                    style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating glass bottom navigation bar for compact screens.
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.destinations, required this.index, required this.onSelect});

  final List<NavDest> destinations;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: GlassCard(
        intensive: true,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        radius: 26,
        shadow: 0.16,
        child: Row(
          children: [
            for (int i = 0; i < destinations.length; i++)
              Expanded(
                child: _BottomNavItem(
                  destination: destinations[i],
                  selected: i == index,
                  onTap: () => onSelect(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({required this.destination, required this.selected, required this.onTap});

  final NavDest destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.brand : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF7E92FF).withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : const [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              selected ? (destination.activeIcon ?? destination.icon) : destination.icon,
              size: 22,
              color: selected ? Colors.white : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              destination.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: selected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
