import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/church_role_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../data/models/church_role_dto.dart';

class ChurchRolesScreen extends StatefulWidget {
  const ChurchRolesScreen({super.key});

  @override
  State<ChurchRolesScreen> createState() => _ChurchRolesScreenState();
}

class _ChurchRolesScreenState extends State<ChurchRolesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ChurchRoleProvider>().fetchRoles());
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final tr = locale.translate;
    final roleProvider = Provider.of<ChurchRoleProvider>(context);
    final isFa = locale.locale.languageCode == 'fa';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo.shade900,
        title: Text(tr('Church Roles', 'نقش‌های کلیسا'), style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => roleProvider.fetchRoles()),
        ],
      ),
      body: roleProvider.isLoading && roleProvider.roles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => roleProvider.fetchRoles(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: roleProvider.roles.length,
                itemBuilder: (context, index) {
                  final role = roleProvider.roles[index];
                  return _buildRoleCard(role, isFa, tr);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        onPressed: () => _showRoleForm(context, tr),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(tr('New Role', 'نقش جدید'), style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildRoleCard(ChurchRoleDto role, bool isFa, Function tr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: role.isActive ? Colors.indigo.shade50 : Colors.grey.shade100,
          child: Icon(Icons.church, color: role.isActive ? Colors.indigo : Colors.grey),
        ),
        title: Text(
          isFa ? (role.nameFa ?? role.nameEn) : role.nameEn,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${tr('Required', 'نیاز کل')}: ${role.requiredCountPerService} | '
                '${role.isNonRepeatable ? tr('Unique', 'غیرقابل تکرار') : tr('Repeatable', 'تکرارپذیر')}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                '👫 ${tr('Men', 'مرد')}: ${role.requiredMen}  ${tr('Women', 'زن')}: ${role.requiredWomen}',
                style: TextStyle(fontSize: 12, color: Colors.indigo.shade400, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (val) {
            if (val == 'edit') _showRoleForm(context, tr, role: role);
            if (val == 'delete') _showDeleteDialog(context, role, tr);
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'edit', child: Row(children: [const Icon(Icons.edit, size: 18), const SizedBox(width: 8), Text(tr('Edit', 'ویرایش'))])),
            PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete, color: Colors.red, size: 18), const SizedBox(width: 8), Text(tr('Delete', 'حذف'))])),
          ],
        ),
      ),
    );
  }

  void _showRoleForm(BuildContext context, Function tr, {ChurchRoleDto? role}) {
    final nameEnController = TextEditingController(text: role?.nameEn);
    final nameFaController = TextEditingController(text: role?.nameFa);
    final countController = TextEditingController(text: role?.requiredCountPerService.toString() ?? '1');
    final menController = TextEditingController(text: role?.requiredMen.toString() ?? '0');
    final womenController = TextEditingController(text: role?.requiredWomen.toString() ?? '0');
    
    bool isActive = role?.isActive ?? true;
    bool useWeight = role?.useWeight ?? false;
    bool isNonRepeatable = role?.isNonRepeatable ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(role == null ? tr('Create Role', 'ایجاد نقش') : tr('Edit Role', 'ویرایش نقش'), 
                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildTextField(nameEnController, tr('Name (English)', 'نام (انگلیسی)')),
                _buildTextField(nameFaController, tr('Name (Farsi)', 'نام (فارسی)')),
                _buildTextField(countController, tr('Total Required', 'کل تعداد مورد نیاز'), isNumber: true),
                
                // ردیف برای حداقل تعداد زن و مرد
                Row(
                  children: [
                    Expanded(child: _buildTextField(menController, tr('Min Men', 'حداقل مرد'), isNumber: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(womenController, tr('Min Women', 'حداقل زن'), isNumber: true)),
                  ],
                ),
                
                SwitchListTile(
                  title: Text(tr('Is Active', 'فعال باشد')),
                  value: isActive,
                  onChanged: (v) => setSheetState(() => isActive = v),
                ),
                SwitchListTile(
                  title: Text(tr('Use Weight', 'استفاده از وزن (اولویت)')),
                  value: useWeight,
                  onChanged: (v) => setSheetState(() => useWeight = v),
                ),
                SwitchListTile(
                  title: Text(tr('Non-Repeatable', 'غیرقابل تکرار در یک بازه')),
                  value: isNonRepeatable,
                  onChanged: (v) => setSheetState(() => isNonRepeatable = v),
                ),
                
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    onPressed: () async {
                      final dto = ChurchRoleDto(
                        id: role?.id ?? 0,
                        nameEn: nameEnController.text,
                        nameFa: nameFaController.text,
                        isActive: isActive,
                        requiredCountPerService: int.tryParse(countController.text) ?? 1,
                        requiredMen: int.tryParse(menController.text) ?? 0,
                        requiredWomen: int.tryParse(womenController.text) ?? 0,
                        useWeight: useWeight,
                        isNonRepeatable: isNonRepeatable,
                      );

                      bool success;
                      if (role == null) {
                        success = await context.read<ChurchRoleProvider>().createRole(dto);
                      } else {
                        success = await context.read<ChurchRoleProvider>().updateRole(role.id, dto);
                      }

                      if (success && context.mounted) Navigator.pop(context);
                    },
                    child: context.watch<ChurchRoleProvider>().isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : Text(tr('Save', 'ذخیره'), style: const TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ChurchRoleDto role, Function tr) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('Delete Role', 'حذف نقش')),
        content: Text(tr('Are you sure you want to delete this role?', 'آیا از حذف این نقش مطمئن هستید؟')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('Cancel', 'لغو'))),
          TextButton(
            onPressed: () async {
              await context.read<ChurchRoleProvider>().deleteRole(role.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(tr('Delete', 'حذف'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label, 
          labelStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
        ),
      ),
    );
  }
}