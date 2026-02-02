import 'package:flutter/material.dart';
import '../../data/models/my_schedule_dto.dart'; // یا نام مدل WeeklyPlanDto شما
import '../../data/services/my_schedule_api_service.dart';
import '../../data/models/weekly_plan_dto.dart'; 

class WeeklyPlanProvider with ChangeNotifier {
  final MyScheduleApiService _apiService;

  WeeklyPlanProvider(this._apiService);

 // List<dynamic> _weeklyPlan = []; // لیست برنامه‌ها
  bool _isLoading = false;
  String? _error;

  // Getter ها
 // List<dynamic> get weeklyPlan => _weeklyPlan;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // متد اصلی دریافت برنامه هفتگی
  // در فایل weekly_plan_provider.dart

List<WeeklyPlanDto> _weeklyPlan = []; // تغییر نوع به لیست DTO
List<WeeklyPlanDto> get weeklyPlan => _weeklyPlan;

Future<void> fetchWeeklyPlan({String? userId}) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final List<dynamic> data = await _apiService.getWeeklyPlan(userId);
    
    // تبدیل نقشه‌های خام به اشیاء DTO
    _weeklyPlan = data.map((item) => WeeklyPlanDto.fromJson(item)).toList();
    
  } catch (e) {
    _error = e.toString();
    _weeklyPlan = [];
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  // متد تایید حضور کاربر
  Future<void> markAttendance(int assignmentId, String status, {String? userId}) async {
    try {
      final success = await _apiService.updateStatus(assignmentId, status);
      if (success) {
        // بعد از موفقیت، لیست را دوباره از سرور می‌گیریم تا تغییرات اعمال شود
        await fetchWeeklyPlan(userId: userId);
      }
    } catch (e) {
      _error = "خطا در بروزرسانی وضعیت: $e";
      notifyListeners();
    }
  }
}