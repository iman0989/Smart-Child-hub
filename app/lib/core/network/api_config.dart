/// Networking configuration for the Smart Child Hub PHP backend.
library;

import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  /// Compile-time override, supplied when building for a real host:
  ///
  ///   flutter build web --release --dart-define=API_BASE_URL=https://api.example.com
  ///
  /// or, to keep the URL out of the command line, put it in a file:
  ///
  ///   flutter build web --release --dart-define-from-file=config/production.env
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Local XAMPP API. Only ever used by debug/profile builds, so a release
  /// bundle can never ship a `localhost` URL that is meaningless on the
  /// teacher's machine.
  static const String _localBaseUrl =
      'http://localhost/Smart-Child-Daily-Activity-Tracking-System/backend/public';

  /// Base origin of the REST API, without a trailing slash.
  ///
  /// Android emulators reach the host machine through 10.0.2.2, so pass that via
  /// --dart-define there. A release build without an override resolves to an
  /// empty string, which [ApiClient] reports as "not configured" instead of
  /// failing later with a confusing network error.
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _normalize(_envBaseUrl);

    // Debug and profile keep working against the local XAMPP backend untouched.
    if (kReleaseMode) return '';

    return _normalize(_localBaseUrl);
  }

  /// True when the bundle knows which server to talk to. The login screen uses
  /// this to show setup guidance instead of a generic connection failure.
  static bool get isConfigured => baseUrl.isNotEmpty;

  /// Max time to wait for any single HTTP request before treating it as a
  /// timeout and surfacing a friendly message.
  static const Duration timeout = Duration(seconds: 20);

  /// Device name reported when issuing auth tokens.
  static const String deviceName = 'mobile';

  /// Tolerant parsing of an operator supplied base URL: a missing scheme
  /// defaults to https (production only), and stray trailing slashes or a
  /// trailing `/api` are removed so paths concatenate cleanly.
  static String _normalize(String raw) {
    String value = raw.trim();
    if (value.isEmpty) return '';

    if (!value.contains('://')) value = 'https://$value';
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    if (value.endsWith('/api')) {
      value = value.substring(0, value.length - 4);
    }

    return value;
  }
}
