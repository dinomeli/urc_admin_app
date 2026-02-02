import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../providers/user_role_provider.dart';
import '../../data/models/user_role_dto.dart';

class UserRolesScreen extends StatefulWidget {
  const UserRolesScreen({super.key});

  @override
  State<UserRolesScreen> createState() => _UserRolesScreenState();
}

class _UserRolesScreenState extends State<UserRolesScreen> {
  String searchQuery = "";

@override
void initState() {
  super.initState();
  // فراخوانی متد جدید که هم رول‌ها و هم کل یوزرها را می‌گیرد
  Future.microtask(() =>
      Provider.of<UserRoleProvider>(context, listen: false).fetchInitialData());
}

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserRoleProvider>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final tr = locale.translate;
    final isFa = locale.locale.languageCode == 'fa';

    // فیلتر کردن لیست بر اساس جستجو
    final filteredList = provider.assignments.where((a) {
      final name = (a.userFullName ?? a.userName ?? "").toLowerCase();
      return name.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo.shade900,
        title: Text(tr('User Roles', 'مدیریت نقش‌ها'), 
          style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.fetchAllAssignments(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAssignmentDialog(context, provider, tr, isFa),
        backgroundColor: Colors.indigo.shade700,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(tr('Assign Role', 'تخصیص نقش'), 
          style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // بخش جستجو
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: tr('Search user...', 'جستجوی کاربر...'),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? _buildEmptyState(tr)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          return _buildUserRoleCard(
                              context, filteredList[index], provider, tr, isFa);
                        },
                      ),
          ),
        ],
      ),
    );
  }

 Widget _buildUserRoleCard(BuildContext context, UserRoleDto assignment,
    UserRoleProvider provider, Function tr, bool isFa) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16), // فضای بیشتر بین کارت‌ها
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(16), // پدینگ داخلی بیشتر
      child: Column( // استفاده از Column برای چیدمان عمودی بهتر
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.indigo.shade50,
                radius: 25,
                child: Text(
                  (assignment.userFullName ?? assignment.userName ?? "?")[0],
                  style: TextStyle(color: Colors.indigo.shade700, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.userFullName ?? assignment.userName ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    // نام رول با رنگ متمایز و فضای کامل
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isFa ? (assignment.roleNameFa ?? '') : (assignment.roleNameEn ?? ''),
                        style: TextStyle(fontSize: 13, color: Colors.indigo.shade900, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              // دکمه‌های عملیات
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                    onPressed: () => _showEditWeightDialog(context, assignment, provider, tr),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _confirmDelete(context, assignment, provider, tr),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20), // خط جداکننده برای بخش پایین کارت
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.scale_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "${tr('Assignment Weight', 'وزن تخصیص یافته')}: ${assignment.weight}",
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ],
              ),
              // یک لیبل وضعیت کوچک
              Text(
                tr('Active', 'فعال'),
                style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildEmptyState(Function tr) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(tr('No assignments found', 'تخصیصی یافت نشد')),
        ],
      ),
    );
  }

  // دیالوگ تخصیص نقش جدید
  void _showAssignmentDialog(BuildContext context, UserRoleProvider provider, Function tr, bool isFa) {
  String? selUserId;
  int? selRoleId;
  double weight = 1.0;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr('New Assignment', 'تخصیص نقش جدید')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ۱. انتخاب کاربر (از لیست تمام کاربران سیستم)
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: tr('Select User', 'انتخاب کاربر'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              isExpanded: true,
              value: selUserId,
              items: provider.allUsers.map((user) => DropdownMenuItem(
                value: user.id,
                child: Text(user.fullName),
              )).toList(),
              onChanged: (v) => setDialogState(() => selUserId = v),
            ),
            const SizedBox(height: 16),
            // ۲. انتخاب نقش خدمتی (از لیست ChurchRoles)
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: tr('Church Role', 'نقش خدمتی'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              isExpanded: true,
              value: selRoleId,
              items: provider.churchRoles.map((role) => DropdownMenuItem<int>(
                value: role['Id'] as int,
                child: Text(isFa ? (role['NameFa'] ?? '') : (role['NameEn'] ?? '')),
              )).toList(),
              onChanged: (v) => setDialogState(() => selRoleId = v),
            ),
            const SizedBox(height: 16),
            // ۳. وزن
            TextField(
              decoration: InputDecoration(
                labelText: tr('Weight', 'وزن'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => weight = double.tryParse(v) ?? 1.0,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Cancel', 'انصراف'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade700),
            onPressed: (selUserId != null && selRoleId != null) 
              ? () async {
                await provider.assignRole(selUserId!, selRoleId!, weight);
                Navigator.pop(ctx);
              } : null,
            child: Text(tr('Save', 'ذخیره'), style: const TextStyle(color: Colors.white)),
          )
        ],
      ),
    ),
  );
}

  void _showEditWeightDialog(BuildContext context, UserRoleDto assignment, UserRoleProvider provider, Function tr) {
    double newWeight = assignment.weight;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('Update Weight', 'بروزرسانی وزن')),
        content: TextField(
          decoration: InputDecoration(hintText: assignment.weight.toString()),
          keyboardType: TextInputType.number,
          onChanged: (v) => newWeight = double.tryParse(v) ?? assignment.weight,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Cancel', 'انصراف'))),
          ElevatedButton(
            onPressed: () async {
              await provider.updateWeight(assignment.userId, assignment.roleId, newWeight);
              Navigator.pop(ctx);
            },
            child: Text(tr('Update', 'بروزرسانی')),
          )
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserRoleDto assignment, UserRoleProvider provider, Function tr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('Delete', 'حذف')),
        content: Text(tr('Are you sure?', 'آیا از حذف این نقش مطمئن هستید؟')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('No', 'خیر'))),
          TextButton(
            onPressed: () async {
              await provider.removeRole(assignment.userId, assignment.roleId);
              Navigator.pop(ctx);
            },
            child: Text(tr('Yes, Delete', 'بله، حذف شود'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}