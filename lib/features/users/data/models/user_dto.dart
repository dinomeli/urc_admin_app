import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.pascal)
class UserDto {
  final String id;
  final String? userName;
  final String? email;
  final String? firstName;
  final String? lastName;
  
  @JsonKey(name: 'Phone')
  final dynamic phone; 
  
  final String? gender;
  final String? address;
  final bool? isActive;
  final List<String>? roles;

  UserDto({
    required this.id,
    this.userName,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.gender,
    this.address,
    this.isActive,
    this.roles,
  });

  // --- گترهای محاسباتی برای رفع خطاهای UI ---
  
  String get initial => (firstName != null && firstName!.isNotEmpty) 
      ? firstName![0].toUpperCase() 
      : (userName != null && userName!.isNotEmpty ? userName![0].toUpperCase() : "?");

  String get fullName => '${firstName ?? ""} ${lastName ?? ""}'.trim().isEmpty 
      ? (userName ?? "Unknown User") 
      : '${firstName ?? ""} ${lastName ?? ""}'.trim();

  String get phoneString => phone?.toString() ?? '---';

  String get genderString => gender ?? 'نامشخص';

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class CreateUserDto {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String phone;
  final String? gender;
  final String address;

  CreateUserDto({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.gender,
    required this.address,
  });

  factory CreateUserDto.fromJson(Map<String, dynamic> json) => _$CreateUserDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CreateUserDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class UpdateUserDto {
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String? gender;
  final String address;
  final bool isActive;

  UpdateUserDto({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.gender,
    required this.address,
    required this.isActive,
  });

  factory UpdateUserDto.fromJson(Map<String, dynamic> json) => _$UpdateUserDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateUserDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class UpdateUserRolesDto {
  final List<String> roles;

  UpdateUserRolesDto({required this.roles});

  factory UpdateUserRolesDto.fromJson(Map<String, dynamic> json) => _$UpdateUserRolesDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateUserRolesDtoToJson(this);
}