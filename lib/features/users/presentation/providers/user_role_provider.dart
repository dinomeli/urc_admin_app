import 'package:flutter/material.dart';
import '../../data/services/user_role_api_service.dart';
import '../../data/models/user_role_dto.dart';
import '../../data/models/user_dto.dart';

class UserRoleProvider with ChangeNotifier {
  final UserRoleApiService _apiService = UserRoleApiService();

  // وضعیت‌ها
  List<UserRoleDto> _assignments = []; // لیست تمام تخصیص‌های فعلی
  List<UserDto> _allUsers = [];       // لیست کل کاربران سیستم
  List<Map<String, dynamic>> _churchRoles = []; // لیست نقش‌های تعریف شده در کلیسا
  
  bool _isLoading = false;
  String? _error;

  // Getterها
  List<UserRoleDto> get assignments => _assignments;
  List<UserDto> get allUsers => _allUsers;
  List<Map<String, dynamic>> get churchRoles => _churchRoles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// بارگذاری همزمان تمام داده‌های اولیه
  /// این متد در initState صفحه فراخوانی می‌شود
  Future<void> fetchInitialData() async {
    _setLoading(true);
    _error = null;
    
    try {
      // اجرای موازی درخواست‌ها برای افزایش سرعت بارگذاری
      final results = await Future.wait([
        _apiService.getAllAssignments(),
        _apiService.getAllUsers(),
        _apiService.getChurchRoles(),
      ]);
      
      _assignments = results[0] as List<UserRoleDto>;
      _allUsers = results[1] as List<UserDto>;
      _churchRoles = results[2] as List<Map<String, dynamic>>;
      
    } catch (e) {
      _error = "خطا در دریافت اطلاعات: ${e.toString()}";
      print("UserRoleProvider Error: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// دریافت لیست تخصیص‌ها (به تنهایی)
  Future<void> fetchAllAssignments() async {
    try {
      _assignments = await _apiService.getAllAssignments();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// تخصیص نقش جدید به یک کاربر
  Future<bool> assignRole(String userId, int roleId, double weight) async {
    _setLoading(true);
    try {
      final success = await _apiService.assignRole(userId, roleId, weight);
      if (success) {
        // به جای لود دوباره همه چیز، فقط لیست تخصیص‌ها را بروزرسانی می‌کنیم
        await fetchAllAssignments();
        return true;
      }
      return false;
    } catch (e) {
      _error = "خطا در تخصیص نقش: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// بروزرسانی وزن یک نقش
  Future<bool> updateWeight(String userId, int roleId, double weight) async {
    _setLoading(true);
    try {
      final success = await _apiService.updateWeight(userId, roleId, weight);
      if (success) {
        // بروزرسانی محلی مقدار وزن برای سرعت بیشتر در UI (Optimistic Update)
        final index = _assignments.indexWhere(
            (a) => a.userId == userId && a.roleId == roleId);
        if (index != -1) {
          // اگر مدل شما کپی‌پذیر است، اینجا آپدیت کنید یا دوباره لیست را بگیرید
          await fetchAllAssignments();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// حذف یک نقش از کاربر
  Future<bool> removeRole(String userId, int roleId) async {
    _setLoading(true);
    try {
      final success = await _apiService.removeRole(userId, roleId);
      if (success) {
        // حذف مستقیم از لیست موجود برای آپدیت آنی UI
        _assignments.removeWhere((a) => a.userId == userId && a.roleId == roleId);
        return true;
      }
      return false;
    } catch (e) {
      _error = "خطا در حذف نقش: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // متدهای کمکی برای مدیریت وضعیت
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}