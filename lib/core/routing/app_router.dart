import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/common/widgets/custom_drawer.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/common/presentation/screens/placeholder_screen.dart'; // ← import جدید
import '../../features/churches/presentation/screens/churches_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // ShellRoute برای داشتن drawer و appbar مشترک در صفحات اصلی
    ShellRoute(
      builder: (context, state, child) {
        final bool isRTL = Directionality.of(context) == TextDirection.rtl;
        final String location = state.uri.toString();

        return Scaffold(
          appBar: AppBar(
            title: Text(_getPageTitle(location)),
            centerTitle: true,
          ),
          endDrawer: isRTL ? const CustomDrawer() : null,
          drawer: !isRTL ? const CustomDrawer() : null,
          body: child,
        );
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const PlaceholderScreen(
            title: 'Dashboard',
            description: 'صفحه اصلی آمار و نمودارها',
          ),
        ),
        GoRoute(
          path: '/churches',
          builder: (context, state) => const PlaceholderScreen(
            title: 'Churches',
            description: 'مدیریت کلیساها',
          ),
        ),
        GoRoute(
          path: '/church-settings',
          builder: (context, state) => const PlaceholderScreen(title: 'Church Settings'),
        ),
        GoRoute(
          path: '/members',
          builder: (context, state) => const PlaceholderScreen(title: 'Members'),
        ),
        GoRoute(
          path: '/users',
          builder: (context, state) => const PlaceholderScreen(title: 'Users (Admin)'),
        ),
        GoRoute(
          path: '/roles',
          builder: (context, state) => const PlaceholderScreen(title: 'Roles'),
        ),
        GoRoute(
          path: '/user-roles',
          builder: (context, state) => const PlaceholderScreen(title: 'User Roles'),
        ),
        GoRoute(
          path: '/role-relations',
          builder: (context, state) => const PlaceholderScreen(title: 'Role Relations'),
        ),
        GoRoute(
          path: '/church-schedules',
          builder: (context, state) => const PlaceholderScreen(title: 'Church Schedules'),
        ),
        GoRoute(
          path: '/attendance',
          builder: (context, state) => const PlaceholderScreen(title: 'Attendance'),
        ),
        GoRoute(
          path: '/my-schedule',
          builder: (context, state) => const PlaceholderScreen(title: 'My Schedule'),
        ),
        GoRoute(
          path: '/absences',
          builder: (context, state) => const PlaceholderScreen(title: 'Absences'),
        ),
        GoRoute(
          path: '/news',
          builder: (context, state) => const PlaceholderScreen(title: 'News'),
        ),
        GoRoute(
          path: '/events',
          builder: (context, state) => const PlaceholderScreen(title: 'Events'),
        ),
        GoRoute(
          path: '/dynamic-forms',
          builder: (context, state) => const PlaceholderScreen(title: 'Dynamic Forms'),
        ),
        GoRoute(
          path: '/send-menu',
          builder: (context, state) => const PlaceholderScreen(title: 'Send Menu to App'),
        ),
        GoRoute(
          path: '/send-notifications',
          builder: (context, state) => const PlaceholderScreen(title: 'Send Notifications'),
        ),
        GoRoute(
          path: '/weekly-plan',
          builder: (context, state) => const PlaceholderScreen(title: 'Weekly Plan'),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const PlaceholderScreen(title: 'Calendar'),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const PlaceholderScreen(
            title: 'Home',
            description: 'صفحه اصلی اپلیکیشن',
          ),
        ),
        GoRoute(
  path: '/churches',
  builder: (context, state) => const ChurchesScreen(),
),
        GoRoute(
          path: '/change-password',
          builder: (context, state) => const PlaceholderScreen(title: 'Change Password'),
        ),
      ],
    ),
  ],

  redirect: (BuildContext context, GoRouterState state) {
    // بعداً چک واقعی لاگین رو اینجا می‌ذاریم
  //  final bool isLoggedIn = false; // temporary – بعداً از provider می‌گیریم
    //final bool isLoggingIn = state.uri.toString() == '/login';

   // if (!isLoggedIn && !isLoggingIn) {
   //   return '/login';
   // }
   // if (isLoggedIn && isLoggingIn) {
   //   return '/dashboard';
   // }
    return null;
  },

  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        '404 - صفحه پیدا نشد\n${state.uri}',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20),
      ),
    ),
  ),
);

String _getPageTitle(String location) {
  if (location.startsWith('/dashboard')) return 'Dashboard';
  if (location.startsWith('/churches')) return 'Churches';
  if (location.startsWith('/members')) return 'Members';
   if (location.startsWith('/schedule')) return 'Schedule';
  // می‌تونی بقیه رو هم اضافه کنی یا از map استفاده کنی
  return 'Church Admin Panel';
}