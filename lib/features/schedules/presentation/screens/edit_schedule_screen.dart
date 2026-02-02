// lib/features/schedules/presentation/screens/edit_schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/locale_provider.dart';
import '../providers/schedule_provider.dart';
import '../../data/models/edit_schedule_response.dart';

class EditScheduleScreen extends StatefulWidget {
  final int? scheduleId;
  const EditScheduleScreen({super.key, this.scheduleId});

  @override
  State<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.scheduleId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<ScheduleProvider>(context, listen: false)
            .loadEditData(widget.scheduleId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final tr = locale.translate;
    final provider = Provider.of<ScheduleProvider>(context);
    final editData = provider.editData;
    final schedule = editData?.schedule;
    final isConfirmed = schedule?.isConfirmed ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo.shade900,
        title: Text(tr('Edit Schedule', 'ویرایش برنامه'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (!isConfirmed && schedule != null)
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
              onPressed: () => _confirmAndLock(context, tr, provider, schedule.id),
            ),
        ],
      ),
      floatingActionButton: (!isConfirmed && editData != null)
          ? FloatingActionButton.extended(
              onPressed: () => _showAddDialog(context, tr, provider),
              backgroundColor: Colors.indigo.shade700,
              icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
              label: Text(tr('Add Person', 'افزودن شخص'),
                  style: const TextStyle(color: Colors.white)),
            )
          : null,
      body: Directionality(
        textDirection: locale.textDirection,
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null
                ? _buildErrorView(provider, tr)
                : (editData == null || schedule == null)
                    ? Center(child: Text(tr('No data', 'داده‌ای یافت نشد')))
                    : _buildContent(context, editData, tr, provider, isConfirmed),
      ),
    );
  }

  Widget _buildContent(BuildContext context, EditScheduleResponse editData,
      Function tr, ScheduleProvider provider, bool isConfirmed) {
    final schedule = editData.schedule!;
    final locale = Provider.of<LocaleProvider>(context);
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', locale.locale.languageCode);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade700, Colors.indigo.shade500],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('Service Information', 'اطلاعات مراسم'),
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  schedule.serviceDate != null
                      ? dateFormat.format(schedule.serviceDate!)
                      : '---',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isConfirmed
                        ? tr('Status: Locked', 'وضعیت: نهایی شده')
                        : tr('Status: Editing', 'وضعیت: در حال ویرایش'),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            // --- بخش اصلاح شده ---
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final assignment = schedule.safeAssignments[index];
                return _buildAssignmentTile(assignment, isConfirmed, provider, tr);
              },
              childCount: schedule.safeAssignments.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  // --- متدهای کمکی ---

  void _confirmAndLock(
      BuildContext context, Function tr, ScheduleProvider provider, int? id) async {
    if (id == null) return;
    await provider.confirmSchedule(id);
    provider.loadEditData(id);
  }

  void _confirmDelete(
      BuildContext context, int id, ScheduleProvider provider, Function tr) async {
    await provider.removeAssignment(id);
    if (widget.scheduleId != null) provider.loadEditData(widget.scheduleId!);
  }

  Widget _buildErrorView(ScheduleProvider provider, Function tr) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(provider.error ?? 'Error'),
          TextButton(
            onPressed: () => provider.loadEditData(widget.scheduleId!),
            child: Text(tr('Try Again', 'تلاش مجدد')),
          )
        ],
      ),
    );
  }

  Widget _buildAssignmentTile(
      dynamic assignment, bool isConfirmed, ScheduleProvider provider, Function tr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade50,
          child: Icon(Icons.assignment_ind_outlined, color: Colors.indigo.shade700),
        ),
        title: Text(assignment.roleName ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(assignment.userFullName ?? ''),
        trailing: !isConfirmed
            ? IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                onPressed: () => _confirmDelete(context, assignment.id!, provider, tr),
              )
            : null,
      ),
    );
  }

  void _showAddDialog(BuildContext context, Function tr, ScheduleProvider provider) {
    final editData = provider.editData;
    if (editData == null) return;

    int? selectedRoleId;
    String? selectedUserId;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(tr('Add New Assignment', 'افزودن شخص جدید')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: tr('Role', 'نقش'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                value: selectedRoleId,
                items: editData.roles
                    .map((role) => DropdownMenuItem(
                        value: role.id,
                        child: Text(Provider.of<LocaleProvider>(context).locale.languageCode == 'fa'
                            ? role.nameFa ?? ''
                            : role.nameEn ?? '')))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedRoleId = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: tr('Person', 'شخص'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                value: selectedUserId,
                items: editData.availableUsers
                    .map((user) =>
                        DropdownMenuItem(value: user.id, child: Text(user.fullName ?? '')))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedUserId = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text(tr('Cancel', 'انصراف'))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade700),
              onPressed: (selectedRoleId != null && selectedUserId != null)
                  ? () async {
                      Navigator.pop(context);
                      await provider.addAssignment(
                        scheduleId: widget.scheduleId!,
                        roleId: selectedRoleId!,
                        userId: selectedUserId!,
                      );
                      provider.loadEditData(widget.scheduleId!);
                    }
                  : null,
              child: Text(tr('Add', 'افزودن'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}