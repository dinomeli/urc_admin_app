// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'church_schedule_list_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChurchScheduleListDto _$ChurchScheduleListDtoFromJson(
  Map<String, dynamic> json,
) => ChurchScheduleListDto(
  id: (json['Id'] as num?)?.toInt(),
  serviceDate: json['ServiceDate'] == null
      ? null
      : DateTime.parse(json['ServiceDate'] as String),
  isConfirmed: json['IsConfirmed'] as bool? ?? false,
  assignmentsCount: (json['AssignmentsCount'] as num?)?.toInt() ?? 0,
  assignments:
      (json['Assignments'] as List<dynamic>?)
          ?.map((e) => AssignmentDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$ChurchScheduleListDtoToJson(
  ChurchScheduleListDto instance,
) => <String, dynamic>{
  'Id': instance.id,
  'ServiceDate': instance.serviceDate?.toIso8601String(),
  'IsConfirmed': instance.isConfirmed,
  'AssignmentsCount': instance.assignmentsCount,
  'Assignments': instance.assignments,
};

AssignmentDto _$AssignmentDtoFromJson(Map<String, dynamic> json) =>
    AssignmentDto(
      id: (json['Id'] as num?)?.toInt(),
      churchRoleId: (json['ChurchRoleId'] as num?)?.toInt() ?? 0,
      roleNameEn: json['RoleNameEn'] as String? ?? '',
      roleNameFa: json['RoleNameFa'] as String? ?? '',
      userId: json['UserId'] as String? ?? '',
      userFullName: json['UserFullName'] as String? ?? '',
      status: json['Status'] as String? ?? 'Pending',
    );

Map<String, dynamic> _$AssignmentDtoToJson(AssignmentDto instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'ChurchRoleId': instance.churchRoleId,
      'RoleNameEn': instance.roleNameEn,
      'RoleNameFa': instance.roleNameFa,
      'UserId': instance.userId,
      'UserFullName': instance.userFullName,
      'Status': instance.status,
    };
