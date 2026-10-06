import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';
import 'network_error.dart';

/// Typed REST client for the Smart Child Hub PHP backend.
///
/// Talks to the `{success, message, data, errors}` envelope, injects the
/// bearer token from [SessionManager], applies a request timeout, and maps
/// transport failures (no internet / timeout) and HTTP errors to friendly
/// [ApiException]s.
class ApiClient {
  ApiClient._(this._baseUrl);

  /// The token is attached here by `SessionManager` (or directly for tests).
  /// This is the parent credential for parent-mode requests.
  String? token;

  /// Child session token issued by `/api/auth/child-login`. While
  /// [useChildToken] is true it is sent instead of [token], so the backend can
  /// authenticate the request as the PIN-authenticated child (which is then
  /// refused from parent-only profile/PIN/account management endpoints).
  String? childToken;

  bool useChildToken = false;

  final String _baseUrl;
  static ApiClient instance = ApiClient._(ApiConfig.baseUrl);

  bool get isConfigured => _baseUrl.isNotEmpty;

  /// Enters child mode: subsequent requests use the child session token.
  void useChildSession(String token) {
    childToken = token;
    useChildToken = true;
  }

  /// Switches back to the parent credential (parent zone / after logout).
  void useParentSession() {
    useChildToken = false;
  }

  void clearChildSession() {
    childToken = null;
    useChildToken = false;
  }

  static void configure({String? baseUrl, String? token}) {
    if (baseUrl != null && baseUrl.isNotEmpty) {
      instance = ApiClient._(baseUrl);
    }
    if (token != null) instance.token = token;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    // A release bundle built without --dart-define=API_BASE_URL has no server.
    // Fail with a clear message instead of sending the request to whatever
    // origin happens to be hosting the frontend.
    if (!isConfigured) throw const ApiException.notConfigured();

    final Uri base = Uri.parse('$_baseUrl$path');
    if (query == null || query.isEmpty) return base;
    return base.replace(queryParameters: query);
  }

  Map<String, String> _headers({bool withBody = true}) {
    final String? active = useChildToken ? (childToken ?? token) : token;
    return {
      if (withBody) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (active != null && active.isNotEmpty) 'Authorization': 'Bearer $active',
    };
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) => _guard(() async {
    final http.Response res = await http
        .get(_uri(path, query), headers: _headers(withBody: false))
        .timeout(ApiConfig.timeout);
    return _decode(res);
  });

  Future<dynamic> post(String path, {Object? body}) => _guard(() async {
    final http.Response res = await http
        .post(_uri(path), headers: _headers(), body: jsonEncode(body ?? const {}))
        .timeout(ApiConfig.timeout);
    return _decode(res);
  });

  Future<dynamic> put(String path, {Object? body}) => _guard(() async {
    final http.Response res = await http
        .put(_uri(path), headers: _headers(), body: jsonEncode(body ?? const {}))
        .timeout(ApiConfig.timeout);
    return _decode(res);
  });

  Future<dynamic> delete(String path, {Object? body}) => _guard(() async {
    final http.Response res = await http
        .delete(_uri(path), headers: _headers(), body: body == null ? null : jsonEncode(body))
        .timeout(ApiConfig.timeout);
    return _decode(res);
  });

  /// Multipart form upload (used for child profile photos).
  ///
  /// The file is sent as bytes rather than by path. A browser has no local
  /// filesystem path to hand to `MultipartFile.fromPath`, so a path based
  /// upload simply cannot work on Web; reading the picked file into memory keeps
  /// one code path for every platform. Photos are capped at 5 MB server side.
  Future<dynamic> postMultipart(
    String path, {
    required String fileField,
    required Uint8List bytes,
    required String filename,
    Map<String, String>? fields,
  }) => _guard(() async {
    final http.MultipartRequest request = http.MultipartRequest('POST', _uri(path));
    request.headers.addAll(_headers());
    final List<MapEntry<String, String>> fieldEntries = fields?.entries.toList() ?? [];
    for (final MapEntry<String, String> e in fieldEntries) {
      request.fields[e.key] = e.value;
    }
    request.files.add(
      http.MultipartFile.fromBytes(fileField, bytes, filename: filename),
    );
    final http.StreamedResponse streamed = await http.Client()
        .send(request)
        .timeout(ApiConfig.timeout);
    final http.Response res = await http.Response.fromStream(streamed);
    return _decode(res);
  });

  dynamic _decode(http.Response res) {
    if (res.statusCode == 204) return null;

    Object? decoded;
    try {
      decoded = res.body.isEmpty ? null : jsonDecode(res.body);
    } catch (_) {
      decoded = null;
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded['data'];
      return decoded;
    }

    throw ApiException.fromResponse(res.statusCode, decoded);
  }

  Future<dynamic> _guard(Future<dynamic> Function() run) async {
    try {
      return await run();
    } on TimeoutException {
      throw const ApiException.timeout();
    } on http.ClientException {
      throw const ApiException.network();
    } catch (error) {
      // dart:io is unavailable on Web, so SocketException detection is
      // resolved by conditional import rather than by naming the type here.
      if (isNetworkFailure(error)) {
        throw const ApiException.network();
      }
      rethrow;
    }
  }
}
