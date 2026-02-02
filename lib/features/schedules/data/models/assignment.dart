class Assignment {
  final int id;
  final int churchRoleId;
  final String userId;
  final String userName;
  final String roleName;
  final String status;

  Assignment({
    required this.id,
    required this.churchRoleId,
    required this.userId,
    required this.userName,
    required this.roleName,
    required this.status,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] ?? 0,
      churchRoleId: json['churchRoleId'] ?? 0,
      userId: json['userId'] ?? '',
      userName: json['user']?['fullName'] ?? json['user']?['userName'] ?? 'نامشخص',
      roleName: json['churchRole']?['nameEn'] ?? 'نامشخص',
      status: json['status'] ?? 'Pending',
    );
  }
}