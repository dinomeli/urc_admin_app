class WeeklyPlanDto {
  final int scheduleId;
  final DateTime serviceDate;
  final String? roleNameEn;
  final String? roleNameFa;
  final String status;
  final bool isConfirmed;
  final String? userName;

  WeeklyPlanDto({
    required this.scheduleId,
    required this.serviceDate,
    this.roleNameEn,
    this.roleNameFa,
    required this.status,
    required this.isConfirmed,
    this.userName,
  });

  factory WeeklyPlanDto.fromJson(Map<String, dynamic> json) {
    return WeeklyPlanDto(
      // دقت کنید کلیدها دقیقاً مطابق خروجی پست‌من شماست
      scheduleId: json['ScheduleId'] ?? 0,
      serviceDate: DateTime.parse(json['ServiceDate']),
      roleNameEn: json['RoleNameEn'],
      roleNameFa: json['RoleNameFa'],
      status: json['Status'] ?? 'Pending',
      isConfirmed: json['IsConfirmed'] ?? false,
      userName: json['UserName'],
    );
  }
}