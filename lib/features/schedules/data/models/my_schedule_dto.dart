class MyScheduleDto {
  final int assignmentId;
  final int scheduleId;
  final DateTime serviceDate;
  final String? roleNameEn;
  final String? roleNameFa;
  final String? userFullName;
  final String status;
  final bool isConfirmed;
  final String? confirmationToken;

  MyScheduleDto({
    required this.assignmentId,
    required this.scheduleId,
    required this.serviceDate,
    this.roleNameEn,
    this.roleNameFa,
    this.userFullName,
    required this.status,
    required this.isConfirmed,
    this.confirmationToken,
  });

 factory MyScheduleDto.fromJson(Map<String, dynamic> json) {
  return MyScheduleDto(
    // بررسی هر دو حالت حروف بزرگ و کوچک برای اطمینان کامل
    assignmentId: json['assignmentId'] ?? json['AssignmentId'] ?? 0,
    scheduleId: json['scheduleId'] ?? json['ScheduleId'] ?? 0,
    
    serviceDate: json['serviceDate'] != null 
        ? DateTime.parse(json['serviceDate']) 
        : (json['ServiceDate'] != null ? DateTime.parse(json['ServiceDate']) : DateTime.now()),
    
    roleNameEn: json['roleNameEn'] ?? json['RoleNameEn'],
    roleNameFa: json['roleNameFa'] ?? json['RoleNameFa'],
    
    // فیلدی که "نامشخص" می‌شد احتمالاً در JSON با U بزرگ شروع شده
    userFullName: json['userFullName'] ?? json['UserFullName'] ?? "نامشخص", 
    
    status: (json['status'] ?? json['Status'] ?? 'Pending').toString(),
    isConfirmed: json['isConfirmed'] ?? json['IsConfirmed'] ?? false,
    confirmationToken: json['confirmationToken'] ?? json['ConfirmationToken'],
  );
}

  MyScheduleDto copyWith({
    String? status,
    bool? isConfirmed,
  }) {
    return MyScheduleDto(
      assignmentId: assignmentId,
      scheduleId: scheduleId,
      serviceDate: serviceDate,
      roleNameEn: roleNameEn,
      roleNameFa: roleNameFa,
      userFullName: userFullName,
      confirmationToken: confirmationToken,
      status: status ?? this.status,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}