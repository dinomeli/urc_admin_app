import 'package:flutter/material.dart';
import '../../data/models/menu_item_dto.dart';
import '../../data/services/menu_api_service.dart';

class MenuProvider with ChangeNotifier {
  // وابستگی به سرویس
MenuProvider(this._apiService); // دریافت Service به عنوان ورودی
final MenuApiService _apiService;// این خط را اضافه کنید
  // سازنده کلاس که سرویس را از ورودی می‌گیرد
  //MenuProvider(this._apiService);

  List<MenuItemDto> _menus = [];
  bool _isLoading = false;
  String? _error;

  List<MenuItemDto> get menus => _menus;
  bool get isLoading => _isLoading;
  String? get error => _error;

bool _isFirstLoad = true; // اضافه کردن این متغیر
bool get isFirstLoad => _isFirstLoad;

Future<void> fetchMenus() async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    _menus = await _apiService.getAll();
    _isFirstLoad = false; // بعد از اولین تلاش، چه لیست پر باشد چه خالی، این کاذب می‌شود
  } catch (e) {
    _error = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
  // ایجاد منو جدید
  Future<bool> createMenu(MenuItemDto dto) async {
    final success = await _apiService.create(dto);
    if (success) {
      await fetchMenus(); // لیست را بروز کن
    }
    return success;
  }

  // ویرایش منو
  Future<bool> updateMenu(int id, MenuItemDto dto) async {
    final success = await _apiService.update(id, dto);
    if (success) {
      await fetchMenus();
    }
    return success;
  }

  // حذف منو
  Future<void> deleteMenu(int id) async {
    final success = await _apiService.delete(id);
    if (success) {
      _menus.removeWhere((m) => m.id == id);
      notifyListeners();
    }
  }
}