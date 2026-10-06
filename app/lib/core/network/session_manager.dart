import '../../models/user_model.dart';
import 'api_client.dart';
import 'token_store.dart';

/// Owns the active session: the bearer token, the cached parent profile and
/// their persistent storage. `ApiClient` reads the token from here so every
/// authenticated request carries it automatically.
class SessionManager {
  SessionManager._();

  static final SessionManager instance = SessionManager._();

  TokenStore? _store;
  String? _token;
  UserModel? _user;
  bool _restored = false;

  String? get token => _token;
  UserModel? get user => _user;
  bool get isRestored => _restored;
  bool get hasSession => _token != null && _token!.isNotEmpty;

  /// Loads any persisted session from disk (called once at app start).
  Future<void> restore() async {
    _store ??= await TokenStore.load();
    _token = _store!.token;
    final Map<String, dynamic>? cached = _store!.user;
    if (cached != null) {
      try {
        _user = UserModel.fromJson(cached);
      } catch (_) {
        _user = null;
      }
    }
    ApiClient.instance.token = _token;
    _restored = true;
  }

  /// Persists a newly issued token + profile.
  Future<void> saveSession({required String token, required UserModel user}) async {
    _token = token;
    _user = user;
    ApiClient.instance.token = token;
    await _store?.save(token: token, user: user.toJson());
  }

  /// Keeps the cached profile in sync after profile edits.
  Future<void> updateUser(UserModel user) async {
    _user = user;
    await _store?.saveUser(user.toJson());
  }

  /// Drops the token and cached profile (logout / session expiry).
  Future<void> clear() async {
    _token = null;
    _user = null;
    ApiClient.instance.clearChildSession();
    ApiClient.instance.token = null;
    await _store?.clear();
  }
}
