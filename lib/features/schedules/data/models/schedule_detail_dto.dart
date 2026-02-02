import 'package:json_annotation/json_annotation.dart';

part 'schedule_detail_dto.g.dart';

@JsonSerializable()
class ScheduleDetailDto {
  final int id;
  final String serviceDate;
  final bool isConfirmed;
  final List<AssignmentDetailDto> assignments;

  ScheduleDetailDto({
    required this.id,
    required this.serviceDate,
    required this.isConfirmed,
    required this.assignments,
  });

  factory ScheduleDetailDto.fromJson(Map<String, dynamic> json) => _$ScheduleDetailDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleDetailDtoToJson(this);
}

@JsonSerializable()
class AssignmentDetailDto {
  final String userFullName;
  final String roleNameEn;
  final String? roleNameFa;
  final String status;

  AssignmentDetailDto({
    required this.userFullName,
    required this.roleNameEn,
    this.roleNameFa,
    required this.status,
  });

  factory AssignmentDetailDto.fromJson(Map<String, dynamic> json) => _$AssignmentDetailDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AssignmentDetailDtoToJson(this);
}