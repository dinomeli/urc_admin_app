import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/absence_provider.dart';
// فرض بر این است که پروایدر زبان شما اینجاست
import '../../../../core/providers/locale_provider.dart'; 
import 'dart:ui' as ui;
class AbsencesScreen extends StatefulWidget {
  const AbsencesScreen({super.key});

  @override
  State<AbsencesScreen> createState() => _AbsencesScreenState();
}

class _AbsencesScreenState extends State<AbsencesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AbsenceProvider>(context, listen: false).fetchMyAbsences());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AbsenceProvider>(context);
    // تشخیص زبان برای راست‌چین یا چپ‌چین کردن
   final locale = Provider.of<LocaleProvider>(context);
    
    final tr = locale.translate;
    final isFa = locale.locale.languageCode == 'fa';
    
    // تابع کمکی برای ترجمه (مطابق پروژه‌ی شما)
   // String tr(String en, String fa) => isFa ? fa : en;

    return Directionality(
      textDirection: isFa ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('My Absences', 'غیبت‌های من')),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreateDialog(context, tr, isFa),
          label: Text(tr('Add Absence', 'ثبت غیبت')),
          icon: const Icon(Icons.add),
        ),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null
                ? Center(child: Text(provider.error!))
                : provider.absences.isEmpty
                    ? _buildEmptyState(tr)
                    : RefreshIndicator(
                        onRefresh: () => provider.fetchMyAbsences(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: provider.absences.length,
                          itemBuilder: (context, index) {
                            final absence = provider.absences[index];
                            return _buildAbsenceCard(absence, provider, tr, isFa);
                          },
                        ),
                      ),
      ),
    );
  }

  Widget _buildEmptyState(Function tr) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 70, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(tr('No absences recorded', 'هیچ غیبتی ثبت نشده است')),
        ],
      ),
    );
  }

  Widget _buildAbsenceCard(absence, provider, Function tr, bool isFa) {
    final dateStr = '${DateFormat('yyyy/MM/dd').format(absence.startDate)} ${tr('to', 'تا')} ${DateFormat('yyyy/MM/dd').format(absence.endDate)}';
    
    return Card(
      child: ListTile(
        title: Text(dateStr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(absence.reason ?? tr('No reason provided', 'بدون دلیل')),
        trailing: IconButton(
          icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
          onPressed: () => _confirmDelete(context, provider, absence.id, tr),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, Function tr, bool isFa) {
    DateTime? tempStart;
    DateTime? tempEnd;
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: isFa ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: AlertDialog(
            title: Text(tr('New Absence', 'ثبت غیبت جدید')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _datePickerTile(
                  label: tr('Start Date', 'تاریخ شروع'),
                  selectedDate: tempStart,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setDialogState(() => tempStart = picked);
                  },
                  isFa: isFa,
                ),
                _datePickerTile(
                  label: tr('End Date', 'تاریخ پایان'),
                  selectedDate: tempEnd,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: tempStart ?? DateTime.now(),
                      firstDate: tempStart ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setDialogState(() => tempEnd = picked);
                  },
                  isFa: isFa,
                ),
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    labelText: tr('Reason (Optional)', 'دلیل (اختیاری)'),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('Cancel', 'انصراف'))),
              ElevatedButton(
                onPressed: () async {
                  if (tempStart == null || tempEnd == null) return;
                  final success = await Provider.of<AbsenceProvider>(context, listen: false)
                      .createAbsence(tempStart!, tempEnd!, reasonController.text);
                  if (mounted) Navigator.pop(context);
                },
                child: Text(tr('Submit', 'ثبت')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _datePickerTile({required String label, DateTime? selectedDate, required VoidCallback onTap, required bool isFa}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(selectedDate == null ? label : DateFormat('yyyy/MM/dd').format(selectedDate)),
      trailing: const Icon(Icons.calendar_month, size: 20),
      onTap: onTap,
    );
  }

  void _confirmDelete(BuildContext context, AbsenceProvider provider, int id, Function tr) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('Delete', 'حذف')),
        content: Text(tr('Are you sure?', 'آیا از حذف اطمینان دارید؟')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('No', 'خیر'))),
          TextButton(
            onPressed: () {
              provider.deleteAbsence(id);
              Navigator.pop(context);
            },
            child: Text(tr('Yes', 'بله'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}