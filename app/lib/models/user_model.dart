/// Parent account model.
class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone = '',
    this.avatarKey = '',
    this.primaryAccount = true,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String avatarKey;
  final bool primaryAccount;

  String get initials {
    final List<String> parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return parts[0][0] + parts[1][0];
    return fullName.isNotEmpty ? fullName[0] : '?';
  }

  UserModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? avatarKey,
    bool? primaryAccount,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarKey: avatarKey ?? this.avatarKey,
      primaryAccount: primaryAccount ?? this.primaryAccount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'avatarKey': avatarKey,
    'primaryAccount': primaryAccount,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String? ?? '',
    avatarKey: json['avatarKey'] as String? ?? '',
    primaryAccount: json['primaryAccount'] as bool? ?? true,
  );
}
