import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/providers/locale_provider.dart'; // اضافه شد
import '../providers/calendar_provider.dart';
import '../../data/models/calendar_event_dto.dart';

class ChurchCalendarScreen extends StatefulWidget {
  const ChurchCalendarScreen({super.key});

  @override
  State<ChurchCalendarScreen> createState() => _ChurchCalendarScreenState();
}

class _ChurchCalendarScreenState extends State<ChurchCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CalendarProvider>(context, listen: false).fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalendarProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(
      context,
    ); // دسترسی به زبان
    final tr = localeProvider.translate;
    final isFarsi = localeProvider.locale.languageCode == 'fa';

    return Scaffold(
      appBar: AppBar(title: Text(tr('ChurchCalendar', 'تقویم کلیسا'))),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(child: Text(provider.error!))
          : Column(
              children: [
                TableCalendar(
                  locale: isFarsi ? 'fa_IR' : 'en_US',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

                  // اصلاح نام پارامتر در اینجا:
                  // در متد onDaySelected:
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });

                    // پیدا کردن رویداد با مقایسه دقیق میلادی
                    final eventsOnDay = provider.events.where((e) {
                      // تبدیل رشته سرور به DateTime
                      final eventDate = DateTime.parse(e.start);
                      // استفاده از تابع داخلی برای مقایسه روز/ماه/سال بدون درگیر شدن با ساعت
                      return isSameDay(eventDate, selectedDay);
                    }).toList();

                    if (eventsOnDay.isNotEmpty) {
                      provider.fetchScheduleDetails(eventsOnDay.first.id);
                    }
                  },

                  // در متد eventLoader:
                  eventLoader: (day) {
                    return provider.events
                        .where((e) => isSameDay(DateTime.parse(e.start), day))
                        .toList();
                  },
                  // راست‌چین یا چپ‌چین کردن هدر تقویم
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontFamily: isFarsi ? 'Vazir' : 'Roboto',
                      fontSize: 17,
                    ),
                  ),
                  calendarStyle: const CalendarStyle(
                    markerDecoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFF00ADB5),
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Color(0x4D00ADB5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: provider.selectedDetail == null
                      ? Center(
                          child: Text(
                            tr(
                              'SelectDayToSeeDetails',
                              'روزی را برای مشاهده جزئیات انتخاب کنید',
                            ),
                          ),
                        )
                      : _buildDetailList(provider, tr, isFarsi),
                ),
              ],
            ),
    );
  }

  // متد کمکی برای ساخت لیست جزئیات با ترجمه
  Widget _buildDetailList(
    CalendarProvider provider,
    Function tr,
    bool isFarsi,
  ) {
    final detail = provider.selectedDetail!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tr('Date', 'تاریخ')}: ${detail.serviceDate}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${tr('Status', 'وضعیت')}: ${detail.isConfirmed ? tr('Confirmed', 'تأیید شده') : tr('Pending', 'در انتظار')}',
                ),
                const Divider(height: 32),
                Text(
                  tr('Assignments', 'تخصیص‌ها'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00ADB5),
                  ),
                ),
                const SizedBox(height: 10),
                ...detail.assignments.map(
                  (a) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.person, size: 20),
                    ),
                    title: Text(
                      a.userFullName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${isFarsi ? (a.roleNameFa ?? a.roleNameEn) : a.roleNameEn} - ${tr(a.status, a.status)}',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
