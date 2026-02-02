import 'package:dio/dio.dart';
import '../../../../core/networking/dio_client.dart';
import '../models/church_service_setting.dart';

class ChurchSettingsRepository {
  Future<List<ChurchServiceSetting>> getAllSettings() async {
  try {
    final response = await DioClient.instance.get('/api/church-settings');
    if (response.statusCode == 200) {
      final data = response.data as List<dynamic>;
      return data.map((json) => ChurchServiceSetting.fromJson(json)).toList();
    }
    throw Exception('خطای سرور');
  } on DioException catch (e) {
    throw Exception(e.response?.data['message'] ?? 'خطای شبکه');
  }
}
  Future<void> createSetting(ChurchServiceSetting setting) async {
    try {
      final response = await DioClient.instance.post(
        '/api/church-settings',
        data: setting.toJson(),
      );
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('خطا در ایجاد تنظیمات: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'خطا در ارتباط');
    }
  }

  Future<void> updateSetting(int id, ChurchServiceSetting setting) async {
    try {
      final response = await DioClient.instance.put(
        '/api/church-settings/$id',
        data: setting.toJson(),
      );
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('خطا در ویرایش تنظیمات: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'خطا در ارتباط');
    }
  }

  Future<void> deleteSetting(int id) async {
    try {
      final response = await DioClient.instance.delete('/api/church-settings/$id');
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('خطا در حذف تنظیمات: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'خطا در ارتباط');
    }
  }
}