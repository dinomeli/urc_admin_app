// lib/features/schedules/data/services/role_pair_api_service.dart
import 'package:dio/dio.dart';
import '../models/role_pair_dto.dart';
import '../../../../core/networking/dio_client.dart';
class RolePairApiService {
  final Dio _dio=DioClient.instance.dio;

  //RolePairApiService(this._dio);

  Future<List<RolePairDto>> getAll() async {
    final response = await _dio.get('/api/role-pairs');
    return (response.data['data'] as List)
        .map((json) => RolePairDto.fromJson(json))
        .toList();
  }

  Future<RolePairDto> getById(int id) async {
    final response = await _dio.get('/api/role-pairs/$id');
    return RolePairDto.fromJson(response.data['data']);
  }

  Future<bool> create(RolePairDto dto) async {
    try {
      await _dio.post('/api/role-pairs', data: dto.toJson());
      return true;
    } catch (e) {
      print('خطا در ایجاد جفت نقش: $e');
      return false;
    }
  }

  Future<bool> update(int id, RolePairDto dto) async {
    try {
      await _dio.put('/api/role-pairs/$id', data: dto.toJson());
      return true;
    } catch (e) {
      print('خطا در ویرایش جفت نقش: $e');
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _dio.delete('/api/role-pairs/$id');
      return true;
    } catch (e) {
      print('خطا در حذف جفت نقش: $e');
      return false;
    }
  }
}