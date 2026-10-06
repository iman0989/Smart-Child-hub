import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_icons.dart';
import '../../providers/notification_provider.dart';
import '../../routes/app_routes.dart';
import 'animated_background.dart';
import 'app_icon.dart';
import 'glass_app_bar.dart';
import 'responsive_content.dart';

/// Standard full-screen scaffold for pushed module screens: the animated world
/// behind a frosted floating bar and the given [child] content.
///
/// Every tracking screen can drop-in replace
/// `Scaffold(appBar: CustomAppBar(...), body: ...)` with this widget.
class WorldScreen extends StatelessWidget {
  const WorldScreen({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.actions = const [],
    this.onBack,
    this.backgroundOpacity = 0.9,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      AppConstants.screenPadding,
      AppConstants.spaceXs,
      AppConstants.screenPadding,
      AppConstants.spaceXxl,
    ),
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final List<Widget> actions;
  final VoidCallback? onBack;
  final double backgroundOpacity;
  final Widget child;

  /// Padding around the content inside [ResponsiveContent].
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: AnimatedBackground(opacity: backgroundOpacity)),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                GlassAppBar(
                  title: title,
                  subtitle: subtitle,
                  showBack: showBack,
                  actions: actions,
                  onBack: onBack,
                ),
                Expanded(
                  child: ResponsiveContent(padding: padding, child: child),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Standard notification bell action for [WorldScreen] / [GlassAppBar].
class NotificationBellAction extends StatelessWidget {
  const NotificationBellAction({super.key});

  @override
  Widget build(BuildContext context) {
    final int unread = context.watch<NotificationProvider>().unreadCount;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: IconButton(
        tooltip: 'Notifications',
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
        icon: Badge.count(
          count: unread,
          isLabelVisible: unread > 0,
          backgroundColor: Theme.of(context).colorScheme.error,
          child: const AppIcon(AppIcons.bell, size: 22),
        ),
      ),
    );
  }
}
