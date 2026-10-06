import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_child_hub/core/theme/app_theme.dart';
import 'package:smart_child_hub/providers/auth_provider.dart';
import 'package:smart_child_hub/providers/settings_provider.dart';
import 'package:smart_child_hub/screens/authentication/login_brand_panel.dart';
import 'package:smart_child_hub/screens/authentication/login_screen.dart';

Widget _wrap(Widget child, {required bool dark}) {
  return MultiProvider(
    providers: <ChangeNotifierProvider<dynamic>>[
      ChangeNotifierProvider<SettingsProvider>(
        create: (_) => SettingsProvider()..setDarkMode(dark),
      ),
      ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      home: child,
    ),
  );
}

/// Guards the responsive split layout: the sign-in screen must render without
/// layout errors from a 360 px phone up to a 1440 px desktop, in both themes.
void main() {
  SharedPreferences.setMockInitialValues(<String, Object>{});

  const List<Size> sizes = <Size>[
    Size(360, 640),
    Size(430, 932),
    Size(600, 900),
    Size(840, 900),
    Size(1280, 800),
    Size(1440, 900),
  ];

  for (final bool dark in <bool>[false, true]) {
    for (final Size size in sizes) {
      testWidgets('login ${dark ? "dark" : "light"} '
          '${size.width.toInt()}x${size.height.toInt()}', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final List<String> reports = <String>[];
        final void Function(FlutterErrorDetails)? previous = FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          reports.add(details.toString());
        };
        addTearDown(() => FlutterError.onError = previous);

        await tester.pumpWidget(_wrap(const LoginScreen(), dark: dark));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 800));
        final Object? err = tester.takeException();
        FlutterError.onError = previous;

        expect(reports, isEmpty, reason: 'layout errors at $size');
        expect(err, isNull);

        // The split layout shows both panels; the compact layout swaps the
        // brand panel for a banner.
        expect(find.byType(LoginBrandPanel), size.width >= 840 ? findsOneWidget : findsNothing);
        expect(find.byType(LoginCompactBanner), size.width >= 840 ? findsNothing : findsOneWidget);

        expect(find.text('Sign in'), findsOneWidget);
        expect(find.text('Kids mode'), findsOneWidget);
        expect(find.text('Create a parent account'), findsOneWidget);
        expect(find.text('Forgot password?'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(2));
      });
    }
  }
}
