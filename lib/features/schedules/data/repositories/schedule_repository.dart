import 'package:dio/dio.dart';
import '../models/church_schedule.dart';

import '../../../../core/networking/dio_client.dart';
import 'package:dio/dio.dart';
import '../../../../core/networking/dio_client.dart';
import '../services/api_service.dart';

class ScheduleRepository {
  final ApiService _api;

  ScheduleRepository(this._api);

  Future<List<ChurchSchedule>> getSchedules() => _api.getSchedules();
  Future<Map<String, dynamic>> generateSchedules(int weeksCount, bool includeCommunion) => _api.generateSchedules(weeksCount, includeCommunion);
  Future<ChurchSchedule> getScheduleDetail(int id) => _api.getScheduleDetail(id);
  Future<Map<String, dynamic>> updateAssignment(int assignmentId, String userId) => _api.updateAssignment(assignmentId, userId);
  Future<Map<String, dynamic>> addAssignment(int scheduleId, int roleId, String userId) => _api.addAssignment(scheduleId, roleId, userId);
  Future<Map<String, dynamic>> removeAssignment(int id) => _api.removeAssignment(id);
  Future<Response> exportPdf(int id) => _api.exportPdf(id);
  Future<ChurchSchedule> getWeeklyPlan(int? id) => _api.getWeeklyPlan(id);
  Future<Response> exportExcel(DateTime? from, DateTime? to) => _api.exportExcel(from, to);
}