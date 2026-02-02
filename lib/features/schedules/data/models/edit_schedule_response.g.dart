// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_schedule_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditScheduleResponse _$EditScheduleResponseFromJson(
  Map<String, dynamic> json,
) => EditScheduleResponse(
  schedule: ChurchScheduleEditDto.fromJson(
    json['Schedule'] as Map<String, dynamic>,
  ),
  availableUsers: (json['AvailableUsers'] as List<dynamic>)
      .map((e) => AvailableUserDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  roles: (json['Roles'] as List<dynamic>)
      .map((e) => ChurchRoleSimpleDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$EditScheduleResponseToJson(
  EditScheduleResponse instance,
) => <String, dynamic>{
  'Schedule': instance.schedule,
  'AvailableUsers': instance.availableUsers,
  'Roles': instance.roles,
};

ChurchScheduleEditDto _$ChurchScheduleEditDtoFromJson(
  Map<String, dynamic> json,
) => ChurchScheduleEditDto(
  id: (json['Id'] as num).toInt(),
  serviceDate: DateTime.parse(json['ServiceDate'] as String),
  isConfirmed: json['IsConfirmed'] as bool,
  assignments: (json['Assignments'] as List<dynamic>)
      .map(
        (e) =>
            ChurchScheduleAssignmentEditDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

Map<String, dynamic> _$ChurchScheduleEditDtoToJson(
  ChurchScheduleEditDto instance,
) => <String, dynamic>{
  'Id': instance.id,
  'ServiceDate': instance.serviceDate.toIso8601String(),
  'IsConfirmed': instance.isConfirmed,
  'Assignments': instance.assignments,
};

ChurchScheduleAssignmentEditDto _$ChurchScheduleAssignmentEditDtoFromJson(
  Map<String, dynamic> json,
) => ChurchScheduleAssignmentEditDto(
  id: (json['Id'] as num).toInt(),
  churchRoleId: (json['ChurchRoleId'] as num).toInt(),
  roleName: json['RoleName'] as String,
  userId: json['UserId'] as String,
  userFullName: json['UserFullName'] as String,
  status: json['Status'] as String?,
);

Map<String, dynamic> _$ChurchScheduleAssignmentEditDtoToJson(
  ChurchScheduleAssignmentEditDto instance,
) => <String, dynamic>{
  'Id': instance.id,
  'ChurchRoleId': instance.churchRoleId,
  'RoleName': instance.roleName,
  'UserId': instance.userId,
  'UserFullName': instance.userFullName,
  'Status': instance.status,
};

AvailableUserDto _$AvailableUserDtoFromJson(Map<String, dynamic> json) =>
    AvailableUserDto(
      id: json['Id'] as String,
      fullName: json['FullName'] as String,
      email: json['Email'] as String?,
    );

Map<String, dynamic> _$AvailableUserDtoToJson(AvailableUserDto instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'FullName': instance.fullName,
      'Email': instance.email,
    };

ChurchRoleSimpleDto _$ChurchRoleSimpleDtoFromJson(Map<String, dynamic> json) =>
    ChurchRoleSimpleDto(
      id: (json['Id'] as num).toInt(),
      nameEn: json['NameEn'] as String,
      nameFa: json['NameFa'] as String?,
      isActive: json['IsActive'] as bool,
    );

Map<String, dynamic> _$ChurchRoleSimpleDtoToJson(
  ChurchRoleSimpleDto instance,
) => <String, dynamic>{
  'Id': instance.id,
  'NameEn': instance.nameEn,
  'NameFa': instance.nameFa,
  'IsActive': instance.isActive,
};
