import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/dashboard_loader.dart';
import '../../models/app_notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/cards/notification_tile.dart';
import '../../widgets/common/animated_background.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_state_widget.dart' show showAppError;
import '../../widgets/common/glass_app_bar.dart';
import '../../widgets/common/motion.dart';
import '../../widgets/common/responsive_content.dart';

/// Notification center with mark-all-read and dismiss actions.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationProvider provider = context.watch<NotificationProvider>();
    final List<AppNotificationModel> notifications = provider.notifications;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: AnimatedBackground(opacity: 0.9)),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                GlassAppBar(
                  title: 'Notifications',
                  subtitle: '${provider.unreadCount} unread',
                  actions: [
                    if (provider.unreadCount > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextButton(
                          onPressed: () async {
                            await provider.markAllRead();
                            if (context.mounted && provider.error != null) {
                              showAppError(context, provider.error);
                            }
                          },
                          child: const Text('Mark all read'),
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: ResponsiveContent(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    child: notifications.isEmpty
                        ? const EmptyStateWidget(
                            title: 'All caught up',
                            message: 'You have no notifications right now.',
                          )
                        : RefreshIndicator(
                            onRefresh: () => loadDashboardData(context),
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: notifications.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final notification = notifications[index];
                                return Entrance(
                                  delay: Duration(milliseconds: 60 * index.clamp(0, 6)),
                                  child: NotificationTile(
                                    notification: notification,
                                    onTap: () async {
                                      await provider.markRead(notification.id);
                                      if (context.mounted && provider.error != null) {
                                        showAppError(context, provider.error);
                                      }
                                    },
                                    onDismiss: () async {
                                      await provider.dismiss(notification.id);
                                      if (context.mounted && provider.error != null) {
                                        showAppError(context, provider.error);
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
