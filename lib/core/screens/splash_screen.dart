import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
//import io.flutter.embedding.android.FlutterActivity ..FlutterActivity
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goToLogin();
  }

  Future<void> _goToLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.church, size: 100, color: Color(0xFF00ADB5)),
            const SizedBox(height: 24),
            const Text(
              'URC Admin Panel',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('در حال بارگذاری...'),
          ],
        ),
      ),
    );
  }
}