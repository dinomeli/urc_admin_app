import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../data/models/my_schedule_dto.dart';
import '../../presentation/providers/my_schedule_provider.dart';
import '../../../users/presentation/providers/user_provider.dart'; // پروایدر اصلی کاربران
import 'dart:ui' as ui;

class MyScheduleScreen extends StatefulWidget {
  const MyScheduleScreen({super.key});

  @override
  State<MyScheduleScreen> createState() => _MyScheduleScreenState();
}

class _MyScheduleScreenState extends State<MyScheduleScreen> {
  String? selectedUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  //void _loadData() {
    // فراخوانی متدها از پروایدرهای مربوطه
 //   context.read<MyScheduleProvider>().fetchMySchedules(userId: selectedUserId);
   // context.read<UserProvider>().fetchUsers(); 
 // }
void _loadData() async {
    // ابتدا لیست برنامه‌ها
    await context.read<MyScheduleProvider>().fetchMySchedules(userId: selectedUserId);
    
    // سپس لیست کاربران (اگر ادمین بود)
    try {
      await context.read<UserProvider>().fetchUsers();
    } catch (e) {
      print('خطا در لود کاربران: $e');
      // اینجا می‌توانید یک اسنک‌بار نشان دهید که دسترسی به لیست کاربران ندارید
    }
  }
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyScheduleProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final locale = Provider.of<LocaleProvider>(context);
    
    final tr = locale.translate;
    final isFa = locale.locale.languageCode == 'fa';

    // استفاده از لیست کاربران از UserProvider
    final usersList = userProvider.users; 

    return Directionality(
      textDirection: isFa ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          elevation: 2,
          backgroundColor: Colors.indigo.shade900,
          foregroundColor: Colors.white,
          title: Text(selectedUserId == null 
              ? tr('MySchedules', 'برنامه‌های من') 
              : tr('UserSchedules', 'برنامه کاربر')),
          actions: [
            // بخش انتخاب کاربر (فیلتر مخصوص مدیر)
            PopupMenuButton<String>(
              icon: const Icon(Icons.person_search),
              onSelected: (String userId) {
                setState(() => selectedUserId = userId);
                _loadData();
              },
              itemBuilder: (BuildContext context) {
                return usersList.map((user) {
                  return PopupMenuItem<String>(
                    value: user.id.toString(),
                    child: Text(user.fullName ?? '---'),
                  );
                }).toList();
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
          ],
        ),
        body: Column(
          children: [
            if (selectedUserId != null) _buildFilterChip(tr),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                      ? _buildErrorUI(provider.error!, tr)
                      : _buildScheduleList(provider, tr, isFa),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(Function tr) {
    return Container(
      width: double.infinity,
      color: Colors.orange.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tr('FilteredView', 'مشاهده برنامه کاربر انتخاب شده'), 
               style: TextStyle(color: Colors.orange.shade900, fontSize: 12)),
          InkWell(
            onTap: () {
              setState(() => selectedUserId = null);
              _loadData();
            },
            child: Icon(Icons.close, size: 20, color: Colors.orange.shade900),
          )
        ],
      ),
    );
  }

  Widget _buildScheduleList(MyScheduleProvider provider, Function tr, bool isFa) {
    if (provider.mySchedules.isEmpty) {
      return Center(
        child: Text(tr('NoSchedules', 'برنامه‌ای یافت نشد')),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.mySchedules.length,
      itemBuilder: (context, index) {
        final schedule = provider.mySchedules[index];
        return _buildScheduleCard(schedule, provider, tr, isFa);
      },
    );
  }

  Widget _buildScheduleCard(MyScheduleDto schedule, MyScheduleProvider provider, Function tr, bool isFa) {
  final bool isAccepted = schedule.status == 'Accepted';
  final bool isAbsent = schedule.status == 'Absent';

  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.indigo.shade50,
        child: Icon(Icons.event, color: Colors.indigo.shade900),
      ),
      title: Text(
        isFa ? (schedule.roleNameFa ?? '---') : (schedule.roleNameEn ?? '---'),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat(isFa ? 'yyyy/MM/dd' : 'dd MMM yyyy').format(schedule.serviceDate)),
          // اگر نام کاربر وجود داشت (یعنی ادمین دارد لیست کلی را می‌بیند) نمایش بده
          if (schedule.userFullName != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "${tr('User', 'کاربر')}: ${schedule.userFullName}",
                style: TextStyle(color: Colors.blueGrey.shade700, fontSize: 12),
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.check_circle, color: isAccepted ? Colors.green : Colors.grey.shade300),
            onPressed: () => _handleAttendance(provider, schedule.assignmentId, true, tr),
          ),
          IconButton(
            icon: Icon(Icons.cancel, color: isAbsent ? Colors.red : Colors.grey.shade300),
            onPressed: () => _handleAttendance(provider, schedule.assignmentId, false, tr),
          ),
        ],
      ),
    ),
  );
}

  void _handleAttendance(MyScheduleProvider provider, int id, bool present, Function tr) async {
    final success = await provider.markAttendance(id, present);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Success', 'انجام شد'))),
      );
    }
  }

  Widget _buildErrorUI(String error, Function tr) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(error, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: _loadData, child: Text(tr('Retry', 'تلاش مجدد'))),
        ],
      ),
    );
  }
}