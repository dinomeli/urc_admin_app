import 'package:flutter/material.dart';
import '../../data/services/my_schedule_api_service.dart';
import '../../data/models/my_schedule_dto.dart';

class MyScheduleProvider with ChangeNotifier {
  final MyScheduleApiService _apiService;

  // ۲. در سازنده آن را دریافت کن
  MyScheduleProvider(this._apiService);
  List<MyScheduleDto> _mySchedules = [];
  bool _isLoading = false;
  String? _error;

  List<MyScheduleDto> get mySchedules => _mySchedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMySchedules({String? userId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mySchedules = await _apiService.getSchedules(userId: userId);
    } catch (e) {
      _error = e.toString();
      debugPrint('Provider Error (fetchMySchedules): $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تغییر وضعیت حضور با استفاده از copyWith برای جلوگیری از ارورهای پارامتر
  Future<bool> markAttendance(int assignmentId, bool isPresent) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.markAttendance(assignmentId, isPresent);
      if (success) {
        final index = _mySchedules.indexWhere((s) => s.assignmentId == assignmentId);
        if (index != -1) {
          // اینجا از copyWith استفاده می‌کنیم تا فیلدهای ثابت (مثل ID، نام کاربر، توکن و ...) دست نخورند
          _mySchedules[index] = _mySchedules[index].copyWith(
            status: isPresent ? 'Accepted' : 'Absent',
            isConfirmed: isPresent, 
          );
        }
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// اعلام غیبت با استفاده از copyWith
  Future<bool> markAbsent(int assignmentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.markAbsent(assignmentId);
      if (success) {
        final index = _mySchedules.indexWhere((s) => s.assignmentId == assignmentId);
        if (index != -1) {
          _mySchedules[index] = _mySchedules[index].copyWith(
            status: 'Absent',
            isConfirmed: false,
          );
        }
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}