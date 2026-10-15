class UserModel {
  final String id;
  final String? phone;
  final String username;
  final String? displayName;
  final String? email;
  final String role;
  final String language;
  final bool hasPassword;

  UserModel({
    required this.id,
    this.phone,
    required this.username,
    this.displayName,
    this.email,
    required this.role,
    this.language = 'bn',
    this.hasPassword = false,
  });

  String get displayNameOrUsername =>
      (displayName != null && displayName!.trim().isNotEmpty)
          ? displayName!
          : '@$username';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString(),
      username: json['username']?.toString() ?? '',
      displayName: json['displayName']?.toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString() ?? 'user',
      language: json['language']?.toString() ?? 'bn',
      hasPassword: json['hasPassword'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'username': username,
      'displayName': displayName,
      'email': email,
      'role': role,
      'language': language,
      'hasPassword': hasPassword,
    };
  }
}
