import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import 'core/providers/locale_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/churches/presentation/screens/churches_screen.dart';
import 'features/church_settings/presentation/screens/church_settings_list_screen.dart';
import 'features/common/widgets/custom_drawer.dart';
import 'features/common/presentation/screens/placeholder_screen.dart';
import 'features/churches/presentation/providers/church_provider.dart';
import 'features/schedules/presentation/providers/schedule_provider.dart';
import 'features/church_settings/presentation/providers/church_settings_provider.dart';
import 'features/notifications/presentation/providers/notification_send_provider.dart';
import 'features/notifications/presentation/screens/send_notification_screen.dart';
// کلید نویگیشن برای مدیریت بک دکمه
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // مدیریت بک دکمه اندروید (برگشت به صفحه قبلی به جای خروج)
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
      SystemNavigator.pop();
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadUserData()),
        ChangeNotifierProvider(create: (_) => ChurchProvider()),
        ChangeNotifierProvider(create: (_) => NotificationSendProvider()),
        ChangeNotifierProvider(create: (_) => ChurchSettingsProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp.router(
         
          title: 'URC Admin Panel',
          debugShowCheckedModeBanner: false,
          locale: localeProvider.locale,
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('fa', 'IR'),
          ],
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
            fontFamily: localeProvider.locale.languageCode == 'fa' ? 'Vazir' : 'Roboto',
            useMaterial3: true,
            primarySwatch: Colors.teal,
            scaffoldBackgroundColor: const Color(0xFFF4F6F9),
          ),
          routerConfig: GoRouter(
           navigatorKey: navigatorKey,
            initialLocation: '/splash',
            routes: [
              GoRoute(
                path: '/splash',
                builder: (context, state) => const SplashScreen(),
              ),
              GoRoute(
                path: '/login',
                builder: (context, state) => const LoginScreen(),
              ),
              GoRoute(
  path: '/church-settings',
  builder: (context, state) => const ChurchSettingsListScreen(),
),
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.roles.isEmpty) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return Scaffold(
                      appBar: AppBar(title: Text(localeProvider.translate('Dashboard', 'داشبورد'))),
                      drawer: const CustomDrawer(),
                      body: const Center(
                        child: Text(
                          'خوش آمدید به داشبورد\n(در حال توسعه)',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  },
                ),
              ),
              GoRoute(
                path: '/churches',
                builder: (context, state) => const ChurchesScreen(),
              ),
              GoRoute(
  path: '/send-notification',
  builder: (context, state) => const SendNotificationScreen(),
),
 GoRoute(
  path: '/schedules-list',
  builder: (context, state) => const SendNotificationScreen(),
),
            ],
          ),
        );
      },
    );
  }
}