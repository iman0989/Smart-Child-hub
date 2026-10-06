import 'package:flutter/foundation.dart';

import '../core/services/auth_service.dart';
import '../core/theme/app_theme.dart';
import '../models/user_model.dart';

enum AuthStatus { idle, loading, success, error }

/// Session state backed by the REST [AuthService].
///
/// Handles login, registration, password recovery, auto-login (session
/// restore + token validation) and logout, and exposes a small `isLoading`/
/// `error` surface for the auth screens.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? service}) : _service = service ?? AuthService();

  final AuthService _service;

  UserModel? _user;
  AuthStatus _status = AuthStatus.idle;
  String? _error;
  AppMode _mode = AppMode.parent;

  UserModel? get user => _user;
  AuthStatus get status => _status;
  String? get error => _error;
  AppMode get mode => _mode;

  bool get isLoggedIn => _user != null;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isChildMode => _mode == AppMode.child;

  /// Called by the splash screen at startup: restores any persisted session,
  /// then validates the token against the server (auto-login).
  Future<bool> restoreSession() async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final UserModel? cached = await _service.restoreSession();
      if (cached == null) {
        _status = AuthStatus.idle;
        notifyListeners();
        return false;
      }
      final bool valid = await _service.validateSession();
      if (!valid) {
        // Offline keeps the cached session; an invalid token clears it.
        if (!_service.hasSession) {
          _user = null;
          _status = AuthStatus.idle;
          notifyListeners();
          return false;
        }
      }
      _user = _service.currentUser;
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _user = await _service.login(email: email, password: password);
      _mode = AppMode.parent;
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _user = await _service.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
      _mode = AppMode.parent;
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    try {
      await _service.resetPassword(email: email);
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Gets the reset token from the forgot-password response (dev flow).
  Future<String?> requestResetToken({required String email}) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final String? token = await _service.requestResetToken(email: email);
      _status = AuthStatus.success;
      notifyListeners();
      return token;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> completePasswordReset({
    required String email,
    required String token,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    try {
      await _service.completePasswordReset(email: email, token: token, password: password);
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _user = await _service.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _service.logout();
    _user = null;
    _status = AuthStatus.idle;
    _error = null;
    notifyListeners();
  }

  Future<void> updateProfile({String? fullName, String? phone, String? avatarKey}) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    try {
      await _service.updateProfile(fullName: fullName, phone: phone, avatarKey: avatarKey);
      _user = _service.currentUser;
      _status = AuthStatus.success;
      notifyListeners();
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _error = e.message;
      notifyListeners();
    }
  }

  void setMode(AppMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  /// Keeps the stored user object in sync after local edits.
  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }
}
