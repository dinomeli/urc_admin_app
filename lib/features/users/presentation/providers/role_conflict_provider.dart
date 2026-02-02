
import 'package:flutter/material.dart';
import '../../data/services/role_conflict_api_service.dart';
import '../../data/models/role_conflict_dto.dart';

class RoleConflictProvider with ChangeNotifier {
  final RoleConflictApiService _apiService=RoleConflictApiService();

  List<RoleConflictDto> _conflicts = [];
  bool _isLoading = false;
  String? _error;

  //RoleConflictProvider(this._apiService);

  List<RoleConflictDto> get conflicts => _conflicts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchConflicts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conflicts = await _apiService.getAll();
    } catch (e) {
      _error = e.toString();
      print('خطا در لود تضادها: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createConflict(RoleConflictDto dto) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.create(dto);
      if (success) await fetchConflicts();
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateConflict(int id, RoleConflictDto dto) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.update(id, dto);
      if (success) await fetchConflicts();
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteConflict(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.delete(id);
      if (success) {
        _conflicts.removeWhere((c) => c.id == id);
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