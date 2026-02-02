import 'package:dio/dio.dart';
import '../models/calendar_event_dto.dart';
import '../models/schedule_detail_dto.dart';

class ChurchCalendarApiService {
  final Dio _dio;
  ChurchCalendarApiService(this._dio);

  // ۱. دریافت لیست رویدادها (خروجی مستقیم Array است)
  Future<List<CalendarEventDto>> getCalendarEvents() async {
    final response = await _dio.get('/api/church-calendar/events');
    // چون خروجی Ok(schedules) است، مستقیم response.data را مپ می‌کنیم
    return (response.data as List)
        .map((json) => CalendarEventDto.fromJson(json))
        .toList();
  }

  // ۲. دریافت جزئیات (خروجی داخل فیلد data است)
  Future<ScheduleDetailDto> getScheduleDetails(int id) async {
    final response = await _dio.get('/api/church-calendar/$id');
    // چون خروجی Ok(new { data = dto }) است، باید از ['data'] استفاده کنیم
    return ScheduleDetailDto.fromJson(response.data['data']);
  }
}