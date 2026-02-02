import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardProvider with ChangeNotifier {
  Map<String, dynamic>? _data;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDashboardStats(String token) async {
    if (token.isEmpty) {
      _error = "توکن یافت نشد. مجددا وارد شوید.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // چاپ توکن برای تست در کنسول (بعد از تست پاک کنید)
      print("Sending Token: $token");

      final response = await http.get(
        Uri.parse('http://urc.somee.com/api/DashboardApi/dashboard-stats'),
        headers: {
          'Authorization': 'Bearer $token', // فاصله بین Bearer و توکن حیاتی است
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _data = json.decode(response.body);
      } else if (response.statusCode == 401) {
        _error = "نشست کاربری منقضی شده است (401)";
      } else {
        _error = 'خطای سرور: ${response.statusCode}';
      }
    } catch (e) {
      _error = "خطای اتصال: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
