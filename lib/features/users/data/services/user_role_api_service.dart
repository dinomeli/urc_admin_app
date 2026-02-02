// lib/features/users/data/services/user_role_api_service.dart
import 'package:dio/dio.dart';
import '../models/user_role_dto.dart';
import '../models/user_dto.dart';
import '../../../../core/networking/dio_client.dart';
class UserRoleApiService {
  final Dio _dio=DioClient.instance.dio;

  //UserRoleApiService(this._dio);

  Future<List<UserRoleDto>> getAllAssignments() async {
    final response = await _dio.get('/api/user-roles');
    return (response.data['data'] as List)
        .map((json) => UserRoleDto.fromJson(json))
        .toList();
  }
  Future<List<Map<String, dynamic>>> getChurchRoles() async {
  try {
    final response = await _dio.get('/api/church-roles'); // آدرس دقیق را با بک‌اِند چک کنید
    return List<Map<String, dynamic>>.from(response.data['data']);
  } catch (e) {
    print('خطا در دریافت نقش‌های کلیسا: $e');
    return [];
  }
}
Future<List<UserDto>> getAllUsers() async {
  final response = await _dio.get('/api/users'); // فرض بر این است که این اندپوینت وجود دارد
  return (response.data['data'] as List)
      .map((json) => UserDto.fromJson(json))
      .toList();
}
  Future<List<UserRoleDto>> getUserRoles(String userId) async {
    final response = await _dio.get('/api/user-roles/user/$userId');
    return (response.data['data'] as List)
        .map((json) => UserRoleDto.fromJson(json))
        .toList();
  }

  Future<bool> assignRole(String userId, int roleId, double weight) async {
    try {
      await _dio.post('/api/user-roles', data: {
        'userId': userId,
        'roleId': roleId,
        'weight': weight,
      });
      return true;
    } catch (e) {
      print('خطا در تخصیص نقش: $e');
      return false;
    }
  }

  Future<bool> updateWeight(String userId, int roleId, double weight) async {
    try {
      await _dio.put('/api/user-roles/weight', data: {
        'userId': userId,
        'roleId': roleId,
        'weight': weight,
      });
      return true;
    } catch (e) {
      print('خطا در بروزرسانی وزن: $e');
      return false;
    }
  }

  Future<bool> removeRole(String userId, int roleId) async {
    try {
      await _dio.delete('/api/user-roles', data: {
        'userId': userId,
        'roleId': roleId,
      });
      return true;
    } catch (e) {
      print('خطا در حذف نقش: $e');
      return false;
    }
  }
}