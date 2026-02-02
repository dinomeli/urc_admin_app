// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleDetailDto _$ScheduleDetailDtoFromJson(Map<String, dynamic> json) =>
    ScheduleDetailDto(
      id: (json['id'] as num).toInt(),
      serviceDate: json['serviceDate'] as String,
      isConfirmed: json['isConfirmed'] as bool,
      assignments: (json['assignments'] as List<dynamic>)
          .map((e) => AssignmentDetailDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ScheduleDetailDtoToJson(ScheduleDetailDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serviceDate': instance.serviceDate,
      'isConfirmed': instance.isConfirmed,
      'assignments': instance.assignments,
    };

AssignmentDetailDto _$AssignmentDetailDtoFromJson(Map<String, dynamic> json) =>
    AssignmentDetailDto(
      userFullName: json['userFullName'] as String,
      roleNameEn: json['roleNameEn'] as String,
      roleNameFa: json['roleNameFa'] as String?,
      status: json['status'] as String,
    );

Map<String, dynamic> _$AssignmentDetailDtoToJson(
  AssignmentDetailDto instance,
) => <String, dynamic>{
  'userFullName': instance.userFullName,
  'roleNameEn': instance.roleNameEn,
  'roleNameFa': instance.roleNameFa,
  'status': instance.status,
};
