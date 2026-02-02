import 'package:dio/dio.dart';
import '../models/my_schedule_dto.dart';
import '../../../../core/networking/dio_client.dart';
import 'package:flutter/foundation.dart'; // برای حل مشکل debugPrint
import '../models/my_schedule_dto.dart';

class MyScheduleApiService {
  // استفاده از کلاینت سراسری پروژه
  MyScheduleApiService(this._dio); 
final Dio _dio;
  /// دریافت لیست برنامه‌ها
  /// اگر [userId] پاس داده شود (برای ادمین)، برنامه آن کاربر را می‌آورد
  /// اگر نال باشد، برنامه خود کاربر لاگین شده را می‌آورد
  Future<List<MyScheduleDto>> getSchedules({String? userId}) async {
    final String url = userId == null 
        ? '/api/my-schedule' 
        : '/api/my-schedule?userId=$userId';
    
    final response = await _dio.get(url);
    
    // مپ کردن داده‌ها بر اساس ساختار PascalCase سرور
    return (response.data['data'] as List)
        .map((json) => MyScheduleDto.fromJson(json))
        .toList();
  }

// tr: دریافت برنامه هفتگی کاربر فعلی یا کاربر مشخص
// en: Get weekly plan for current user or specific user



  // features/schedules/data/services/my_schedule_api_service.dart

Future<List<dynamic>> getWeeklyPlan(String? userId) async {
  try {
    // ایجاد یک Map برای پارامترها
    final Map<String, dynamic> queryParams = {};
    
    // فقط اگر userId مقدار داشت و واقعاً پر بود، آن را به پارامترها اضافه کن
    if (userId != null && userId.trim().isNotEmpty) {
      queryParams['userId'] = userId;
    }

    final response = await _dio.get(
      '/api/churchschedules/weekly-plan', 
      // اگر queryParams خالی باشد، سرور طبق منطق جدید ما کل برنامه را می‌آورد
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.statusCode == 200) {
      // استخراج لیست از بدنه پاسخ سرور
      return response.data['data'] as List<dynamic>? ?? [];
    }
    
    return [];
  } on DioException catch (e) {
    // لاگ دقیق برای عیب‌یابی راحت‌تر
    print("API Error Details: ${e.response?.data}");
    print("Full Path: ${e.requestOptions.uri}");
    rethrow;
  } catch (e) {
    print("Unknown Error: $e");
    rethrow;
  }
}

  // متد جدید برای تایید یا رد حضور
  Future<bool> updateStatus(int assignmentId, String newStatus) async {
    final response = await _dio.post('/api/my-schedule/update-status', data: {
      'AssignmentId': assignmentId,
      'Status': newStatus,
    });
    return response.statusCode == 200;
  }

  /// ثبت حضور/غیبت توسط خود کاربر
  Future<bool> markAttendance(int assignmentId, bool isPresent) async {
    try {
      await _dio.post('/api/my-schedule/mark', data: {
        'assignmentId': assignmentId,
        'isPresent': isPresent,
      });
      return true;
    } catch (e) {
      debugPrint('Error marking attendance: $e');
      return false;
    }
  }

  /// اعلام غیبت سریع
  Future<bool> markAbsent(int assignmentId) async {
    try {
      await _dio.post('/api/my-schedule/absent', data: {
        'assignmentId': assignmentId,
      });
      return true;
    } catch (e) {
      debugPrint('Error marking absent: $e');
      return false;
    }
  }
}