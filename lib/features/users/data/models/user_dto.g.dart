// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
  id: json['Id'] as String,
  userName: json['UserName'] as String?,
  email: json['Email'] as String?,
  firstName: json['FirstName'] as String?,
  lastName: json['LastName'] as String?,
  phone: json['Phone'],
  gender: json['Gender'] as String?,
  address: json['Address'] as String?,
  isActive: json['IsActive'] as bool?,
  roles: (json['Roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
  'Id': instance.id,
  'UserName': instance.userName,
  'Email': instance.email,
  'FirstName': instance.firstName,
  'LastName': instance.lastName,
  'Phone': instance.phone,
  'Gender': instance.gender,
  'Address': instance.address,
  'IsActive': instance.isActive,
  'Roles': instance.roles,
};

CreateUserDto _$CreateUserDtoFromJson(Map<String, dynamic> json) =>
    CreateUserDto(
      email: json['Email'] as String,
      password: json['Password'] as String,
      firstName: json['FirstName'] as String,
      lastName: json['LastName'] as String,
      phone: json['Phone'] as String,
      gender: json['Gender'] as String?,
      address: json['Address'] as String,
    );

Map<String, dynamic> _$CreateUserDtoToJson(CreateUserDto instance) =>
    <String, dynamic>{
      'Email': instance.email,
      'Password': instance.password,
      'FirstName': instance.firstName,
      'LastName': instance.lastName,
      'Phone': instance.phone,
      'Gender': instance.gender,
      'Address': instance.address,
    };

UpdateUserDto _$UpdateUserDtoFromJson(Map<String, dynamic> json) =>
    UpdateUserDto(
      email: json['Email'] as String,
      firstName: json['FirstName'] as String,
      lastName: json['LastName'] as String,
      phone: json['Phone'] as String,
      gender: json['Gender'] as String?,
      address: json['Address'] as String,
      isActive: json['IsActive'] as bool,
    );

Map<String, dynamic> _$UpdateUserDtoToJson(UpdateUserDto instance) =>
    <String, dynamic>{
      'Email': instance.email,
      'FirstName': instance.firstName,
      'LastName': instance.lastName,
      'Phone': instance.phone,
      'Gender': instance.gender,
      'Address': instance.address,
      'IsActive': instance.isActive,
    };

UpdateUserRolesDto _$UpdateUserRolesDtoFromJson(Map<String, dynamic> json) =>
    UpdateUserRolesDto(
      roles: (json['Roles'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$UpdateUserRolesDtoToJson(UpdateUserRolesDto instance) =>
    <String, dynamic>{'Roles': instance.roles};
