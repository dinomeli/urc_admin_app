// lib/features/schedules/presentation/providers/role_pair_provider.dart
import 'package:flutter/material.dart';
import '../../data/services/role_pair_api_service.dart';
import '../../data/models/role_pair_dto.dart';
import '../../data/models/user_dto.dart';
class RolePairProvider with ChangeNotifier {
  final RolePairApiService _apiService= RolePairApiService();

  List<RolePairDto> _pairs = [];
  bool _isLoading = false;
  String? _error;

  //RolePairProvider(this._apiService);

  List<RolePairDto> get pairs => _pairs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPairs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pairs = await _apiService.getAll();
    } catch (e) {
      _error = e.toString();
      print('خطا در لود جفت نقش‌ها: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createPair(RolePairDto dto) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.create(dto);
      if (success) await fetchPairs();
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePair(int id, RolePairDto dto) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.update(id, dto);
      if (success) await fetchPairs();
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePair(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.delete(id);
      if (success) {
        _pairs.removeWhere((p) => p.id == id);
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