// lib/features/users/presentation/providers/user_provider.dart
import 'package:flutter/material.dart';
import '../../data/services/user_api_service.dart';
import '../../data/models/user_dto.dart';

class UserProvider with ChangeNotifier {
  final UserApiService _apiService=UserApiService();

  // فقط یک constructor ساده (DioClient داخل سرویس مدیریت می‌شه)

  List<UserDto> _users = [];
  bool _isLoading = false;
  String? _error;

  List<UserDto> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUsers() async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    _users = await _apiService.getUsers();
  } catch (e) {
    _error = 'خطا در بارگذاری کاربران: $e';
    print(_error);
  }

  _isLoading = false;
  notifyListeners();
}
  Future<void> createUser(CreateUserDto dto) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.createUser(dto);
      await fetchUsers(); // رفرش لیست بعد از ایجاد
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // بقیه متدها مثل updateUser, deleteUser, updateRoles رو مشابه اضافه کن
  // اگر نیاز داشتی کد کاملشون رو برات می‌فرستم

  Future<void> updateUser(String id, UpdateUserDto dto) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.updateUser(id, dto);
      await fetchUsers();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteUser(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deleteUser(id);
      await fetchUsers();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateRoles(String id, List<String> roles) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.updateRoles(id, roles);
      await fetchUsers();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}