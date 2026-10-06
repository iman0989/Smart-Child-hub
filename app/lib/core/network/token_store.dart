import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists the JWT bearer token and the cached parent profile so the app can
/// restore a session across launches (auto-login / session persistence).
class TokenStore {
  TokenStore._(this._prefs);

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  final SharedPreferences _prefs;

  static Future<TokenStore> load() async => TokenStore._(await SharedPreferences.getInstance());

  String? get token => _prefs.getString(_tokenKey);

  Map<String, dynamic>? get user {
    final String? raw = _prefs.getString(_userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> save({required String token, required Map<String, dynamic> user}) async {
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_userKey, jsonEncode(user));
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs.setString(_userKey, jsonEncode(user));
  }

  Future<void> clear() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }
}
