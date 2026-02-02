// lib/features/users/data/services/church_role_api_service.dart
import 'package:dio/dio.dart';
import '../models/church_role_dto.dart';
import '../../../../core/networking/dio_client.dart';
class ChurchRoleApiService {
  final Dio _dio = DioClient.instance.dio;

  //ChurchRoleApiService(this._dio);

  Future<List<ChurchRoleDto>> getAll() async {
    final response = await _dio.get('/api/church-roles');
    
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
    return (response.data['data'] as List)
        .map((json) => ChurchRoleDto.fromJson(json))
        .toList();
  }

  Future<ChurchRoleDto> getById(int id) async {
    final response = await _dio.get('/api/church-roles/$id');
    return ChurchRoleDto.fromJson(response.data['data']);
  }

  Future<bool> create(ChurchRoleDto dto) async {
    try {
      await _dio.post('/api/church-roles', data: dto.toJson());
      return true;
    } catch (e) {
      print('خطا در ایجاد نقش: $e');
      return false;
    }
  }

  Future<bool> update(int id, ChurchRoleDto dto) async {
    try {
      await _dio.put('/api/church-roles/$id', data: dto.toJson());
      return true;
    } catch (e) {
      print('خطا در ویرایش نقش: $e');
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _dio.delete('/api/church-roles/$id');
      return true;
    } catch (e) {
      print('خطا در حذف نقش: $e');
      return false;
    }
  }
}