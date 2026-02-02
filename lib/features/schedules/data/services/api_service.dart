import 'package:dio/dio.dart';

import '../models/church_schedule.dart';
import 'package:dio/dio.dart';
import '../../../../features/schedules/presentation/utils/constants.dart'; 

class ApiService {
  final Dio _dio;

  ApiService(String token) : _dio = Dio(BaseOptions(
      baseUrl: Constants.baseUrl,
      headers: {'Authorization': 'Bearer $token'},
    )) {
    _dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  Future<List<ChurchSchedule>> getSchedules() async {
    final response = await _dio.get('/api/ChurchSchedulesApi');
    return (response.data as List).map((json) => ChurchSchedule.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> generateSchedules(int weeksCount, bool includeCommunion) async {
    final response = await _dio.post('/api/ChurchSchedulesApi/generate', queryParameters: {
      'weeksCount': weeksCount,
      'includeCommunion': includeCommunion,
    });
    return response.data;
  }

  Future<ChurchSchedule> getScheduleDetail(int id) async {
    final response = await _dio.get('/api/ChurchSchedulesApi/$id');
    return ChurchSchedule.fromJson(response.data['schedule']);
  }

  Future<Map<String, dynamic>> updateAssignment(int assignmentId, String userId) async {
    final response = await _dio.put('/api/ChurchSchedulesApi/assignment/$assignmentId', data: userId);
    return response.data;
  }

  Future<Map<String, dynamic>> addAssignment(int scheduleId, int roleId, String userId) async {
    final response = await _dio.post('/api/ChurchSchedulesApi/assignment', data: {
      'scheduleId': scheduleId,
      'roleId': roleId,
      'userId': userId,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> removeAssignment(int id) async {
    final response = await _dio.delete('/api/ChurchSchedulesApi/assignment/$id');
    return response.data;
  }

  Future<Response> exportPdf(int id) async {
    return await _dio.get('/api/ChurchSchedulesApi/$id/pdf', options: Options(responseType: ResponseType.bytes));
  }

  Future<ChurchSchedule> getWeeklyPlan(int? id) async {
    final url = id != null ? '/api/ChurchSchedulesApi/weekly-plan/$id' : '/api/ChurchSchedulesApi/weekly-plan';
    final response = await _dio.get(url);
    return ChurchSchedule.fromJson(response.data);
  }

  Future<Response> exportExcel(DateTime? fromDate, DateTime? toDate) async {
    return await _dio.get('/api/ChurchSchedulesApi/export-excel', queryParameters: {
      'fromDate': fromDate?.toIso8601String(),
      'toDate': toDate?.toIso8601String(),
    }, options: Options(responseType: ResponseType.bytes));
  }
}