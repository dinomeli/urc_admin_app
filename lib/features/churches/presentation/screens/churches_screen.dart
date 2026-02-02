import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/models/church.dart';
import '../providers/church_provider.dart';
import '../widgets/church_card.dart';
import '../widgets/church_form_bottomsheet.dart';
import '../../../../core/providers/locale_provider.dart';

class ChurchesScreen extends StatefulWidget {
  const ChurchesScreen({super.key});

  @override
  State<ChurchesScreen> createState() => _ChurchesScreenState();
}

class _ChurchesScreenState extends State<ChurchesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChurchProvider>(context, listen: false).fetchChurches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = Provider.of<LocaleProvider>(context).translate;
    const Color primaryColor = Color(0xFF00ADB5);

    return Scaffold(
      backgroundColor: Colors.grey[100], // پس‌زمینه متمایز از کارت‌ها
      appBar: AppBar(
        title: Text(
          tr('Church Management', 'مدیریت کلیساها'),
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            onPressed: () => Provider.of<ChurchProvider>(context, listen: false).fetchChurches(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context),
        backgroundColor: primaryColor,
        elevation: 6,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: Text(tr('Add', 'افزودن'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Consumer<ChurchProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            );
          }

          if (provider.error != null) {
            return _buildErrorState(provider, tr, primaryColor);
          }

          if (provider.churches.isEmpty) {
            return _buildEmptyState(tr, primaryColor);
          }

          return RefreshIndicator(
            color: primaryColor,
            onRefresh: provider.fetchChurches,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 85), // فضای کافی برای FAB
              itemCount: provider.churches.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final church = provider.churches[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ChurchCard(
                    church: church,
                    onEdit: () => _showForm(context, church: church),
                    onDelete: () => _confirmDelete(context, church.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // --- ویجت‌های کمکی برای مدیریت وضعیت‌های مختلف ---

  Widget _buildEmptyState(Function tr, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.church_outlined, size: 100, color: color.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text(
            tr('No churches found', 'هیچ کلیسایی یافت نشد'),
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            tr('Start by adding a new location', 'با افزودن یک لوکیشن جدید شروع کنید'),
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ChurchProvider provider, Function tr, Color color) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              tr('Error: ', 'خطا: ') + provider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: provider.fetchChurches,
              icon: const Icon(Icons.refresh),
              label: Text(tr('Try Again', 'تلاش مجدد')),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForm(BuildContext context, {Church? church}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // برای ایجاد افکت شیشه‌ای یا گوشه گرد تمیز
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ChurchFormBottomSheet(church: church),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    final tr = Provider.of<LocaleProvider>(context, listen: false).translate;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 10),
            Text(tr('Delete Church', 'حذف کلیسا')),
          ],
        ),
        content: Text(tr('Are you sure you want to delete this church?', 'آیا مطمئن هستید که می‌خواهید این کلیسا را حذف کنید؟')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(tr('Cancel', 'انصراف'), style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await Provider.of<ChurchProvider>(context, listen: false).deleteChurch(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(tr('Church deleted successfully', 'کلیسا با موفقیت حذف شد')),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr('Delete error: ', 'خطا در حذف: ') + e.toString()), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text(tr('Delete', 'حذف')),
          ),
        ],
      ),
    );
  }
}