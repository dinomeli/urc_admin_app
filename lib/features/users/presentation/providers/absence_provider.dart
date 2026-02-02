// lib/features/schedules/presentation/providers/absence_provider.dart
import 'package:flutter/material.dart';
import '../../data/services/absence_api_service.dart';
import '../../data/models/absence_dto.dart';

class AbsenceProvider with ChangeNotifier {
  final AbsenceApiService _apiService=AbsenceApiService();

  List<AbsenceDto> _absences = [];
  bool _isLoading = false;
  String? _error;

 // AbsenceProvider(this._apiService);

  List<AbsenceDto> get absences => _absences;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMyAbsences() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _absences = await _apiService.getMyAbsences();
    } catch (e) {
      _error = e.toString();
      print('خطا در لود غیبت‌ها: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createAbsence(DateTime start, DateTime end, String? reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dto = AbsenceDto(
        id: 0, // سرور می‌سازه
        userId: '', // سرور می‌ذاره
        startDate: start,
        endDate: end,
        reason: reason,
        createdAt: DateTime.now(),
      );

      final success = await _apiService.createAbsence(dto);
      if (success) await fetchMyAbsences();
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAbsence(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.deleteAbsence(id);
      if (success) {
        _absences.removeWhere((a) => a.id == id);
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