import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/auth_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // اگر نقش‌ها هنوز لود نشدن
        if (authProvider.roles.isEmpty) {
          return const Drawer(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('در حال بارگذاری نقش‌ها...'),
                ],
              ),
            ),
          );
        }

        final tr = Provider.of<LocaleProvider>(context, listen: false).translate;
        final isAdmin = authProvider.isAdmin;
        final isGroupLeader = authProvider.isGroupLeader;

        return Drawer(
          backgroundColor: const Color(0xFF222831),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF00ADB5)),
                child: Center(
                  child: Text(
                    tr('Church Admin', 'پنل مدیریت کلیسا'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Dashboard
              _tile(
                context: context,
                icon: FontAwesomeIcons.chartLine,
                title: tr('Dashboard', 'داشبورد'),
                route: '/dashboard',
              ),

              // Church Management
              ExpansionTile(
                leading: const Icon(FontAwesomeIcons.church, color: Colors.white70),
                title: Text(tr('Church Management', 'مدیریت کلیساها'), style: _titleStyle()),
                iconColor: const Color(0xFF00ADB5),
                collapsedIconColor: Colors.white70,
                children: [
                  _subTile(context: context, title: tr('Churches', 'کلیساها'), route: '/churches'),
                  _subTile(context: context, title: tr('Church Settings', 'تنظیمات'), route: '/church-settings'),
                ],
              ),

              // Members & Roles
              ExpansionTile(
                leading: const Icon(FontAwesomeIcons.users, color: Colors.white70),
                title: Text(tr('Members & Roles', 'اعضا و نقش‌ها'), style: _titleStyle()),
                iconColor: const Color(0xFF00ADB5),
                collapsedIconColor: Colors.white70,
                children: [
                  _subTile(context: context, title: tr('Members', 'اعضا'), route: '/members'),
                  if (isAdmin) _subTile(context: context, title: tr('Users', 'کاربران'), route: '/users-list'),
                  if (isAdmin || isGroupLeader) ...[
                    _subTile(context: context, title: tr('Roles', 'نقش‌ها'), route: '/church-roles'),
                    _subTile(context: context, title: tr('User Roles', 'نقش‌های کاربران'), route: '/user-roles'),
                    _subTile(context: context, title: tr('Role pairs', 'روابط نقش‌ها'), route: '/role-pairs'),
                       _subTile(context: context, title: tr('Role conflicts', 'تداخل‌های نقش‌ها'), route: '/role-conflicts'),
                  ],
                ],
              ),

              // Schedules & Attendance
              ExpansionTile(
                leading: const Icon(FontAwesomeIcons.calendarAlt, color: Colors.white70),
                title: Text(tr('Schedules & Attendance', 'برنامه‌ها و حضور و غیاب'), style: _titleStyle()),
                iconColor: const Color(0xFF00ADB5),
                collapsedIconColor: Colors.white70,
                children: [
                  if (isAdmin || isGroupLeader)
                    _subTile(context: context, title: tr('Church Schedules', 'برنامه‌های کلیسا'), route: '/schedules-list'),
                  _subTile(context: context, title: tr('Attendance', 'حضور و غیاب'), route: '/attendance'),
                  _subTile(context: context, title: tr('My Schedule', 'برنامه من'), route: '/my-schedule'),
                  _subTile(context: context, title: tr('Absences', 'غیبت‌ها'), route: '/absence'),
                ],
              ),

              // News & Events
              ExpansionTile(
                leading: const Icon(FontAwesomeIcons.newspaper, color: Colors.white70),
                title: Text(tr('News & Events', 'اخبار و رویدادها'), style: _titleStyle()),
                iconColor: const Color(0xFF00ADB5),
                collapsedIconColor: Colors.white70,
                children: [
                  _subTile(context: context, title: tr('News', 'اخبار'), route: '/news'),
                  _subTile(context: context, title: tr('Events', 'رویدادها'), route: '/events'),
                ],
              ),

              // Forms & Menu (فقط ادمین)
              if (isAdmin)
                ExpansionTile(
                  leading: const Icon(FontAwesomeIcons.fileAlt, color: Colors.white70),
                  title: Text(tr('Forms & Menu', 'فرم‌ها و منو'), style: _titleStyle()),
                  iconColor: const Color(0xFF00ADB5),
                  collapsedIconColor: Colors.white70,
                  children: [
                    _subTile(context: context, title: tr('Form Builder', 'فرم‌ساز'), route: '/dynamic-forms'),
                    _subTile(context: context, title: tr('Send Menu to App', 'ارسال منو به اپ'), route: '/menu-items'),
                    _subTile(context: context, title: tr('Send Notifications', 'ارسال اعلان'), route: '/send-notification'),
                  ],
                ),

              // آیتم‌های ساده
              _tile(
                context: context,
                icon: FontAwesomeIcons.calendarWeek,
                title: tr('Weekly Plan', 'برنامه هفتگی'),
                route: '/weekly-plan',
              ),
              _tile(
                context: context,
                icon: FontAwesomeIcons.calendar,
                title: tr('Calendar', 'تقویم'),
                route: '/church-calendar',
              ),
              _tile(
                context: context,
                icon: FontAwesomeIcons.home,
                title: tr('Home', 'خانه'),
                route: '/home',
              ),
              _tile(
                context: context,
                icon: FontAwesomeIcons.lock,
                title: tr('Change Password', 'تغییر رمز عبور'),
                route: '/change-password',
              ),
            ],
          ),
        );
      },
    );
  }

  /// متد ناوبری هوشمند
  void _navigate(BuildContext context, String route) {
    Navigator.pop(context);
    final isRootPage = ['/dashboard', '/login'].contains(route);

    if (isRootPage) {
      context.go(route); // جایگزین مسیر
    } else {
      context.push(route); // اضافه به پشته، بک کار می‌کند
    }
  }

  /// آیتم اصلی
  Widget _tile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16)),
      hoverColor: const Color(0xFF00ADB5).withOpacity(0.2),
      onTap: () => _navigate(context, route),
    );
  }

  /// آیتم زیرمجموعه
  Widget _subTile({
    required BuildContext context,
    required String title,
    required String route,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 48.0),
      title: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 15)),
      hoverColor: const Color(0xFF00ADB5).withOpacity(0.15),
      onTap: () => _navigate(context, route),
    );
  }

  TextStyle _titleStyle() {
    return const TextStyle(color: Colors.white70, fontSize: 16);
  }
}
