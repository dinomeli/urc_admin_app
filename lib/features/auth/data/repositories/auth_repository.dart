import 'package:dio/dio.dart';
import '../models/login_response.dart';
import '../../../../core/networking/dio_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  final _storage = const FlutterSecureStorage();

  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await DioClient.instance.post(
        '/api/auth/login',
        data: {'email': email.trim(), 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final loginResponse = LoginResponse.fromJson(data);

        await DioClient.saveToken(loginResponse.token);
        await _storage.write(key: 'user_email', value: email.trim());

        return loginResponse;
      } else {
        throw Exception('ورود ناموفق: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'خطا در ارتباط با سرور',
      );
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await DioClient.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await DioClient.clearToken();
    await _storage.delete(key: 'user_email');
  }
}