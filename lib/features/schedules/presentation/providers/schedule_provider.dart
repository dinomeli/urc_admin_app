import 'package:flutter/material.dart';
import '../../data/services/schedule_api_service.dart';
import '../../data/models/church_schedule_list_dto.dart';
import '../../data/models/edit_schedule_response.dart';




class ScheduleProvider with ChangeNotifier {
 final ScheduleApiService _apiService = ScheduleApiService(); // فقط یک بار ساخته می‌شه

  // فقط یک constructor ساده
 
  // فیلدهای اصلی
  List<ChurchScheduleListDto> _schedules = [];
  List<ChurchScheduleListDto> get schedules => _schedules;

  EditScheduleResponse? _editData;
  EditScheduleResponse? get editData => _editData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  ScheduleProvider();

  Future<void> fetchSchedules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _schedules = await _apiService.getSchedules();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadEditData(int scheduleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _editData = await _apiService.getScheduleForEdit(scheduleId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> generateSchedules(int weeksCount, bool includeCommunion) async {
  try {
    final result = await _apiService.generateSchedules(
      weeksCount: weeksCount,
      includeCommunion: includeCommunion,
    );
    await fetchSchedules(); // رفرش لیست
    return result['success'] == true;
  } catch (e) {
    print('خطا در generateSchedules: $e');
    return false;
  }
}

  Future<void> addAssignment({
    required int scheduleId,
    required int roleId,
    required String userId,
  }) async {
    try {
      await _apiService.addAssignment(
        scheduleId: scheduleId,
        roleId: roleId,
        userId: userId,
      );
      await loadEditData(scheduleId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeAssignment(int assignmentId) async {
    try {
      await _apiService.removeAssignment(assignmentId);
      if (_editData != null && _editData!.schedule.id != null) {
        await loadEditData(_editData!.schedule.id!);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  Future<void> deleteSchedule(int scheduleId) async {
  try {
    await _apiService.deleteSchedule(scheduleId);
    await fetchSchedules(); // رفرش لیست
  } catch (e) {
    _error = e.toString();
    notifyListeners();
  }
}

Future<void> confirmSchedule(int scheduleId) async {
  try {
    await _apiService.confirmSchedule(scheduleId);
    await fetchSchedules(); // رفرش لیست
    await loadEditData(scheduleId); // اگر در صفحه ویرایش هستی
  } catch (e) {
    _error = e.toString();
    notifyListeners();
  }
}
}