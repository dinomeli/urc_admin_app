class RolePairDto {
  final int id;
  final String personAId;
  final String? personAName;
  final String personBId;
  final String? personBName;
  final int roleAId;
  final String? roleAName;
  final int roleBId;
  final String? roleBName;
  final bool alwaysTogether;

  RolePairDto({
    required this.id,
    required this.personAId,
    this.personAName,
    required this.personBId,
    this.personBName,
    required this.roleAId,
    this.roleAName,
    required this.roleBId,
    this.roleBName,
    required this.alwaysTogether,
  });

  factory RolePairDto.fromJson(Map<String, dynamic> json) {
    return RolePairDto(
      // بر اساس لاگ شما، نام فیلدها در JSON با حروف بزرگ شروع می‌شود
      id: json['Id'] is int ? json['Id'] : (json['Id'] as num? ?? 0).toInt(),
      personAId: json['PersonAId']?.toString() ?? '',
      personAName: json['PersonAName']?.toString(),
      personBId: json['PersonBId']?.toString() ?? '',
      personBName: json['PersonBName']?.toString(),
      roleAId: json['RoleAId'] is int ? json['RoleAId'] : (json['RoleAId'] as num? ?? 0).toInt(),
      roleAName: json['RoleAName']?.toString(),
      roleBId: json['RoleBId'] is int ? json['RoleBId'] : (json['RoleBId'] as num? ?? 0).toInt(),
      roleBName: json['RoleBName']?.toString(),
      alwaysTogether: json['AlwaysTogether'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'PersonAId': personAId,
      'PersonBId': personBId,
      'RoleAId': roleAId,
      'RoleBId': roleBId,
      'AlwaysTogether': alwaysTogether,
    };
  }
}