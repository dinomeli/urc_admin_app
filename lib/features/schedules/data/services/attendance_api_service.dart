// lib/features/schedules/data/services/attendance_api_service.dart
import 'package:dio/dio.dart';
import '../models/attendance_dto.dart';
import '../../../../core/networking/dio_client.dart';
class AttendanceApiService {
  final Dio _dio=DioClient.instance.dio;

  //AttendanceApiService(this._dio);

  Future<List<AttendanceDto>> getAll() async {
    final response = await _dio.get('/api/attendance');
    return (response.data['data'] as List)
        .map((json) => AttendanceDto.fromJson(json))
        .toList();
  }

  Future<List<AttendanceDto>> getBySchedule(int scheduleId) async {
    final response = await _dio.get('/api/attendance/schedule/$scheduleId');
    return (response.data['data'] as List)
        .map((json) => AttendanceDto.fromJson(json))
        .toList();
  }

  Future<List<AttendanceDto>> getMyAttendance() async {
    final response = await _dio.get('/api/attendance/user/current'); // یا userId کاربر فعلی
    return (response.data['data'] as List)
        .map((json) => AttendanceDto.fromJson(json))
        .toList();
  }

  Future<bool> markAttendance(int assignmentId, bool isPresent) async {
    try {
      await _dio.post('/api/attendance/mark', data: {
        'assignmentId': assignmentId,
        'isPresent': isPresent,
      });
      return true;
    } catch (e) {
      print('خطا در ثبت حضور: $e');
      return false;
    }
  }
}