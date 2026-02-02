import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  List<String> _roles = [];
  String? _email;
  String? _token;
  bool _isLoading = true; // اضافه شد: وضعیت اولیه لودینگ

  List<String> get roles => _roles;
  String? get email => _email;
  String? get token => _token;
  bool get isLoading => _isLoading; // اضافه شد: دسترسی به لودینگ

  bool get isAdmin => _roles.contains('Admin');
  bool get isGroupLeader => _roles.contains('GroupLeader');

  final _storage = const FlutterSecureStorage();

  Future<void> loadUserData() async {
    _isLoading = true; // شروع لودینگ
    notifyListeners();

    _email = await _storage.read(key: 'user_email');
    _token = await _storage.read(key: 'jwt_token');
    final rolesStr = await _storage.read(key: 'user_roles');
    if (rolesStr != null) {
      _roles = rolesStr.split(',').map((e) => e.trim()).toList();
    }
    
    _isLoading = false; // پایان لودینگ
    notifyListeners();
  }

  // این متد رو دقیقاً با همین پارامترها تعریف کن
Future<void> setUserData(String email, List<String> roles, String token) async {
  _email = email;
  _roles = roles.map((r) => r.trim()).toList(); // تمیز کردن
  _token = token;

  await _storage.write(key: 'user_email', value: email);
  await _storage.write(key: 'jwt_token', value: token);
  await _storage.write(key: 'user_roles', value: roles.join(','));

  notifyListeners();
  print('AuthProvider: نقش‌ها ذخیره شد → $roles'); // دیباگ
}
  Future<void> clearUserData() async {
    _email = null;
    _roles = [];
    _token = null;

    await _storage.deleteAll();
    notifyListeners();
  }
}