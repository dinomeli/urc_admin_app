import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

// --- Imports: Providers ---
import 'core/providers/locale_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/presentation/providers/menu_provider.dart';
import 'features/churches/presentation/providers/church_provider.dart';
import 'features/schedules/presentation/providers/attendance_provider.dart';
import 'features/schedules/presentation/providers/schedule_provider.dart';
import 'features/church_settings/presentation/providers/church_settings_provider.dart';
import 'features/notifications/presentation/providers/notification_send_provider.dart';
import 'features/schedules/presentation/providers/weekly_plan_provider.dart';
import 'features/schedules/presentation/providers/my_schedule_provider.dart';
import 'features/schedules/presentation/providers/calendar_provider.dart';
import 'features/users/presentation/providers/user_provider.dart';
import 'features/users/presentation/providers/church_role_provider.dart';
import 'features/users/presentation/providers/role_pair_provider.dart';
import 'features/users/presentation/providers/user_role_provider.dart';
import 'features/users/presentation/providers/absence_provider.dart';
import 'features/users/presentation/providers/role_conflict_provider.dart';

// --- Imports: Services ---
import 'core/networking/dio_client.dart';
import 'core/data/services/menu_api_service.dart';
import 'features/schedules/data/services/my_schedule_api_service.dart';
import 'features/schedules/data/services/church_calendar_api_service.dart';
// --- Imports: Screens ---
import 'core/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'core/presentation/screens/MenuItems_Screen.dart';
import 'features/churches/presentation/screens/churches_screen.dart';
import 'features/church_settings/presentation/screens/church_settings_list_screen.dart';
import 'features/common/widgets/custom_drawer.dart';
import 'features/notifications/presentation/screens/send_notification_screen.dart';
import 'features/schedules/presentation/screens/schedule_list_screen.dart';
import 'features/schedules/presentation/screens/Attendance_Screen.dart';
import 'features/schedules/presentation/screens/church_calendar_screen.dart';
import 'features/schedules/presentation/screens/my_schedule_Screen.dart';
import 'features/schedules/presentation/screens/WeeklyPlan_Screen.dart';
import 'features/users/presentation/screens/users_list_screen.dart';
import 'features/users/presentation/screens/user_roles_screen.dart';
import 'features/users/presentation/screens/absences_screen.dart';
import 'features/users/presentation/screens/church_roles_list_screen.dart';
import 'features/users/presentation/screens/role_pairs_screen.dart';
import 'features/users/presentation/screens/Role_Conflicts_Screen.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // کنترل دکمه Back سیستم
  SystemChannels.platform.setMethodCallHandler((call) async {
    if (call.method == 'SystemNavigator.pop') {
      final context = navigatorKey.currentContext;
      if (context != null) {
        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
          return;
        }
      }
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ۱. پایه (اول لوکال بعد بقیه)
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadUserData()),

        // ۲. کلاینت شبکه
        Provider.value(value: DioClient.instance),

        // ۳. سرویس‌ها
        ProxyProvider<DioClient, MenuApiService>(
          update: (_, client, __) => MenuApiService(client.dio),
        ),
        ProxyProvider<DioClient, MyScheduleApiService>(
          update: (_, client, __) => MyScheduleApiService(client.dio),
        ),
        // در بخش سرویس‌ها (بخش ۳)
        ProxyProvider<DioClient, ChurchCalendarApiService>(
          update: (_, client, __) => ChurchCalendarApiService(client.dio),
        ),
        // ۴. پروایدرهای وابسته
        ChangeNotifierProxyProvider<MenuApiService, MenuProvider>(
          create: (context) => MenuProvider(context.read<MenuApiService>()),
          update: (_, service, previous) => previous ?? MenuProvider(service),
        ),
        ChangeNotifierProxyProvider<MyScheduleApiService, WeeklyPlanProvider>(
          create: (context) =>
              WeeklyPlanProvider(context.read<MyScheduleApiService>()),
          update: (_, service, previous) =>
              previous ?? WeeklyPlanProvider(service),
        ),
        ChangeNotifierProxyProvider<MyScheduleApiService, MyScheduleProvider>(
          create: (context) =>
              MyScheduleProvider(context.read<MyScheduleApiService>()),
          update: (_, service, previous) =>
              previous ?? MyScheduleProvider(service),
        ),

        // در بخش پروایدرهای وابسته (بخش ۴)
        ChangeNotifierProxyProvider<ChurchCalendarApiService, CalendarProvider>(
          create: (context) =>
              CalendarProvider(context.read<ChurchCalendarApiService>()),
          update: (_, service, previous) =>
              previous ?? CalendarProvider(service),
        ),
        // ۵. سایر پروایدرها
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ChurchProvider()),
        ChangeNotifierProvider(create: (_) => NotificationSendProvider()),
        ChangeNotifierProvider(create: (_) => ChurchSettingsProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => ChurchRoleProvider()),
        ChangeNotifierProvider(create: (_) => UserRoleProvider()),
        ChangeNotifierProvider(create: (_) => RolePairProvider()),
        ChangeNotifierProvider(create: (_) => RoleConflictProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => AbsenceProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          final isFarsi = localeProvider.locale.languageCode == 'fa';

          return MaterialApp.router(
            title: 'URC Admin Panel',
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            supportedLocales: const [Locale('en', 'US'), Locale('fa', 'IR')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return Directionality(
                textDirection: localeProvider.textDirection,
                child: child!,
              );
            },
            theme: ThemeData(
              // انتخاب هوشمند فونت بر اساس زبان
              fontFamily: isFarsi ? 'Vazir' : 'Roboto',
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
              scaffoldBackgroundColor: const Color(0xFFF4F6F9),
            ),
            routerConfig: _router,
          );
        },
      ),
    );
  }

  static final GoRouter _router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/church-settings',
        builder: (context, state) => const ChurchSettingsListScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => Consumer2<AuthProvider, LocaleProvider>(
          builder: (context, auth, localeProvider, _) {
            final isFarsi = localeProvider.locale.languageCode == 'fa';

            return Scaffold(
              // استفاده از CustomDrawer که خودتان دارید
              drawer: const CustomDrawer(),
              body: const DashboardContent(), // محتوای اصلی داشبورد
            );
          },
        ),
      ),
      GoRoute(
        path: '/churches',
        builder: (context, state) => const ChurchesScreen(),
      ),
      GoRoute(
        path: '/users-list',
        builder: (context, state) => const UsersListScreen(),
      ),
      GoRoute(
        path: '/church-roles',
        builder: (context, state) => const ChurchRolesScreen(),
      ),
      GoRoute(
        path: '/role-conflicts',
        builder: (context, state) => const RoleConflictsScreen(),
      ),
      GoRoute(
        path: '/user-roles',
        builder: (context, state) => const UserRolesScreen(),
      ),
      GoRoute(
        path: '/role-pairs',
        builder: (context, state) => const RolePairsScreen(),
      ),
      GoRoute(
        path: '/absence',
        builder: (context, state) => const AbsencesScreen(),
      ),
      GoRoute(
        path: '/menu-items',
        builder: (context, state) => const MenuItemsScreen(),
      ),
      GoRoute(
        path: '/attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: '/attendance/schedule/:id',
        builder: (context, state) => AttendanceScreen(
          scheduleId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/send-notification',
        builder: (context, state) => const SendNotificationScreen(),
      ),
      GoRoute(
        path: '/weekly-plan',
        builder: (context, state) => const WeeklyPlanScreen(),
      ),
      GoRoute(
        path: '/weekly-plan/:userId',
        builder: (context, state) =>
            WeeklyPlanScreen(userId: state.pathParameters['userId']),
      ),
      GoRoute(
        path: '/church-calendar',
        builder: (context, state) => const ChurchCalendarScreen(),
      ),
      GoRoute(
        path: '/my-schedule',
        builder: (context, state) => const MyScheduleScreen(),
      ),
      GoRoute(
        path: '/schedules-list',
        builder: (context, state) => const ScheduleListScreen(),
      ),
    ],
  );
}
