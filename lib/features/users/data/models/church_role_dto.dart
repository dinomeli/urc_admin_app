import 'package:json_annotation/json_annotation.dart';

part 'church_role_dto.g.dart';

// این خط بسیار مهم است تا فیلدهای سرور (PascalCase) را بشناسد
@JsonSerializable(fieldRename: FieldRename.pascal)
class ChurchRoleDto {
  final int id;
  final String nameEn;
  final String? nameFa;
  final bool isActive;
  final int requiredCountPerService;
  final int requiredMen; // فیلد جدید
  final int requiredWomen; // فیلد جدید
  final bool useWeight;
  final bool isNonRepeatable;

  ChurchRoleDto({
    required this.id,
    required this.nameEn,
    this.nameFa,
    required this.isActive,
    required this.requiredCountPerService,
    this.requiredMen = 0, // پیش‌فرض صفر
    this.requiredWomen = 0, // پیش‌فرض صفر
    required this.useWeight,
    required this.isNonRepeatable,
  });

  factory ChurchRoleDto.fromJson(Map<String, dynamic> json) => _$ChurchRoleDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ChurchRoleDtoToJson(this);
}