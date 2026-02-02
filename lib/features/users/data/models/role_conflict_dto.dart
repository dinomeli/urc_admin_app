class RoleConflictDto {
  final int id;
  final int roleAId;
  final String? roleANameFa;
  final String? roleANameEn;
  final int roleBId;
  final String? roleBNameFa;
  final String? roleBNameEn;
  final String? description;

  RoleConflictDto({
    required this.id,
    required this.roleAId,
    this.roleANameFa,
    this.roleANameEn,
    required this.roleBId,
    this.roleBNameFa,
    this.roleBNameEn,
    this.description,
  });

  factory RoleConflictDto.fromJson(Map<String, dynamic> json) {
    return RoleConflictDto(
      id: json['Id'] ?? 0,
      roleAId: json['RoleAId'] ?? 0,
      roleANameFa: json['RoleANameFa'],
      roleANameEn: json['RoleANameEn'],
      roleBId: json['RoleBId'] ?? 0,
      roleBNameFa: json['RoleBNameFa'],
      roleBNameEn: json['RoleBNameEn'],
      description: json['Description'],
    );
  }

  Map<String, dynamic> toJson() => {
    'RoleAId': roleAId,
    'RoleBId': roleBId,
    'Description': description,
  };
}