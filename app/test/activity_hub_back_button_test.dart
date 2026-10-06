import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_child_hub/core/theme/app_theme.dart';
import 'package:smart_child_hub/screens/activities/activity_hub_screen.dart';
import 'package:smart_child_hub/widgets/common/glass_app_bar.dart';

void main() {
  Widget app({required bool asTab}) {
    if (asTab) {
      return MaterialApp(theme: AppTheme.light(), home: const ActivityHubScreen());
    }
    return MaterialApp(
      theme: AppTheme.light(),
      home: Builder(
        builder: (BuildContext context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/activity-hub'),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      onGenerateRoute: (RouteSettings settings) =>
          MaterialPageRoute<void>(builder: (_) => const ActivityHubScreen(), settings: settings),
    );
  }

  testWidgets('pushed route shows a working back button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/activity-hub'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        onGenerateRoute: (RouteSettings settings) =>
            MaterialPageRoute<void>(builder: (_) => const ActivityHubScreen(), settings: settings),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityHubScreen), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    // Returned to the launching screen.
    expect(find.byType(ActivityHubScreen), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('root tab hides the back button', (WidgetTester tester) async {
    await tester.pumpWidget(app(asTab: true));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityHubScreen), findsOneWidget);
    expect(find.byType(GlassAppBar), findsOneWidget);
    expect(find.byTooltip('Back'), findsNothing);
  });
}
