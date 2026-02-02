// lib/features/schedules/presentation/providers/attendance_provider.dart
import 'package:flutter/material.dart';
import '../../data/services/attendance_api_service.dart';
import '../../data/models/attendance_dto.dart';

class AttendanceProvider with ChangeNotifier {
  final AttendanceApiService _apiService=AttendanceApiService();

  List<AttendanceDto> _attendances = [];
  List<AttendanceDto> _scheduleAttendances = [];
  bool _isLoading = false;
  String? _error;

 // AttendanceProvider(this._apiService);

  List<AttendanceDto> get attendances => _attendances;
  List<AttendanceDto> get scheduleAttendances => _scheduleAttendances;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _attendances = await _apiService.getAll();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBySchedule(int scheduleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _scheduleAttendances = await _apiService.getBySchedule(scheduleId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> markAttendance(int assignmentId, bool isPresent) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.markAttendance(assignmentId, isPresent);
      if (success) {
        // رفرش لیست
        if (_scheduleAttendances.isNotEmpty) {
          final index = _scheduleAttendances.indexWhere((a) => a.id == assignmentId);
          if (index != -1) {
            _scheduleAttendances[index] = AttendanceDto(
              id: assignmentId,
              scheduleId: _scheduleAttendances[index].scheduleId,
              serviceDate: _scheduleAttendances[index].serviceDate,
              userId: _scheduleAttendances[index].userId,
              userFullName: _scheduleAttendances[index].userFullName,
              roleName: _scheduleAttendances[index].roleName,
              status: isPresent ? 'Accepted' : 'Absent',
            );
            notifyListeners();
          }
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