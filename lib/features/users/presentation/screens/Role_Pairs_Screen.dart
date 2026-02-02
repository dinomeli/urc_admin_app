import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/role_pair_provider.dart';
import '../providers/user_role_provider.dart';
import '../../../../core/providers/locale_provider.dart'; // مسیر لوکال پروایدر خودتان را چک کنید
import '../../data/models/role_pair_dto.dart';

class RolePairsScreen extends StatefulWidget {
  const RolePairsScreen({super.key});

  @override
  State<RolePairsScreen> createState() => _RolePairsScreenState();
}

class _RolePairsScreenState extends State<RolePairsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserRoleProvider>();
      if (userProvider.allUsers.isEmpty) {
        userProvider.fetchInitialData();
      }
      context.read<RolePairProvider>().fetchPairs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pairProvider = Provider.of<RolePairProvider>(context);
     final locale = Provider.of<LocaleProvider>(context);
    final tr = locale.translate;
    
    final isFa = locale.locale.languageCode == 'fa';

    // استفاده از تابع ترجمه و تشخیص زبان از پروایدر شما
   
    //final bool isFa = localProvider.isFa;

    return Directionality(
      textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.indigo.shade900,
          title: Text(
            tr('RolePairs', 'مدیریت جفت‌نقش‌ها'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => pairProvider.fetchPairs(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.indigo.shade700,
          onPressed: () => _showCreatePairDialog(context, tr, isFa),
          label: Text(
            tr('AddNewPair', 'افزودن جفت جدید'),
            style: const TextStyle(color: Colors.white),
          ),
          icon: const Icon(Icons.add_link, color: Colors.white),
        ),
        body: pairProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : pairProvider.pairs.isEmpty
                ? _buildEmptyState(tr)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pairProvider.pairs.length,
                    itemBuilder: (context, index) => _buildPairCard(pairProvider.pairs[index], tr, isFa),
                  ),
      ),
    );
  }

  Widget _buildPairCard(RolePairDto pair, Function tr, bool isFa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: pair.alwaysTogether ? Colors.green.shade50 : Colors.amber.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  pair.alwaysTogether ? Icons.link : Icons.link_off,
                  size: 16,
                  color: pair.alwaysTogether ? Colors.green.shade700 : Colors.amber.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  pair.alwaysTogether 
                      ? tr('AlwaysTogether', 'الزام حضور همزمان')
                      : tr('PreferredTogether', 'رابطه ترجیحی'),
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold,
                    color: pair.alwaysTogether ? Colors.green.shade700 : Colors.amber.shade700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildUserDisplay(pair.personAName, pair.roleAName, Colors.indigo),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.swap_horiz, color: Colors.grey.shade400, size: 28),
                ),
                _buildUserDisplay(pair.personBName, pair.roleBName, Colors.teal),
              ],
            ),
          ),
          const Divider(height: 1),
          Align(
            alignment: isFa ? Alignment.centerLeft : Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _confirmDelete(pair, tr, isFa),
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              label: Text(tr('DeletePair', 'حذف این جفت'), style: const TextStyle(color: Colors.red)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildUserDisplay(String? name, String? role, Color color) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 25,
            child: Icon(Icons.person, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            name ?? "---",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            role ?? "---",
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCreatePairDialog(BuildContext context, Function tr, bool isFa) {
    final userProvider = context.read<UserRoleProvider>();
    final pairProvider = context.read<RolePairProvider>();
    String? pAId, pBId;
    int? rAId, rBId;
    bool alwaysTogether = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Directionality(
          textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(tr('CreateNewPair', 'تعریف جفت جدید')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDropdown(tr('SelectPersonA', 'انتخاب شخص اول'), 
                      userProvider.allUsers.map((u) => {'id': u.id, 'name': u.fullName}).toList(), (v) => pAId = v),
                  _buildDropdown(tr('RoleA', 'نقش شخص اول'), 
                      userProvider.churchRoles.map((r) => {'id': r['Id'], 'name': isFa ? r['NameFa'] : r['NameEn']}).toList(), (v) => rAId = v as int?),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider()),
                  _buildDropdown(tr('SelectPersonB', 'انتخاب شخص دوم'), 
                      userProvider.allUsers.map((u) => {'id': u.id, 'name': u.fullName}).toList(), (v) => pBId = v),
                  _buildDropdown(tr('RoleB', 'نقش شخص دوم'), 
                      userProvider.churchRoles.map((r) => {'id': r['Id'], 'name': isFa ? r['NameFa'] : r['NameEn']}).toList(), (v) => rBId = v as int?),
                  SwitchListTile(
                    title: Text(tr('AlwaysTogether', 'الزام حضور همزمان')),
                    value: alwaysTogether,
                    onChanged: (v) => setDialogState(() => alwaysTogether = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Cancel', 'انصراف'))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade700),
                onPressed: () async {
                  if (pAId != null && pBId != null && rAId != null && rBId != null) {
                    await pairProvider.createPair(RolePairDto(
                      id: 0, personAId: pAId!, personBId: pBId!,
                      roleAId: rAId!, roleBId: rBId!, alwaysTogether: alwaysTogether,
                    ));
                    if (context.mounted) Navigator.pop(ctx);
                  }
                },
                child: Text(tr('SavePair', 'ثبت جفت'), style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<Map<String, dynamic>> items, Function(dynamic) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<dynamic>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        items: items.map((i) => DropdownMenuItem(value: i['id'], child: Text(i['name'].toString()))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _confirmDelete(RolePairDto pair, Function tr, bool isFa) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(tr('ConfirmDelete', 'تایید حذف')),
          content: Text(tr('DeleteConfirmationMessage', 'آیا از حذف این رابطه اطمینان دارید؟')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('No', 'خیر'))),
            TextButton(
              onPressed: () {
                context.read<RolePairProvider>().deletePair(pair.id);
                Navigator.pop(ctx);
              },
              child: Text(tr('YesDelete', 'بله، حذف شود'), style: const TextStyle(color: Colors.red)),
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
          Icon(Icons.link_off, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(tr('NoPairsFound', 'هیچ جفت‌نقشی یافت نشد')),
        ],
      ),
    );
  }
}