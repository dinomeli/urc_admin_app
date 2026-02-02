// lib/features/schedules/data/models/edit_schedule_response.dart
import 'package:json_annotation/json_annotation.dart';

part 'edit_schedule_response.g.dart';

@JsonSerializable()
class EditScheduleResponse {
  @JsonKey(name: 'Schedule')
  final ChurchScheduleEditDto schedule;

  @JsonKey(name: 'AvailableUsers')
  final List<AvailableUserDto> availableUsers;

  @JsonKey(name: 'Roles')
  final List<ChurchRoleSimpleDto> roles;

  EditScheduleResponse({
    required this.schedule,
    required this.availableUsers,
    required this.roles,
  });

  factory EditScheduleResponse.fromJson(Map<String, dynamic> json) =>
      _$EditScheduleResponseFromJson(json);
}

@JsonSerializable()
class ChurchScheduleEditDto {
  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'ServiceDate')
  final DateTime serviceDate;

  @JsonKey(name: 'IsConfirmed')
  final bool isConfirmed;

  @JsonKey(name: 'Assignments')
  final List<ChurchScheduleAssignmentEditDto> assignments;

  ChurchScheduleEditDto({
    required this.id,
    required this.serviceDate,
    required this.isConfirmed,
    required this.assignments,
  });

  // getterهای امن (برای جلوگیری از null crash)
  int get safeAssignmentsCount => assignments.length;
  List<ChurchScheduleAssignmentEditDto> get safeAssignments => assignments;

  factory ChurchScheduleEditDto.fromJson(Map<String, dynamic> json) =>
      _$ChurchScheduleEditDtoFromJson(json);
}

@JsonSerializable()
class ChurchScheduleAssignmentEditDto {
  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'ChurchRoleId')
  final int churchRoleId;

  @JsonKey(name: 'RoleName')  // ← فقط RoleName وجود دارد (نه En/Fa جدا)
  final String roleName;

  @JsonKey(name: 'UserId')
  final String userId;

  @JsonKey(name: 'UserFullName')
  final String userFullName;

  @JsonKey(name: 'Status')
  final String? status;

  ChurchScheduleAssignmentEditDto({
    required this.id,
    required this.churchRoleId,
    required this.roleName,
    required this.userId,
    required this.userFullName,
    this.status,
  });

  factory ChurchScheduleAssignmentEditDto.fromJson(Map<String, dynamic> json) =>
      _$ChurchScheduleAssignmentEditDtoFromJson(json);
}

@JsonSerializable()
class AvailableUserDto {
  @JsonKey(name: 'Id')
  final String id;

  @JsonKey(name: 'FullName')
  final String fullName;

  @JsonKey(name: 'Email')
  final String? email;

  AvailableUserDto({
    required this.id,
    required this.fullName,
    this.email,
  });

  factory AvailableUserDto.fromJson(Map<String, dynamic> json) =>
      _$AvailableUserDtoFromJson(json);
}

@JsonSerializable()
class ChurchRoleSimpleDto {
  @JsonKey(name: 'Id')
  final int id;

  @JsonKey(name: 'NameEn')
  final String nameEn;

  @JsonKey(name: 'NameFa')
  final String? nameFa;

  @JsonKey(name: 'IsActive')
  final bool isActive;

  ChurchRoleSimpleDto({
    required this.id,
    required this.nameEn,
    this.nameFa,
    required this.isActive,
  });

  factory ChurchRoleSimpleDto.fromJson(Map<String, dynamic> json) =>
      _$ChurchRoleSimpleDtoFromJson(json);
}