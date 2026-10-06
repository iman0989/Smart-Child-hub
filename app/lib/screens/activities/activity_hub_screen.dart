import 'package:flutter/material.dart';

import '../../core/constants/app_icons.dart';
import '../../routes/app_routes.dart';
import '../../widgets/cards/activity_card.dart';
import '../../widgets/common/animated_background.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/glass_app_bar.dart';
import '../../widgets/common/motion.dart';
import '../../widgets/common/responsive_content.dart';

/// Activity hub linking to every tracking screen.
class ActivityHubScreen extends StatelessWidget {
  const ActivityHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  title: 'Activities',
                  subtitle: 'Track your day',
                  // The hub is both a pushed route ("See all") and a shell tab.
                  // Only offer a way back when there is a route to pop.
                  showBack: Navigator.of(context).canPop(),
                  actions: [
                    IconButton(
                      tooltip: 'Notifications',
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
                      icon: const AppIcon(AppIcons.bell, size: 22),
                    ),
                  ],
                ),
                Expanded(
                  child: ResponsiveContent(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final int columns = constraints.maxWidth >= 1100
                            ? 4
                            : (constraints.maxWidth >= 760
                                  ? 3
                                  : (constraints.maxWidth >= 460 ? 2 : 1));
                        const double gap = 16;
                        final double itemWidth =
                            (constraints.maxWidth - (gap * (columns - 1))) / columns;
                        final cards = <Widget>[
                          _card(
                            context,
                            itemWidth,
                            'Sleep',
                            'Bedtime & rest',
                            AppIcons.bed,
                            const Color(0xFF8A5BF5),
                            AppRoutes.sleepTracking,
                            0,
                          ),
                          _card(
                            context,
                            itemWidth,
                            'Meals',
                            'Breakfast to dinner',
                            AppIcons.food,
                            const Color(0xFFFF8A3D),
                            AppRoutes.mealTracking,
                            1,
                          ),
                          _card(
                            context,
                            itemWidth,
                            'Water',
                            'Daily hydration',
                            AppIcons.water,
                            const Color(0xFF54C3F6),
                            AppRoutes.waterIntake,
                            2,
                          ),
                          _card(
                            context,
                            itemWidth,
                            'Mood',
                            'How you feel',
                            AppIcons.sun,
                            const Color(0xFFFFC93C),
                            AppRoutes.moodTracking,
                            3,
                          ),
                          _card(
                            context,
                            itemWidth,
                            'Homework',
                            'School tasks',
                            AppIcons.homework,
                            const Color(0xFF4359E0),
                            AppRoutes.homework,
                            4,
                          ),
                        ];
                        return Wrap(spacing: gap, runSpacing: gap, children: cards);
                      },
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

  Widget _card(
    BuildContext context,
    double width,
    String title,
    String subtitle,
    String icon,
    Color color,
    String route,
    int index,
  ) {
    return SizedBox(
      width: width,
      child: Entrance(
        delay: Duration(milliseconds: 80 + index * 60),
        child: ActivityCard(
          title: title,
          subtitle: subtitle,
          icon: icon,
          color: color,
          onTap: () => Navigator.of(context).pushNamed(route),
        ),
      ),
    );
  }
}
