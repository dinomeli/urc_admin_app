// lib/features/users/presentation/providers/church_role_provider.dart
import 'package:flutter/material.dart';
import '../../data/services/church_role_api_service.dart';
import '../../data/models/church_role_dto.dart';

class ChurchRoleProvider with ChangeNotifier {
  final ChurchRoleApiService _apiService=ChurchRoleApiService();
//final UserApiService _apiService=UserApiService();
  List<ChurchRoleDto> _roles = [];
  bool _isLoading = false;
  String? _error;

  //ChurchRoleProvider(this._apiService);

  List<ChurchRoleDto> get roles => _roles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRoles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _roles = await _apiService.getAll();
    } catch (e) {
      _error = e.toString();
      print('خطا در لود نقش‌ها: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createRole(ChurchRoleDto dto) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.create(dto);
      if (success) await fetchRoles();
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRole(int id, ChurchRoleDto dto) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.update(id, dto);
      if (success) await fetchRoles();
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRole(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.delete(id);
      if (success) {
        _roles.removeWhere((r) => r.id == id);
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