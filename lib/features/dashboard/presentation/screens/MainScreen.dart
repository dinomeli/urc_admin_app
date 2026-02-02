import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/dashboard_provider.dart';
import './screens/dashboard_screen.dart';
import './screens/churches_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // لیست صفحات اصلی
  final List<Widget> _pages = [
    const DashboardScreen(), // صفحه داشبوردی که قبلاً ساختیم
    const ChurchesScreen(),  // مدیریت کلیساها
    const Center(child: Text('Settings')),
  ];

  @override
  void initState() {
    super.initState();
    // فراخوانی داده‌ها به محض باز شدن برنامه
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardStats("USER_TOKEN");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.church_rounded), label: 'Churches'),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}