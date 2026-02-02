// lib/features/schedules/presentation/providers/calendar_provider.dart
import 'package:flutter/material.dart';
import '../../data/services/church_calendar_api_service.dart';
import '../../data/models/calendar_event_dto.dart';
import '../../data/models/schedule_detail_dto.dart';

class CalendarProvider with ChangeNotifier {
  final ChurchCalendarApiService _apiService;

  List<CalendarEventDto> _events = [];
  ScheduleDetailDto? _selectedDetail;
  bool _isLoading = false;
  String? _error;

  CalendarProvider(this._apiService);

  List<CalendarEventDto> get events => _events;
  ScheduleDetailDto? get selectedDetail => _selectedDetail;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // tr: لود رویدادهای تقویم
  // en: Load calendar events
  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('--- شروع دریافت اطلاعات تقویم از سرور ---'); // لاگ شروع

      _events = await _apiService.getCalendarEvents();

      // 📝 لاگ‌های دیباگ
      print('تعداد کل برنامه‌های دریافت شده: ${_events.length}');

      if (_events.isNotEmpty) {
        for (var event in _events) {
          print(
            'رویداد پیدا شد: ID=${event.id}, Title=${event.title}, StartDate=${event.start}',
          );
        }
      } else {
        print(
          '⚠️ لیست برنامه‌ها خالی است! (دیتایی در دیتابیس نیست یا دسترسی ندارید)',
        );
      }
    } catch (e) {
      _error = 'خطا در بارگذاری تقویم: $e';
      print('❌ خطای API تقویم: $e'); // لاگ خطا
    }

    _isLoading = false;
    notifyListeners();
  }

  // tr: لود جزئیات برنامه انتخاب‌شده
  // en: Load details of selected schedule
  Future<void> fetchScheduleDetails(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedDetail = await _apiService.getScheduleDetails(id);
    } catch (e) {
      _error = 'خطا در بارگذاری جزئیات: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
