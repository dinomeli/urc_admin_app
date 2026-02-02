// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'church_role_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChurchRoleDto _$ChurchRoleDtoFromJson(Map<String, dynamic> json) =>
    ChurchRoleDto(
      id: (json['Id'] as num).toInt(),
      nameEn: json['NameEn'] as String,
      nameFa: json['NameFa'] as String?,
      isActive: json['IsActive'] as bool,
      requiredCountPerService: (json['RequiredCountPerService'] as num).toInt(),
      requiredMen: (json['RequiredMen'] as num?)?.toInt() ?? 0,
      requiredWomen: (json['RequiredWomen'] as num?)?.toInt() ?? 0,
      useWeight: json['UseWeight'] as bool,
      isNonRepeatable: json['IsNonRepeatable'] as bool,
    );

Map<String, dynamic> _$ChurchRoleDtoToJson(ChurchRoleDto instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'NameEn': instance.nameEn,
      'NameFa': instance.nameFa,
      'IsActive': instance.isActive,
      'RequiredCountPerService': instance.requiredCountPerService,
      'RequiredMen': instance.requiredMen,
      'RequiredWomen': instance.requiredWomen,
      'UseWeight': instance.useWeight,
      'IsNonRepeatable': instance.isNonRepeatable,
    };
