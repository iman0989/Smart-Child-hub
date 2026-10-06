import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Driver that saves every screenshot taken by the integration test to the
/// `screenshots/` folder next to the app directory.
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes,
        [Map<String, Object?>? args]) async {
      final File file = File('screenshots/$name.png');
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}
