import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_child_hub/main.dart';
import 'package:smart_child_hub/screens/splash/splash_screen.dart';

void main() {
  testWidgets('App boots to splash and auto-routes to onboarding', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const SmartChildHubApp());

    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsNothing);
  });
}
