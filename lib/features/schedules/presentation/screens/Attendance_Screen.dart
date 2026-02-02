import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../data/models/attendance_dto.dart';
import 'dart:ui' as ui;

class AttendanceScreen extends StatefulWidget {
  final int? scheduleId;

  const AttendanceScreen({super.key, this.scheduleId});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AttendanceProvider>();
      if (widget.scheduleId != null) {
        provider.fetchBySchedule(widget.scheduleId!);
      } else {
        provider.fetchAll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
     final locale = Provider.of<LocaleProvider>(context);
    final tr = locale.translate;
    
    final isFa = locale.locale.languageCode == 'fa';

    final list = widget.scheduleId != null ? provider.scheduleAttendances : provider.attendances;

    return Directionality(
      textDirection: isFa ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.indigo.shade900,
          title: Text(
            widget.scheduleId != null 
                ? tr('ScheduleAttendance', 'حضور و غیاب برنامه') 
                : tr('AttendanceList', 'لیست کل حضورها'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => widget.scheduleId != null 
                  ? provider.fetchBySchedule(widget.scheduleId!) 
                  : provider.fetchAll(),
            ),
          ],
        ),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null
                ? _buildErrorState(provider.error!, tr)
                : _buildAttendanceList(list, provider, tr, isFa),
      ),
    );
  }

  Widget _buildAttendanceList(List<AttendanceDto> list, AttendanceProvider provider, Function tr, bool isFa) {
    if (list.isEmpty) {
      return Center(
        child: Text(tr('NoDataFound', 'اطلاعاتی یافت نشد')),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final att = list[index];
        return _buildAttendanceCard(att, provider, tr, isFa);
      },
    );
  }

  Widget _buildAttendanceCard(AttendanceDto att, AttendanceProvider provider, Function tr, bool isFa) {
    Color statusColor = Colors.grey;
    if (att.status == 'Accepted') statusColor = Colors.green;
    else if (att.status == 'Absent') statusColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // نشانگر وضعیت در سمت مناسب بر اساس زبان
            Container(
              width: 5,
              height: 50,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    att.userFullName ?? tr('UnknownUser', 'کاربر نامشخص'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _buildInfoItem(Icons.work_outline, att.roleName ?? '---'),
                      _buildInfoItem(
                        Icons.calendar_today_outlined, 
                        DateFormat(isFa ? 'yyyy/MM/dd' : 'dd MMM yyyy').format(att.serviceDate)
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // نمایش وضعیت به صورت متنی (دوزبانه)
                  Text(
                    tr(att.status, att.status), // ترجمه Accepted, Absent, Pending
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            // دکمه‌های تایید یا رد حضور
            Row(
              children: [
                _buildActionButton(
                  icon: Icons.check_circle_rounded,
                  color: att.status == 'Accepted' ? Colors.green : Colors.grey.shade300,
                  onTap: () => provider.markAttendance(att.id, true),
                  tooltip: tr('MarkAsPresent', 'ثبت حضور'),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.cancel_rounded,
                  color: att.status == 'Absent' ? Colors.red : Colors.grey.shade300,
                  onTap: () => provider.markAttendance(att.id, false),
                  tooltip: tr('MarkAsAbsent', 'ثبت غیبت'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon, 
    required Color color, 
    required VoidCallback onTap,
    required String tooltip
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 30),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, Function tr) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(tr('ErrorLoadingData', 'خطا در بارگذاری اطلاعات')),
          const SizedBox(height: 8),
          Text(error, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => widget.scheduleId != null 
                ? context.read<AttendanceProvider>().fetchBySchedule(widget.scheduleId!) 
                : context.read<AttendanceProvider>().fetchAll(),
            icon: const Icon(Icons.refresh),
            label: Text(tr('Retry', 'تلاش مجدد')),
          )
        ],
      ),
    );
  }
}