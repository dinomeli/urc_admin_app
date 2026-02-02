import 'package:dio/dio.dart';
import '../models/menu_item_dto.dart';

class MenuApiService {
  final Dio _dio;

  // سازنده اصلاح شده: فقط یک بار و به صورت صحیح
  MenuApiService(this._dio) {
    // تنظیم برای اینکه استاتوس‌های زیر 500 به عنوان خطا (Exception) پرتاب نشوند
    // تا بتوانیم کدهایی مثل 401 را دستی مدیریت کنیم
    _dio.options.validateStatus = (status) => status != null && status < 500;
  }

  Future<List<MenuItemDto>> getAll() async {
    try {
      final response = await _dio.get('/api/menu-items');
      
      if (response.statusCode == 200) {
        // استخراج دیتا از فیلد data (طبق خروجی استاندارد API شما)
        final List rawData = response.data['data'] ?? [];
        return rawData.map((json) => MenuItemDto.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception("نیاز به ورود مجدد (401)");
      } else {
        throw Exception("خطا در دریافت اطلاعات: ${response.statusCode}");
      }
    } catch (e) {
      print('MenuApiService Error: $e');
      rethrow;
    }
  }

  Future<bool> create(MenuItemDto dto) async {
    try {
      final response = await _dio.post('/api/menu-items', data: dto.toJson());
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> update(int id, MenuItemDto dto) async {
    try {
      final response = await _dio.put('/api/menu-items/$id', data: dto.toJson());
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      final response = await _dio.delete('/api/menu-items/$id');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}