import 'package:dio/dio.dart';
import '../models/user_dto.dart';
import '../../../../core/networking/dio_client.dart';
import 'dart:math'; // ← این خط رو اضافه نکردی
class UserApiService {
   final Dio _dio = DioClient.instance.dio; // مستقیم singleton استفاده کن

  Future<List<UserDto>> getUsers() async {
  try {
    final response = await _dio.get('/api/users');

    print('کد وضعیت: ${response.statusCode}');
    print('نوع محتوا: ${response.headers['content-type']}');

    if (response.statusCode != 200) {
      print('پاسخ غیر ۲۰۰: ${response.data}');
      throw DioException(requestOptions: response.requestOptions);
    }

    final json = response.data as Map<String, dynamic>?;
    if (json == null || json['success'] != true) {
      throw Exception('پاسخ ناموفق: ${json?['message']}');
    }

    final dataList = json['data'] as List<dynamic>?;
    if (dataList == null) {
      throw Exception('فیلد data لیست نیست');
    }

   return dataList.map((item) {
  try {
    return UserDto.fromJson(item as Map<String, dynamic>);
  } catch (parseError) {
    // به جای توقف کل برنامه، لاگ بگیرید و یک آبجکت موقت بسازید
    print('خطا در پارس کاربر با شناسه: ${item['Id']}'); 
    return UserDto(
      id: item['Id']?.toString() ?? 'unknown',
      firstName: 'Error',
      lastName: 'Parsing',
      email: item['Email']?.toString() ?? 'error@mail.com',
    );
  }
}).toList();
  } catch (e) {
    print('خطا کامل در getUsers: $e');
    rethrow;
  }
}
  // بقیه متدها مشابه، همه از _dio استفاده کن


  Future<UserDto> getUserById(String id) async {
    final response = await _dio.get('/api/users/$id');
    return UserDto.fromJson(response.data['data']);
  }

  Future<void> createUser(CreateUserDto dto) async {
    await _dio.post('/api/users', data: dto.toJson());
  }

  Future<void> updateUser(String id, UpdateUserDto dto) async {
    await _dio.put('/api/users/$id', data: dto.toJson());
  }

  Future<void> updateRoles(String id, List<String> roles) async {
    await _dio.post('/api/users/$id/roles', data: {'roles': roles});
  }

  Future<void> deleteUser(String id) async {
    await _dio.delete('/api/users/$id');
  }
}