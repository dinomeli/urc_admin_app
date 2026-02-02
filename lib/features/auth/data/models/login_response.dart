class LoginResponse {
  final String token;
  final DateTime expires;
  final String email;
  final String username;
  final List<String> roles;

  LoginResponse({
    required this.token,
    required this.expires,
    required this.email,
    required this.username,
    this.roles = const [],  // ← فقط required رو برداشتیم
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    List<String> parsedRoles = [];

    final rolesRaw = json['roles'];

    if (rolesRaw is List) {
      parsedRoles = rolesRaw.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
    } else if (rolesRaw is String) {
      parsedRoles = [rolesRaw.trim()];
    } else if (rolesRaw != null) {
      parsedRoles = [rolesRaw.toString()];
    }

    return LoginResponse(
      token: json['token']?.toString() ?? '',
      expires: DateTime.tryParse(json['expires']?.toString() ?? '') ?? DateTime.now(),
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      roles: parsedRoles,
    );
  }
}