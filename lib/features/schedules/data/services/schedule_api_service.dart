// lib/features/schedules/data/services/schedule_api_service.dart
import 'package:dio/dio.dart';

import '../../data/models/church_schedule_list_dto.dart';
import '../../data/models/edit_schedule_response.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/networking/dio_client.dart';

class ScheduleApiService {
  final Dio _dio = DioClient.instance.dio; // مستقیم singleton استفاده کن

  Future<List<ChurchScheduleListDto>> getSchedules() async {
    try {
      final response = await _dio.get(ApiConstants.churchSchedules);
      print('لیست برنامه‌ها - وضعیت: ${response.statusCode}');
      return (response.data as List)
          .map((json) => ChurchScheduleListDto.fromJson(json))
          .toList();
    } catch (e) {
      print('خطا در getSchedules: $e');
      rethrow;
    }
  }

  Future<EditScheduleResponse> getScheduleForEdit(int id) async {
    try {
      final path = ApiConstants.scheduleById.replaceAll('{id}', id.toString());
      final response = await _dio.get(path);
      print('ویرایش برنامه $id - وضعیت: ${response.statusCode}');
      return EditScheduleResponse.fromJson(response.data);
    } catch (e) {
      print('خطا در getScheduleForEdit: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generateSchedules({
  int weeksCount = 8,
  bool includeCommunion = true,
}) async {
  try {
    final path = ApiConstants.generateSchedules;  // باید '/generate' باشه
    print('درخواست تولید به: $path با متد POST');
    print('پارامترها: weeksCount=$weeksCount, includeCommunion=$includeCommunion');

    final response = await _dio.post(
      path,
      queryParameters: {
        'weeksCount': weeksCount,
        'includeCommunion': includeCommunion,
      },
    );

    print('تولید موفق - وضعیت: ${response.statusCode}');
    print('پاسخ سرور: ${response.data}');
    return response.data as Map<String, dynamic>;
  } catch (e) {
    if (e is DioException) {
      print('خطا در تولید: وضعیت ${e.response?.statusCode}');
      print('پاسخ سرور: ${e.response?.data}');
      print('URL کامل: ${e.requestOptions.uri}');
      print('متد: ${e.requestOptions.method}');
    }
    rethrow;
  }
}

  Future<void> updateAssignment(int assignmentId, String userId) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.assignment}/$assignmentId',
        data: userId,
      );
      print('به‌روزرسانی تخصیص - وضعیت: ${response.statusCode}');
    } catch (e) {
      print('خطا در updateAssignment: $e');
      rethrow;
    }
  }

  Future<void> addAssignment({
    required int scheduleId,
    required int roleId,
    required String userId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.assignment,
        data: {
          'scheduleId': scheduleId,
          'roleId': roleId,
          'userId': userId,
        },
      );
      print('افزودن تخصیص - وضعیت: ${response.statusCode}');
    } catch (e) {
      print('خطا در addAssignment: $e');
      rethrow;
    }
  }

  Future<void> removeAssignment(int id) async {
    try {
      final response = await _dio.delete('${ApiConstants.assignment}/$id');
      print('حذف تخصیص - وضعیت: ${response.statusCode}');
    } catch (e) {
      print('خطا در removeAssignment: $e');
      rethrow;
    }
  }
  // حذف کامل برنامه
Future<void> deleteSchedule(int scheduleId) async {
  await _dio.delete('${ApiConstants.churchSchedules}/$scheduleId');
}

// تأیید نهایی برنامه
Future<void> confirmSchedule(int scheduleId) async {
  await _dio.post('${ApiConstants.churchSchedules}/$scheduleId/confirm');
}
}