

class AttendanceDto {
  final int id;
  final int scheduleId;
  final DateTime serviceDate;
  final String userId;
  final String? userFullName;
  final String? roleName;
  final String status; // "Accepted", "Absent", "Pending"

  AttendanceDto({
    required this.id,
    required this.scheduleId,
    required this.serviceDate,
    required this.userId,
    this.userFullName,
    this.roleName,
    required this.status,
  });

  factory AttendanceDto.fromJson(Map<String, dynamic> json) {
    return AttendanceDto(
      id: json['Id'] ?? 0,
      scheduleId: json['ScheduleId'] ?? 0,
      serviceDate: json['ServiceDate'] != null
          ? DateTime.parse(json['ServiceDate'])
          : DateTime.now(),
      userId: json['UserId'] ?? '',
      userFullName: json['UserFullName'],
      roleName: json['RoleName'],
      status: json['Status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() => {
    'Id': id,
    'ScheduleId': scheduleId,
    'Status': status,
  };
}
