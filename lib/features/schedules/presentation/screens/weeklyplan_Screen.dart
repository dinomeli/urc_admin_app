import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weekly_plan_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/locale_provider.dart'; // فرض بر این مسیر
import '../../data/models/weekly_plan_dto.dart';

class WeeklyPlanScreen extends StatefulWidget {
  final String? userId;

  const WeeklyPlanScreen({super.key, this.userId});

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  @override
  void initState() {
    super.initState();
    // فراخوانی متد لود فقط یک بار در هنگام ورود به صفحه برای جلوگیری از لوپ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authProvider = context.read<AuthProvider>();
    final weeklyProvider = context.read<WeeklyPlanProvider>();

    // بررسی نقش کاربر برای تعیین سطح دسترسی
    bool isAdminOrLeader = authProvider.roles.contains('Admin') || 
                           authProvider.roles.contains('GroupLeader');

    if (isAdminOrLeader) {
      // اگر ادمین است و userId از ورودی (widget) نال باشد، کل برنامه کلیسا لود می‌شود
      weeklyProvider.fetchWeeklyPlan(userId: widget.userId);
    } else {
      // کاربر معمولی فقط برنامه خودش را می‌بیند
      weeklyProvider.fetchWeeklyPlan();
    }
  }

  @override
  Widget build(BuildContext context) {
    // تشخیص زبان فعلی اپلیکیشن از پروایدر شما
    final localeProvider = Provider.of<LocaleProvider>(context);
    final bool isFarsi = localeProvider.locale.languageCode == 'fa';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userId == null 
            ? (isFarsi ? 'برنامه هفتگی' : 'Weekly Plan') 
            : (isFarsi ? 'برنامه کاربر' : 'User Plan')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          )
        ],
      ),
      body: Consumer<WeeklyPlanProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return _buildErrorUI(provider.error!, isFarsi);
          }

          if (provider.weeklyPlan.isEmpty) {
            return Center(
              child: Text(isFarsi 
                ? 'هیچ برنامه‌ای یافت نشد' 
                : 'No weekly plan found'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.weeklyPlan.length,
            itemBuilder: (context, index) {
              final plan = provider.weeklyPlan[index];
              return _buildPlanCard(plan, provider, isFarsi);
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorUI(String message, bool isFarsi) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: Text(isFarsi ? 'تلاش مجدد' : 'Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(WeeklyPlanDto plan, WeeklyPlanProvider provider, bool isFarsi) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(plan.status),
          child: const Icon(Icons.calendar_month, color: Colors.white),
        ),
        title: Text(
          // انتخاب فیلد نام بر اساس زبان
          isFarsi 
              ? (plan.roleNameFa ?? plan.roleNameEn ?? 'نقش نامشخص') 
              : (plan.roleNameEn ?? plan.roleNameFa ?? 'Unknown Role'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (plan.userName != null)
              Text(
                '${isFarsi ? "خادم" : "User"}: ${plan.userName}',
                style: TextStyle(color: Colors.blueGrey[700], fontWeight: FontWeight.w600),
              ),
            Text('${isFarsi ? "تاریخ" : "Date"}: ${plan.serviceDate.toString().substring(0, 10)}'),
            Text('${isFarsi ? "وضعیت" : "Status"}: ${_translateStatus(plan.status, isFarsi)}'),
            if (plan.isConfirmed)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  isFarsi ? '✅ تأیید شده' : '✅ Confirmed',
                  style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        trailing: plan.status == 'Pending' ? _buildActionButtons(plan, provider) : null,
      ),
    );
  }

  Widget _buildActionButtons(WeeklyPlanDto plan, WeeklyPlanProvider provider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check_circle, color: Colors.green),
          onPressed: () => provider.markAttendance(plan.scheduleId, 'Accepted'),
        ),
        IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red),
          onPressed: () => provider.markAttendance(plan.scheduleId, 'Absent'),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepted': return Colors.green;
      case 'Absent': return Colors.red;
      default: return Colors.orange;
    }
  }

  String _translateStatus(String status, bool isFarsi) {
    switch (status) {
      case 'Accepted': return isFarsi ? 'حاضر هستم' : 'Attending';
      case 'Absent': return isFarsi ? 'غایب هستم' : 'Absent';
      default: return isFarsi ? 'در انتظار پاسخ' : 'Pending';
    }
  }
}