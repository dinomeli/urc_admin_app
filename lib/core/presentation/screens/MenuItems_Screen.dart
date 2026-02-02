import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../../providers/locale_provider.dart';
import '../../data/models/menu_item_dto.dart';

class MenuItemsScreen extends StatelessWidget {
  const MenuItemsScreen({super.key});

  // تابع کمکی برای تبدیل کد رنگ هگز به شیء Color
  Color _parseColor(String hex) {
    try {
      String formattedHex = hex.replaceAll('#', '');
      if (formattedHex.length == 6) formattedHex = 'FF$formattedHex';
      return Color(int.parse('0x$formattedHex'));
    } catch (e) {
      return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MenuProvider>(context);
    final locale = Provider.of<LocaleProvider>(context);
    
    final tr = locale.translate;
    final bool isFa = locale.locale.languageCode == 'fa';

    // اصلاح مشکل لوپ لودینگ با استفاده از isFirstLoad
    if (provider.menus.isEmpty && !provider.isLoading && provider.error == null && provider.isFirstLoad) {
      Future.microtask(() => provider.fetchMenus());
    }

    return Directionality(
      textDirection: isFa ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('Menu Management', 'مدیریت منوها')),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => provider.fetchMenus(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showEditDialog(context, null, tr, isFa),
          label: Text(tr('Add Menu', 'منو جدید')),
          icon: const Icon(Icons.add),
        ),
        body: _buildBody(provider, tr),
      ),
    );
  }

  Widget _buildBody(MenuProvider provider, Function tr) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(provider.error!),
            ElevatedButton(
              onPressed: provider.fetchMenus,
              child: Text(tr('Retry', 'تلاش مجدد')),
            ),
          ],
        ),
      );
    }

    if (provider.menus.isEmpty) {
      return Center(child: Text(tr('No items found', 'رکوردی یافت نشد')));
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchMenus(),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: provider.menus.length,
        itemBuilder: (context, index) {
          final menu = provider.menus[index];
          final bool isFa = Provider.of<LocaleProvider>(context, listen: false).locale.languageCode == 'fa';
          
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _parseColor(menu.color).withOpacity(0.1),
                child: Icon(Icons.link, color: _parseColor(menu.color)),
              ),
              title: Text(isFa ? menu.titleFa : menu.titleEn, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Key: ${menu.key} | Order: ${menu.order}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditDialog(context, menu, tr, isFa),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(context, provider, menu.id, tr),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // دیالوگ ایجاد و ویرایش
  void _showEditDialog(BuildContext context, MenuItemDto? menu, Function tr, bool isFa) {
    final keyCtrl = TextEditingController(text: menu?.key);
    final titleEnCtrl = TextEditingController(text: menu?.titleEn);
    final titleFaCtrl = TextEditingController(text: menu?.titleFa);
    final urlCtrl = TextEditingController(text: menu?.url);
    final colorCtrl = TextEditingController(text: menu?.color ?? "#2196F3");
    final orderCtrl = TextEditingController(text: menu?.order.toString() ?? "0");

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(menu == null ? tr('Add Menu', 'افزودن منو') : tr('Edit Menu', 'ویرایش منو')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(keyCtrl, tr('Key', 'کلید یکتا')),
                _buildTextField(titleEnCtrl, tr('Title (EN)', 'عنوان انگلیسی')),
                _buildTextField(titleFaCtrl, tr('Title (FA)', 'عنوان فارسی')),
                _buildTextField(urlCtrl, tr('URL/Path', 'آدرس یا مسیر')),
                
                const SizedBox(height: 10),
                // بخش انتخاب رنگ با پالت
                InkWell(
                  onTap: () => _openColorPicker(context, colorCtrl, tr, () {
                    setDialogState(() {}); // بروزرسانی پیش‌نمایش رنگ در دیالوگ
                  }),
                  child: AbsorbPointer(
                    child: _buildTextField(
                      colorCtrl, 
                      tr('Color', 'انتخاب رنگ'),
                      suffixIcon: Icon(Icons.circle, color: _parseColor(colorCtrl.text)),
                    ),
                  ),
                ),
                
                _buildTextField(orderCtrl, tr('Order', 'ترتیب نمایش'), isNumber: true),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('Cancel', 'انصراف'))),
            ElevatedButton(
              onPressed: () async {
                final provider = Provider.of<MenuProvider>(context, listen: false);
                final dto = MenuItemDto(
                  id: menu?.id ?? 0,
                  key: keyCtrl.text,
                  titleEn: titleEnCtrl.text,
                  titleFa: titleFaCtrl.text,
                  url: urlCtrl.text,
                  icon: "language",
                  color: colorCtrl.text,
                  order: int.tryParse(orderCtrl.text) ?? 0,
                );

                bool success = menu == null 
                  ? await provider.createMenu(dto) 
                  : await provider.updateMenu(menu.id, dto);

                if (success && context.mounted) Navigator.pop(context);
              },
              child: Text(tr('Save', 'ذخیره')),
            ),
          ],
        ),
      ),
    );
  }

  // ویجت کمکی برای فیلد متنی
  Widget _buildTextField(TextEditingController ctrl, String label, {bool isNumber = false, Widget? suffixIcon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  // پالت انتخاب رنگ (فقط یک بار تعریف شده)
  void _openColorPicker(BuildContext context, TextEditingController colorCtrl, Function tr, VoidCallback onSelect) {
    final List<Color> palette = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, 
      Colors.purple, Colors.teal, Colors.pink, Colors.amber,
      Colors.black, Colors.brown, Colors.indigo, Colors.cyan,
      const Color(0xFF4CAF50), const Color(0xFF607D8B),
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('Select Color', 'انتخاب رنگ')),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: palette.map((color) {
            return GestureDetector(
              onTap: () {
                colorCtrl.text = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                onSelect();
                Navigator.pop(ctx);
              },
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, MenuProvider provider, int id, Function tr) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('Delete', 'حذف')),
        content: Text(tr('Delete this menu?', 'آیا این منو حذف شود؟')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('No', 'خیر'))),
          TextButton(
            onPressed: () async {
              await provider.deleteMenu(id);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(tr('Yes', 'بله'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}