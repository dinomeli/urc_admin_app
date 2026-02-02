import 'package:flutter/material.dart';
import '../../data/models/church_service_setting.dart';
import '../../data/repositories/church_settings_repository.dart';

class ChurchSettingsProvider with ChangeNotifier {
  final ChurchSettingsRepository _repo = ChurchSettingsRepository();
  List<ChurchServiceSetting> _settings = [];
    String? _success;

  List<ChurchServiceSetting> get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get success => _success;
  bool _isLoading = false;
  String? _error;

  Future<void> fetchSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await _repo.getAllSettings();
    } catch (e) {
      if (e.toString().contains('401')) {
        _error = "نشست شما منقضی شده، لطفاً دوباره وارد شوید";
      } else {
        _error = "خطا در دریافت اطلاعات: $e";
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }






  Future<void> create({
    required int churchId,
    required String programType,
    DateTime? serviceDate,
    TimeOfDay? serviceTime,
    bool isActive = true,
  }) async {
    _isLoading = true;
    _error = null;
    _success = null;
    notifyListeners();

    try {
      final setting = ChurchServiceSetting(
        churchId: churchId,
        programType: programType,
        serviceDate: serviceDate,
        serviceStartTime: serviceTime,
        isActive: isActive,
      );
      await _repo.createSetting(setting);
      _success = 'تنظیمات با موفقیت ذخیره شد';
      // لیست رو دوباره لود کن تا بروز بشه
      await fetchSettings();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> update(
    int id, {
    required int churchId,
    required String programType,
    DateTime? serviceDate,
    TimeOfDay? serviceTime,
    bool isActive = true,
  }) async {
    _isLoading = true;
    _error = null;
    _success = null;
    notifyListeners();

    try {
      final setting = ChurchServiceSetting(
        id: id,
        churchId: churchId,
        programType: programType,
        serviceDate: serviceDate,
        serviceStartTime: serviceTime,
        isActive: isActive,
      );
      await _repo.updateSetting(id, setting);
      _success = 'تنظیمات با موفقیت ویرایش شد';
      await fetchSettings(); // لیست بروز
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> delete(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.deleteSetting(id);
      _success = 'تنظیم با موفقیت حذف شد';
      _settings.removeWhere((s) => s.id == id);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _error = null;
    _success = null;
    notifyListeners();
  }
}
