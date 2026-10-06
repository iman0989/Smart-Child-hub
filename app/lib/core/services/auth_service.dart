import '../../models/user_model.dart';
import '../network/api_exception.dart';
import '../network/session_manager.dart';
import '../repositories/auth_repository.dart';

/// REST authentication service.
///
/// Handles sign-in, sign-up, password recovery, session restore (auto-login)
/// and logout. It persists the bearer token + profile via [SessionManager] and
/// converts transport/API failures into user-friendly [AuthException]s.
class AuthService {
  AuthService({AuthRepository? repository}) : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;
  final SessionManager _session = SessionManager.instance;

  UserModel? get currentUser => _session.user;
  bool get hasSession => _session.hasSession;

  /// Restores a persisted session and returns the cached profile.
  Future<UserModel?> restoreSession() async {
    if (_session.isRestored) {
      if (_session.hasSession) return _session.user;
      return null;
    }
    await _session.restore();
    return _session.user;
  }

  /// Validates the stored token against the server. Clears the session on 401.
  Future<bool> validateSession() async {
    if (!_session.hasSession) return false;
    try {
      final UserModel user = await _repository.me();
      await _session.updateUser(user);
      return true;
    } on ApiException catch (e) {
      if (e.kind == ApiErrorKind.unauthorized) {
        // The token is invalid or expired: drop the session so the app
        // returns to the login flow instead of running on a dead token.
        await _session.clear();
        return false;
      }
      if (e.kind == ApiErrorKind.network || e.kind == ApiErrorKind.timeout) {
        // Offline should not nuke the stored session; keep it for next launch.
        return false;
      }
      await _session.clear();
      return false;
    }
  }

  Future<UserModel> login({required String email, required String password}) async {
    try {
      final session = await _repository.login(email: email, password: password);
      await _session.saveSession(token: session.token, user: session.user);
      return session.user;
    } on ApiException catch (e) {
      throw AuthException(e.userMessage);
    }
  }

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final session = await _repository.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
      await _session.saveSession(token: session.token, user: session.user);
      return session.user;
    } on ApiException catch (e) {
      throw AuthException(e.userMessage);
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _repository.forgotPassword(email: email);
    } on ApiException catch (e) {
      throw AuthException(e.userMessage);
    }
  }

  /// Requests a reset token and returns it (dev flow where the backend
  /// returns the token in the response body).
  Future<String?> requestResetToken({required String email}) async {
    try {
      final Map<String, dynamic>? result = await _repository.forgotPassword(email: email);
      return result?['resetToken'] as String?;
    } on ApiException catch (e) {
      throw AuthException(e.userMessage);
    }
  }

  Future<void> completePasswordReset({
    required String email,
    required String token,
    required String password,
  }) async {
    try {
      await _repository.resetPassword(email: email, token: token, password: password);
    } on ApiException catch (e) {
      throw AuthException(e.userMessage);
    }
  }

  /// Changes the password, keeps the freshly issued session token, and
  /// returns the updated profile.
  Future<UserModel> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final dynamic result = await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      final UserModel user = UserModel.fromJson(
        (result as Map<String, dynamic>)['user'] as Map<String, dynamic>,
      );
      final String token = result['token'] as String;
      await _session.saveSession(token: token, user: user);
      return user;
    } on ApiException catch (e) {
      throw AuthException(e.userMessage);
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } on ApiException {
      // Even if the server call fails we must clear the local session.
    } finally {
      await _session.clear();
    }
  }

  Future<void> updateProfile({String? fullName, String? phone, String? avatarKey}) async {
    try {
      final UserModel user = await _repository.updateProfile(
        fullName: fullName,
        phone: phone,
        avatarKey: avatarKey,
      );
      await _session.updateUser(user);
    } on ApiException catch (e) {
      throw AuthException(e.userMessage);
    }
  }
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
