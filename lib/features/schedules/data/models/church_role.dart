class ChurchRole {
  final int id;
  final String nameEn;
  // فیلدهای دیگر اگر لازم

  ChurchRole({
    required this.id,
    required this.nameEn,
  });

  factory ChurchRole.fromJson(Map<String, dynamic> json) {
    return ChurchRole(
      id: json['id'] ?? 0,
      nameEn: json['nameEn'] ?? 'نامشخص',
    );
  }
}