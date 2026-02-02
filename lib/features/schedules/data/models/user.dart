class User {
  final String id;
  final String fullName;
  // فیلدهای دیگر اگر لازم

  User({
    required this.id,
    required this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? json['userName'] ?? 'نامشخص',
    );
  }
}