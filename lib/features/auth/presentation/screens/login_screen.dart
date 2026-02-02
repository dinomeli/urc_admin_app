import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/networking/dio_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  final _authRepo = AuthRepository();
  
  // در بخش تعریف FlutterSecureStorage
final _storage = const FlutterSecureStorage(
  iOptions: IOSOptions(
    // این گزینه باعث می‌شود در شبیه‌ساز ارور امنیتی نگیرید
    accessibility: KeychainAccessibility.first_unlock,
    // این گزینه از بروز تداخل در گروه‌های اپلیکیشن جلوگیری می‌کند
    groupId: null,
  ),
  // برای اندروید هم تنظیمات پیش‌فرض بماند
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
);
  final _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final email = await _storage.read(key: 'saved_email');
    if (email != null && email.isNotEmpty) {
      _emailController.text = email;
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await DioClient.clearToken();
      final response = await _authRepo.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      await DioClient.saveToken(response.token);

      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.setUserData(
          _emailController.text.trim(),
          response.roles,
          response.token,
        );
        
        await _storage.write(key: 'saved_email', value: _emailController.text.trim());
        context.go('/dashboard');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('کاربر یافت نشد') 
            ? 'ایمیل یا رمز عبور اشتباه است'
            : e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _biometricLogin() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      if (!canAuthenticate) return _showMessage('بیومتریک در دسترس نیست');

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'لطفاً برای ورود تأیید کنید',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );

      if (authenticated) {
        final token = await DioClient.getToken();
        if (token != null && token.isNotEmpty) {
          if (mounted) context.go('/dashboard');
        } else {
          _showMessage('ابتدا یکبار با رمز عبور وارد شوید');
        }
      }
    } catch (e) {
      _showMessage('خطا در بیومتریک');
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final tr = localeProvider.translate;
    final bool isFarsi = localeProvider.locale.languageCode == 'fa';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              localeProvider.setLocale(
                isFarsi ? const Locale('en', 'US') : const Locale('fa', 'IR'),
              );
            },
            icon: const Icon(Icons.language, color: Color(0xFF00ADB5)),
            label: Text(isFarsi ? "English" : "فارسی", 
                style: const TextStyle(color: Color(0xFF00ADB5), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.church, size: 80, color: Color(0xFF00ADB5)),
                  const SizedBox(height: 20),
                  Text(tr('Login', 'ورود به سیستم'), 
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    textAlign: isFarsi ? TextAlign.right : TextAlign.left,
                    decoration: InputDecoration(
                      labelText: tr('Email', 'ایمیل'),
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? tr('Required', 'اجباری') : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    textAlign: isFarsi ? TextAlign.right : TextAlign.left,
                    decoration: InputDecoration(
                      labelText: tr('Password', 'رمز عبور'),
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? tr('Required', 'اجباری') : null,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13), textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00ADB5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : Text(tr('Login', 'ورود'), style: const TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: _biometricLogin,
                    icon: const Icon(Icons.fingerprint),
                    label: Text(tr('Biometric', 'ورود با اثر انگشت')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
