import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/locale_provider.dart';
import '../providers/church_settings_provider.dart';
import 'church_settings_form_screen.dart';

class ChurchSettingsListScreen extends StatefulWidget {
  const ChurchSettingsListScreen({super.key});

  @override
  State<ChurchSettingsListScreen> createState() => _ChurchSettingsListScreenState();
}

class _ChurchSettingsListScreenState extends State<ChurchSettingsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChurchSettingsProvider>(context, listen: false).fetchSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final tr = localeProvider.translate;
    final isFarsi = localeProvider.locale.languageCode == 'fa';
    final provider = Provider.of<ChurchSettingsProvider>(context);

    // تم رنگی اصلی اپلیکیشن شما
    const primaryColor = Color(0xFF00ADB5);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(tr('Church Settings', 'تنظیمات کلیساها')),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: provider.fetchSettings,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChurchSettingsFormScreen()),
        ),
        label: Text(tr('Add New', 'افزودن جدید'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: primaryColor,
        elevation: 4,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : provider.settings.isEmpty
              ? _buildEmptyState(tr)
              : RefreshIndicator(
                  color: primaryColor,
                  onRefresh: provider.fetchSettings,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: provider.settings.length,
                    itemBuilder: (context, index) {
                      final setting = provider.settings[index];
                      return _buildSettingCard(context, setting, tr, isFarsi, primaryColor);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(Function tr) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_suggest_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            tr('No settings found', 'هیچ تنظیمی یافت نشد'),
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context, dynamic setting, Function tr, bool isFarsi, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // نوار رنگی کناری برای نمایش وضعیت
              Container(
                width: 6,
                color: setting.isActive ? Colors.green : Colors.grey[400],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              (setting.programType?.isNotEmpty == true)
                                  ? setting.programType!
                                  : tr('Untitled Setting', 'تنظیم بدون عنوان'),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // نمایش وضعیت به صورت Chip
                          _buildStatusChip(setting.isActive, tr),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.church_outlined, tr('Church', 'کلیسا'), setting.churchName ?? tr('Unknown', 'نامشخص')),
                      if (setting.serviceDate != null)
                        _buildInfoRow(Icons.calendar_month_outlined, tr('Date', 'تاریخ'), DateFormat('yyyy/MM/dd').format(setting.serviceDate!)),
                      if (setting.serviceStartTime != null)
                        _buildInfoRow(Icons.access_time_rounded, tr('Time', 'ساعت'), setting.serviceStartTime!.format(context)),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            label: tr('Edit', 'ویرایش'),
                            color: primaryColor,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChurchSettingsFormScreen(setting: setting)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          _buildActionButton(
                            icon: Icons.delete_outline_rounded,
                            label: tr('Delete', 'حذف'),
                            color: Colors.redAccent,
                            onTap: () => _confirmDelete(context, setting.id!),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive, Function tr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive ? tr('Active', 'فعال') : tr('Inactive', 'غیرفعال'),
        style: TextStyle(
          color: isActive ? Colors.green[700] : Colors.grey[700],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text("$label: ", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    final tr = Provider.of<LocaleProvider>(context, listen: false).translate;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(tr('Delete Setting', 'حذف تنظیم')),
        content: Text(tr('Are you sure you want to delete this setting?', 'آیا از حذف این تنظیم مطمئن هستید؟')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(tr('Cancel', 'انصراف'), style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 0),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await Provider.of<ChurchSettingsProvider>(context, listen: false).delete(id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr('Deleted successfully', 'با موفقیت حذف شد')), behavior: SnackBarBehavior.floating),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr('Error: ', 'خطا: ') + e.toString()), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: Text(tr('Delete', 'حذف'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}