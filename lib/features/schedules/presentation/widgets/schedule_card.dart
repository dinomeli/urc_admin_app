import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ← این خط رو اضافه کن

import '../../data/models/church_schedule.dart';
import '../../../../core/providers/locale_provider.dart'; // برای translate

class ScheduleCard extends StatelessWidget {
  final ChurchSchedule schedule;
  final VoidCallback onTap;

  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // حالا Provider.of کار می‌کنه
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final tr = localeProvider.translate;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          schedule.serviceDate.toString().substring(0, 10), // یا schedule.serviceDate.toPersianDate()
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          tr('${schedule.assignments.length} assignments', '${schedule.assignments.length} تخصیص'),
          style: TextStyle(color: Colors.grey[700]),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.teal),
        onTap: onTap,
      ),
    );
  }
}