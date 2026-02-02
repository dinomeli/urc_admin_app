// lib/features/church_schedule/data/models/assignment_request.dart
class AssignmentRequest {
  final int scheduleId;
  final int roleId;
  final String userId;

  AssignmentRequest({required this.scheduleId, required this.roleId, required this.userId});

  Map<String, dynamic> toJson() {
    return {
      'scheduleId': scheduleId,
      'roleId': roleId,
      'userId': userId,
    };
  }
}

// مدل برای داده‌های صفحه ویرایش
class EditScheduleData {
  final ChurchSchedule schedule;
  final List<ApplicationUser> availableUsers;
  final List<ChurchRole> roles;

  EditScheduleData({required this.schedule, required this.availableUsers, required this.roles});
}