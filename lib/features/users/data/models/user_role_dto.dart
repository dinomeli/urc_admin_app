class UserRoleDto {
  final String userId;
  final String? userName;
  final String? userFullName;
  final int roleId;
  final String? roleNameEn;
  final String? roleNameFa;
  final double weight;

  UserRoleDto({
    required this.userId,
    this.userName,
    this.userFullName,
    required this.roleId,
    this.roleNameEn,
    this.roleNameFa,
    required this.weight,
  });

  factory UserRoleDto.fromJson(Map<String, dynamic> json) {
    return UserRoleDto(
      // بر اساس لاگ شما: UserId با حرف بزرگ است
      userId: json['UserId'] ?? '', 
      userName: json['UserName'],
      userFullName: json['UserFullName'],
      roleId: json['RoleId'] ?? 0,
      roleNameEn: json['RoleNameEn'],
      roleNameFa: json['RoleNameFa'],
      // تبدیل عدد به double برای اطمینان
      weight: (json['Weight'] ?? 1).toDouble(), 
    );
  }
}