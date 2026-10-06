/// Categorized API errors with user-friendly messages.
library;

enum ApiErrorKind {
  /// Could not reach the server (no internet, DNS, connection refused).
  network,

  /// The request took longer than [ApiConfig.timeout].
  timeout,

  /// 401 – invalid or expired token, or bad credentials.
  unauthorized,

  /// 404 – the resource does not exist.
  notFound,

  /// 5xx – the server failed.
  server,

  /// 4xx other than 401/404 (validation, conflict, etc).
  validation,

  /// Fallback.
  unknown,
}

class ApiException implements Exception {
  const ApiException(this.kind, {this.statusCode, this.message, this.errors});

  const ApiException.network()
    : this(
        ApiErrorKind.network,
        message: 'No internet connection. Check your connection and try again.',
      );

  const ApiException.timeout()
    : this(ApiErrorKind.timeout, message: 'The request timed out. Please try again.');

  const ApiException.unauthorized()
    : this(ApiErrorKind.unauthorized, message: 'Your session has expired. Please log in again.');

  const ApiException.notFound()
    : this(ApiErrorKind.notFound, message: 'The requested item was not found.');

  const ApiException.server()
    : this(
        ApiErrorKind.server,
        message: 'Something went wrong on the server. Please try again later.',
      );

  /// The release bundle was built without a server URL, so no request can be
  /// attempted. Without this the app would silently POST to its own origin and
  /// report a misleading server error.
  const ApiException.notConfigured()
    : this(
        ApiErrorKind.server,
        message:
            'This copy of the app is not connected to a server. '
            'It was built without an API address.',
      );

  /// Builds an [ApiException] from an HTTP status code and the decoded
  /// backend envelope (`{success, message, data, errors}`).
  factory ApiException.fromResponse(int statusCode, Object? decoded) {
    final Map<String, dynamic>? map = decoded is Map<String, dynamic> ? decoded : null;
    final Object? rawErrors = map?['errors'];
    return ApiException(
      _kindFor(statusCode),
      statusCode: statusCode,
      message: map?['message'] as String?,
      errors: rawErrors is Map<String, dynamic> ? rawErrors : null,
    );
  }

  final ApiErrorKind kind;
  final int? statusCode;
  final String? message;
  final Map<String, dynamic>? errors;

  static ApiErrorKind _kindFor(int code) {
    if (code >= 500) return ApiErrorKind.server;
    if (code == 401) return ApiErrorKind.unauthorized;
    if (code == 404) return ApiErrorKind.notFound;
    return ApiErrorKind.validation;
  }

  /// Server-provided message when present, otherwise a friendly fallback.
  String get userMessage {
    if (message != null && message!.trim().isNotEmpty) return message!;
    switch (kind) {
      case ApiErrorKind.network:
        return 'No internet connection. Check your connection and try again.';
      case ApiErrorKind.timeout:
        return 'The request timed out. Please try again.';
      case ApiErrorKind.unauthorized:
        return 'Your session has expired. Please log in again.';
      case ApiErrorKind.notFound:
        return 'The requested item was not found.';
      case ApiErrorKind.server:
        return 'Something went wrong on the server. Please try again later.';
      case ApiErrorKind.validation:
        return 'Please check the information you entered.';
      case ApiErrorKind.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  String toString() => 'ApiException(${statusCode ?? kind}): ${message ?? userMessage}';
}
