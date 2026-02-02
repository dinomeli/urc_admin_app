// lib/features/church_schedule/data/models/church_schedule_list_dto.dart
import 'package:json_annotation/json_annotation.dart';

part 'church_schedule_list_dto.g.dart';



@JsonSerializable()
class ChurchScheduleListDto {
  @JsonKey(name: 'Id')
  final int? id;

  @JsonKey(name: 'ServiceDate')
  final DateTime? serviceDate;

  @JsonKey(name: 'IsConfirmed', defaultValue: false)
  final bool? isConfirmed;

  @JsonKey(name: 'AssignmentsCount', defaultValue: 0)
  final int? assignmentsCount;

  @JsonKey(name: 'Assignments', defaultValue: [])
  final List<AssignmentDto>? assignments;

  ChurchScheduleListDto({
    this.id,
    this.serviceDate,
    this.isConfirmed,
    this.assignmentsCount,
    this.assignments,
  });

  factory ChurchScheduleListDto.fromJson(Map<String, dynamic> json) =>
      _$ChurchScheduleListDtoFromJson(json);

  // برای استفاده راحت در UI
  int get safeAssignmentsCount => assignmentsCount ?? 0;
  List<AssignmentDto> get safeAssignments => assignments ?? [];
}

@JsonSerializable()
class AssignmentDto {
  @JsonKey(name: 'Id')
  final int? id;

  @JsonKey(name: 'ChurchRoleId', defaultValue: 0)
  final int? churchRoleId;

  @JsonKey(name: 'RoleNameEn', defaultValue: '')
  final String? roleNameEn;

  @JsonKey(name: 'RoleNameFa', defaultValue: '')
  final String? roleNameFa;

  @JsonKey(name: 'UserId', defaultValue: '')
  final String? userId;

  @JsonKey(name: 'UserFullName', defaultValue: '')
  final String? userFullName;

  @JsonKey(name: 'Status', defaultValue: 'Pending')
  final String? status;

  AssignmentDto({
    this.id,
    this.churchRoleId,
    this.roleNameEn,
    this.roleNameFa,
    this.userId,
    this.userFullName,
    this.status,
  });

  factory AssignmentDto.fromJson(Map<String, dynamic> json) =>
      _$AssignmentDtoFromJson(json);
}