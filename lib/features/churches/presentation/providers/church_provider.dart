import 'package:flutter/material.dart';
import '../../data/models/church.dart';
import '../../data/repositories/church_repository.dart';

class ChurchProvider with ChangeNotifier {
  final ChurchRepository _repo = ChurchRepository();

  List<Church> _churches = [];
  bool _isLoading = false;
  String? _error;

  List<Church> get churches => _churches;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchChurches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _churches = await _repo.getChurches();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addChurch(Church church) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newChurch = await _repo.createChurch(church);
      _churches.add(newChurch);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateChurch(Church updated) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repo.updateChurch(updated.id, updated);
      final index = _churches.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        _churches[index] = updated;
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteChurch(int id) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    print('شروع حذف کلیسا با id: $id');
    await _repo.deleteChurch(id);
    print('حذف از سرور موفق بود');
    _churches.removeWhere((c) => c.id == id);
    print('لیست بروز شد - تعداد باقی‌مانده: ${_churches.length}');
  } catch (e) {
    print('خطا در حذف از provider: $e');
    _error = e.toString();
    rethrow;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
}