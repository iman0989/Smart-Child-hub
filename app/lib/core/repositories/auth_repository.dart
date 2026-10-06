import '../../models/child_model.dart';
import '../../models/user_model.dart';
import '../network/api_client.dart';

/// Result of a successful sign-in: profile plus the raw JWT bearer token.
class AuthSession {
  const AuthSession({required this.user, required this.token});

  final UserModel user;
  final String token;
}

/// The security questions a child must answer to recover their PIN.
class ChildRecoveryChallenge {
  const ChildRecoveryChallenge({
    required this.childId,
    required this.name,
    required this.questions,
  });

  final String childId;
  final String name;

  /// Question keys, in the order the parent configured them.
  final List<String> questions;

  factory ChildRecoveryChallenge.fromJson(Map<String, dynamic> json) {
    return ChildRecoveryChallenge(
      childId: json['childId'] as String,
      name: json['name'] as String? ?? '',
      questions: (json['questions'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((Map<String, dynamic> item) => item['questionKey'] as String? ?? '')
          .where((String key) => key.isNotEmpty)
          .toList(growable: false),
    );
  }
}

/// A verified recovery session, good for one PIN reset.
class ChildRecoveryGrant {
  const ChildRecoveryGrant({
    required this.childId,
    required this.recoveryToken,
    required this.expiresInMinutes,
  });

  final String childId;
  final String recoveryToken;
  final int expiresInMinutes;

  factory ChildRecoveryGrant.fromJson(Map<String, dynamic> json) {
    return ChildRecoveryGrant(
      childId: json['childId'] as String,
      recoveryToken: json['recoveryToken'] as String,
      expiresInMinutes: (json['expiresInMinutes'] as num?)?.toInt() ?? 15,
    );
  }
}

/// Result of a successful child PIN reset.
class ChildRecoveryResult {
  const ChildRecoveryResult({required this.childId, required this.name});

  final String childId;
  final String name;
}

/// Data access for the `/api/auth/*` and `/api/parent/profile` endpoints.
class AuthRepository {
  AuthRepository([ApiClient? client]) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<AuthSession> login({
    required String email,
    required String password,
    String deviceName = 'mobile',
  }) async {
    final dynamic data = await _client.post(
      '/api/auth/login',
      body: {'email': email, 'password': password, 'deviceName': deviceName},
    );
    return _sessionFrom(data);
  }

  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String deviceName = 'mobile',
  }) async {
    final dynamic data = await _client.post(
      '/api/auth/register',
      body: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': password,
        'deviceName': deviceName,
      },
    );
    return _sessionFrom(data);
  }

  /// Sends a password reset request. Backend returns the dev one-time token.
  Future<Map<String, dynamic>?> forgotPassword({required String email}) async {
    final dynamic data = await _client.post('/api/auth/forgot-password', body: {'email': email});
    return data is Map<String, dynamic> ? data : null;
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {
    await _client.post(
      '/api/auth/reset-password',
      body: {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': password,
      },
    );
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    String deviceName = 'mobile',
  }) async {
    final dynamic data = await _client.post(
      '/api/auth/change-password',
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'newPasswordConfirmation': newPassword,
        'deviceName': deviceName,
      },
    );
    final Map<String, dynamic> map = data as Map<String, dynamic>;
    if (map['token'] is String) {
      // Password change revokes other sessions and issues a fresh token.
      ApiClient.instance.token = map['token'] as String;
    }
    return map;
  }

  /// Validates the stored token and returns the current profile.
  Future<UserModel> me() async {
    final dynamic data = await _client.get('/api/auth/me');
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _client.post('/api/auth/logout');
  }

  /// Logs a child in with their 4-digit PIN. The backend returns the child
  /// profile plus a child-scoped session token; this repository switches the
  /// [ApiClient] to the child session so the rest of the app is authenticated
  /// as that child (and rejected from parent-only management endpoints).
  Future<ChildModel> childLogin({required String childId, required String pin}) async {
    final dynamic data = await _client.post(
      '/api/auth/child-login',
      body: {'childId': childId, 'pin': pin},
    );
    final Map<String, dynamic> map = data as Map<String, dynamic>;
    final ChildModel child = ChildModel.fromJson(map['child'] as Map<String, dynamic>);
    final String? token = map['token'] as String?;
    if (token != null && token.isNotEmpty) {
      _client.useChildSession(token);
    }
    return child;
  }

  // --- Child PIN recovery -------------------------------------------------

  /// Step 1: load the security questions the parent set for [childId].
  ///
  /// [name] identifies the child when there is no signed-in parent, which is
  /// the usual case: a child who forgot their PIN cannot log in first.
  Future<ChildRecoveryChallenge> childRecoveryQuestions({
    required String childId,
    String? name,
  }) async {
    final dynamic data = await _client.post(
      '/api/auth/child-recovery/questions',
      body: {'childId': childId, if (name != null && name.trim().isNotEmpty) 'name': name.trim()},
    );
    return ChildRecoveryChallenge.fromJson(data as Map<String, dynamic>);
  }

  /// Step 2: answer the questions and receive a single-child recovery token.
  ///
  /// [answers] maps a question key to the child's answer.
  Future<ChildRecoveryGrant> verifyChildRecovery({
    required String childId,
    String? name,
    required Map<String, String> answers,
  }) async {
    final dynamic data = await _client.post(
      '/api/auth/child-recovery/verify',
      body: {
        'childId': childId,
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        'answers': answers.entries
            .map(
              (MapEntry<String, String> entry) => {'questionKey': entry.key, 'answer': entry.value},
            )
            .toList(growable: false),
      },
    );
    return ChildRecoveryGrant.fromJson(data as Map<String, dynamic>);
  }

  /// Step 3: exchange a recovery token for a new 4-digit PIN.
  ///
  /// The token is bound to one child, so this can never change another
  /// profile's PIN. Any session opened with the old PIN is revoked.
  Future<ChildRecoveryResult> resetChildPin({
    required String recoveryToken,
    required String newPin,
    required String newPinConfirmation,
  }) async {
    final dynamic data = await _client.post(
      '/api/auth/child-recovery/reset',
      body: {
        'recoveryToken': recoveryToken,
        'newPin': newPin,
        'newPinConfirmation': newPinConfirmation,
      },
    );
    final Map<String, dynamic> map = data as Map<String, dynamic>;
    return ChildRecoveryResult(
      childId: map['childId'] as String? ?? '',
      name: map['name'] as String? ?? '',
    );
  }

  Future<UserModel> updateProfile({String? fullName, String? phone, String? avatarKey}) async {
    final dynamic data = await _client.put(
      '/api/parent/profile',
      body: {'fullName': ?fullName, 'phone': ?phone, 'avatarKey': ?avatarKey},
    );
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  AuthSession _sessionFrom(dynamic data) {
    final Map<String, dynamic> map = data as Map<String, dynamic>;
    final UserModel user = UserModel.fromJson(map['user'] as Map<String, dynamic>);
    final String token = map['token'] as String;
    return AuthSession(user: user, token: token);
  }
}
