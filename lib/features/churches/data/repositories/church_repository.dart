import 'package:dio/dio.dart';
import '../../../../core/networking/dio_client.dart';
import '../models/church.dart';

class ChurchRepository {
  Future<List<Church>> getChurches() async {
  try {
    final response = await DioClient.instance.get('/api/churches');
    
    // این خط رو اضافه کن تا ساختار دقیق JSON رو ببینیم
    print('پاسخ خام API کلیساها: ${response.data.runtimeType} - ${response.data}');

    if (response.statusCode == 200) {
      final data = response.data;

      if (data is List) {
        return data.map((json) => Church.fromJson(json)).toList();
      } else if (data is Map) {
        print('پاسخ Map بود - کلیدها: ${data.keys}');
        if (data['data'] is List) {
          return (data['data'] as List).map((json) => Church.fromJson(json)).toList();
        }
      }

      throw Exception('فرمت پاسخ نامعتبر');
    }

    throw Exception('خطا: ${response.statusCode}');
  } on DioException catch (e) {
    print('DioException در کلیساها: ${e.response?.data}');
    throw Exception(e.message);
  }
}
  Future<Church> createChurch(Church church) async {
    try {
      final response = await DioClient.instance.post(
        '/api/churches',
        data: church.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Church.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('خطا در ایجاد کلیسا: ${response.statusMessage}');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'خطا در ارتباط');
    }
  }

  Future<void> updateChurch(int id, Church church) async {
    try {
      final response = await DioClient.instance.put(
        '/api/churches/$id',
        data: church.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      throw Exception('خطا در ویرایش کلیسا: ${response.statusMessage}');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'خطا در ارتباط');
    }
  }

  Future<void> deleteChurch(int id) async {
  try {
    print('ارسال DELETE به /api/churches/$id');
    final response = await DioClient.instance.delete('/api/churches/$id');
    print('پاسخ حذف: status=${response.statusCode} - data=${response.data}');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('خطا در حذف: status ${response.statusCode}');
    }
  } on DioException catch (e) {
    print('DioException در حذف: status=${e.response?.statusCode} - data=${e.response?.data}');
    throw Exception(e.response?.data['message'] ?? e.message ?? 'خطا در ارتباط');
  }
}
}