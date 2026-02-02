import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../providers/schedule_provider.dart';
import 'edit_schedule_screen.dart';

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  
  @override
  void initState() {
    super.initState();
    // فراخوانی فقط یکبار هنگام ورود به صفحه، بدون توجه به خالی بودن لیست
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().fetchSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final tr = locale.translate;
    final provider = Provider.of<ScheduleProvider>(context);
    final isFa = locale.locale.languageCode == 'fa';

    // آن شرط خطرناک قبلی از اینجا حذف شد

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo.shade900,
        title: Text(
          tr('Church Schedules', 'برنامه‌های عبادت'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          _buildLanguageButton(locale),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGenerateDialog(context, provider, tr),
        backgroundColor: Colors.indigo.shade700,
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: Text(tr('Generate', 'تولید برنامه'), style: const TextStyle(color: Colors.white)),
      ),
      body: Directionality(
        textDirection: locale.textDirection,
        child: _buildBody(provider, tr, isFa),
      ),
    );
  }

  Widget _buildBody(ScheduleProvider provider, Function tr, bool isFa) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (provider.error != null) {
      return _buildErrorView(provider, tr);
    }

    if (provider.schedules.isEmpty) {
      // استفاده از RefreshIndicator حتی در حالت خالی برای رفرش دستی
      return RefreshIndicator(
        onRefresh: provider.fetchSchedules,
        child: ListView( // ListView استفاده شد تا Pull-to-Refresh کار کند
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            _buildEmptyView(tr),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.fetchSchedules,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.schedules.length,
        itemBuilder: (context, index) => _buildScheduleCard(context, provider.schedules[index], provider, tr, isFa),
      ),
    );
  }

  // بقیه متدها (بدون تغییر زیاد فقط به این کلاس منتقل شدند)

  Widget _buildLanguageButton(LocaleProvider locale) {
    return IconButton(
      icon: const Icon(Icons.language),
      onPressed: () {
        final newLocale = locale.locale.languageCode == 'fa' ? const Locale('en') : const Locale('fa');
        locale.setLocale(newLocale);
      },
    );
  }

  Widget _buildErrorView(ScheduleProvider provider, Function tr) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 10),
          Text("${tr('Error', 'خطا')}: ${provider.error}"),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: provider.fetchSchedules, child: Text(tr('Try Again', 'تلاش مجدد'))),
        ],
      ),
    );
  }

  Widget _buildEmptyView(Function tr) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.event_busy, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(tr('No schedules found', 'برنامه‌ای یافت نشد'), style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, dynamic sch, ScheduleProvider provider, Function tr, bool isFa) {
    final bool isConfirmed = sch.isConfirmed ?? false;
    final dateStr = sch.serviceDate != null
        ? DateFormat('EEEE, d MMMM', isFa ? 'fa' : 'en').format(sch.serviceDate!)
        : tr('Unknown date', 'تاریخ نامشخص');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${sch.safeAssignmentsCount} ${tr('assignments', 'تخصیص')}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isConfirmed)
              IconButton(
                icon: const Icon(Icons.lock_outline, color: Colors.green),
                onPressed: () => _confirmAndLock(context, tr, provider, sch.id),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDeleteSchedule(context, tr, provider, sch.id),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditScheduleScreen(scheduleId: sch.id!)),
        ),
      ),
    );
  }

  // منطق Dialogها دقیقاً مشابه قبل اما به داخل کلاس منتقل شد...
  // (برای کوتاه شدن پاسخ، متدهای دیالوگ را اینجا تکرار نکردم اما حتماً باید در کلاس کپی شوند)
  
  void _showGenerateDialog(BuildContext context, ScheduleProvider provider, Function tr) {
    final controller = TextEditingController(text: '8');
    bool includeCommunion = true;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(tr('Generate', 'تولید برنامه')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: controller, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: tr('Weeks', 'تعداد هفته‌ها'))),
              CheckboxListTile(
                title: Text(tr('Communion', 'عشای ربانی')),
                value: includeCommunion,
                onChanged: (v) => setState(() => includeCommunion = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Cancel', 'انصراف'))),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await provider.generateSchedules(int.tryParse(controller.text) ?? 8, includeCommunion);
                // نیازی به fetch دستی نیست اگر متد generate در پروایدر خودش دیتا را آپدیت کند، 
                // اما برای اطمینان گذاشتیم.
                provider.fetchSchedules();
              },
              child: Text(tr('Generate', 'تولید')),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAndLock(BuildContext context, Function tr, ScheduleProvider provider, int? id) async {
    if (id == null) return;
    final conf = await _showSimpleDialog(context, tr('Confirm', 'تأیید نهایی'), tr('Lock?', 'آیا از قفل کردن مطمئن هستید؟'), tr);
    if (conf) {
      await provider.confirmSchedule(id);
      provider.fetchSchedules();
    }
  }

  void _confirmDeleteSchedule(BuildContext context, Function tr, ScheduleProvider provider, int? id) async {
    if (id == null) return;
    final conf = await _showSimpleDialog(context, tr('Delete', 'حذف'), tr('Are you sure?', 'آیا حذف شود؟'), tr);
    if (conf) {
      await provider.deleteSchedule(id);
      provider.fetchSchedules();
    }
  }

  Future<bool> _showSimpleDialog(BuildContext context, String title, String content, Function tr) async {
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('No', 'خیر'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr('Yes', 'بله'))),
        ],
      ),
    ) ?? false;
  }
}