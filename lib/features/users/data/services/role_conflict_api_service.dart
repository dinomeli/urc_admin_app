
import 'package:dio/dio.dart';
import '../models/role_conflict_dto.dart';
import '../../../../core/networking/dio_client.dart';

class RoleConflictApiService {
  final Dio _dio=DioClient.instance.dio;

  //RoleConflictApiService(this._dio);

  Future<List<RoleConflictDto>> getAll() async {
    final response = await _dio.get('/api/role-conflicts');
    return (response.data['data'] as List)
        .map((json) => RoleConflictDto.fromJson(json))
        .toList();
  }

  Future<RoleConflictDto> getById(int id) async {
    final response = await _dio.get('/api/role-conflicts/$id');
    return RoleConflictDto.fromJson(response.data['data']);
  }

  Future<bool> create(RoleConflictDto dto) async {
    try {
      await _dio.post('/api/role-conflicts', data: dto.toJson());
      return true;
    } catch (e) {
      print('خطا در ایجاد تضاد نقش: $e');
      return false;
    }
  }

  Future<bool> update(int id, RoleConflictDto dto) async {
    try {
      await _dio.put('/api/role-conflicts/$id', data: dto.toJson());
      return true;
    } catch (e) {
      print('خطا در ویرایش تضاد نقش: $e');
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _dio.delete('/api/role-conflicts/$id');
      return true;
    } catch (e) {
      print('خطا در حذف تضاد نقش: $e');
      return false;
    }
  }
}