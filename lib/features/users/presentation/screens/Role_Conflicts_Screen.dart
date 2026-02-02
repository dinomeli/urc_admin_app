import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/role_conflict_provider.dart';
import '../providers/user_role_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../data/models/role_conflict_dto.dart';

class RoleConflictsScreen extends StatefulWidget {
  const RoleConflictsScreen({super.key});

  @override
  State<RoleConflictsScreen> createState() => _RoleConflictsScreenState();
}

class _RoleConflictsScreenState extends State<RoleConflictsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoleConflictProvider>().fetchConflicts();
      if (context.read<UserRoleProvider>().churchRoles.isEmpty) {
        context.read<UserRoleProvider>().fetchInitialData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RoleConflictProvider>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final tr = locale.translate;
    
    final isFa = locale.locale.languageCode == 'fa';

    return Directionality(
      textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(tr('RoleConflicts', 'تضاد نقش‌ها')),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => provider.fetchConflicts(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.red.shade700,
          onPressed: () => _showCreateConflictDialog(context, tr, isFa),
          label: Text(tr('AddConflict', 'تضاد جدید'), style: const TextStyle(color: Colors.white)),
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        ),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildList(provider, tr, isFa),
      ),
    );
  }

  Widget _buildList(RoleConflictProvider provider, Function tr, bool isFa) {
    if (provider.conflicts.isEmpty) {
      return Center(child: Text(tr('NoConflictsFound', 'تضادی تعریف نشده است')));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.conflicts.length,
      itemBuilder: (context, index) {
        final conflict = provider.conflicts[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFFEBEE),
              child: Icon(Icons.block, color: Colors.red),
            ),
            title: Text(
              '${isFa ? conflict.roleANameFa : conflict.roleANameEn} ↔ ${isFa ? conflict.roleBNameFa : conflict.roleBNameEn}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(conflict.description ?? tr('NoDescription', 'بدون توضیح')),
            trailing: IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
              onPressed: () => _confirmDelete(context, conflict, tr, isFa),
            ),
          ),
        );
      },
    );
  }

  void _showCreateConflictDialog(BuildContext context, Function tr, bool isFa) {
    final roleProvider = context.read<UserRoleProvider>();
    int? rAId, rBId;
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Directionality(
          textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            title: Text(tr('NewConflict', 'تعریف تضاد')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRoleDropdown(tr('RoleA', 'نقش اول'), roleProvider.churchRoles, (v) => rAId = v, isFa),
                const SizedBox(height: 10),
                _buildRoleDropdown(tr('RoleB', 'نقش دوم'), roleProvider.churchRoles, (v) => rBId = v, isFa),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: tr('Description', 'توضیحات')),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Cancel', 'انصراف'))),
              ElevatedButton(
                onPressed: () async {
                  if (rAId != null && rBId != null) {
                    final success = await context.read<RoleConflictProvider>().createConflict(
                      RoleConflictDto(id: 0, roleAId: rAId!, roleBId: rBId!, description: descController.text),
                    );
                    if (success) Navigator.pop(ctx);
                  }
                },
                child: Text(tr('Save', 'ذخیره')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown(String label, List<Map<String, dynamic>> roles, Function(int?) onChanged, bool isFa) {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: roles.map((r) => DropdownMenuItem<int>(
        value: r['Id'],
        child: Text(isFa ? r['NameFa'] : r['NameEn']),
      )).toList(),
      onChanged: onChanged,
    );
  }

  void _confirmDelete(BuildContext context, RoleConflictDto conflict, Function tr, bool isFa) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(tr('Delete', 'حذف')),
          content: Text(tr('ConfirmDeleteConflict', 'این تضاد حذف شود؟')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('No', 'خیر'))),
            TextButton(
              onPressed: () async {
                await context.read<RoleConflictProvider>().deleteConflict(conflict.id);
                Navigator.pop(ctx);
              },
              child: Text(tr('Yes', 'بله'), style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}