import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/locale_provider.dart';
import '../../../churches/presentation/providers/church_provider.dart';
import '../providers/church_settings_provider.dart';

class ChurchSettingsScreen extends StatefulWidget {
  const ChurchSettingsScreen({super.key});

  @override
  State<ChurchSettingsScreen> createState() => _ChurchSettingsScreenState();
}

class _ChurchSettingsScreenState extends State<ChurchSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedChurchId;
  String _programType = '';
  DateTime? _serviceDate;
  TimeOfDay? _serviceTime;
  bool _isActive = true;

  final Color primaryColor = const Color(0xFF00ADB5);

  @override
  Widget build(BuildContext context) {
    final tr = Provider.of<LocaleProvider>(context).translate;
    final churchProvider = Provider.of<ChurchProvider>(context);
    final settingsProvider = Provider.of<ChurchSettingsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50], // پس‌زمینه روشن برای حس تمیزی
      appBar: AppBar(
        title: Text(tr('Create Church Setting', 'ایجاد تنظیمات کلیسا')),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // کارت اصلی فرم
              Card(
                elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(tr('General Information', 'اطلاعات عمومی')),
                      const SizedBox(height: 20),

                      // انتخاب کلیسا
                      DropdownButtonFormField<int>(
                        decoration: _buildInputDecoration(tr('Church', 'کلیسا'), Icons.church),
                        value: _selectedChurchId,
                        items: churchProvider.churches.map((church) {
                          return DropdownMenuItem<int>(
                            value: church.id,
                            child: Text(church.name),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedChurchId = value),
                        validator: (v) => v == null ? tr('Required', 'الزامی است') : null,
                      ),
                      const SizedBox(height: 20),

                      // نوع برنامه
                      TextFormField(
                        decoration: _buildInputDecoration(tr('Program Type', 'نوع برنامه'), Icons.event_note),
                        onChanged: (value) => _programType = value,
                        validator: (v) => v!.isEmpty ? tr('Required', 'الزامی است') : null,
                      ),
                      
                      const Divider(height: 40),
                      _buildSectionTitle(tr('Schedule', 'زمان‌بندی')),
                      const SizedBox(height: 16),

                      // ردیف تاریخ و ساعت
                      Row(
                        children: [
                          Expanded(
                            child: _buildPickerButton(
                              label: tr('Date', 'تاریخ'),
                              value: _serviceDate == null 
                                  ? tr('Select', 'انتخاب') 
                                  : DateFormat('yyyy/MM/dd').format(_serviceDate!),
                              icon: Icons.calendar_month,
                              onTap: _pickDate,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPickerButton(
                              label: tr('Time', 'ساعت'),
                              value: _serviceTime == null 
                                  ? tr('Select', 'انتخاب') 
                                  : _serviceTime!.format(context),
                              icon: Icons.access_time,
                              onTap: _pickTime,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // وضعیت فعال بودن
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SwitchListTile(
                          title: Text(tr('Status', 'وضعیت'), style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(_isActive ? tr('Active', 'فعال') : tr('Inactive', 'غیرفعال')),
                          value: _isActive,
                          activeColor: primaryColor,
                          onChanged: (value) => setState(() => _isActive = value),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // دکمه ذخیره
              if (settingsProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.save_rounded, color: Colors.white),
                    label: Text(tr('Save Setting', 'ذخیره تنظیمات'), 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // متدهای کمکی برای زیبایی بیشتر
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 2)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
    );
  }

  Widget _buildPickerButton({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(icon, size: 18, color: primaryColor),
                const SizedBox(width: 8),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // توابع منطقی
  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _serviceDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => _serviceTime = time);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedChurchId != null) {
      try {
        await Provider.of<ChurchSettingsProvider>(context, listen: false).create(
          churchId: _selectedChurchId!,
          programType: _programType,
          serviceDate: _serviceDate,
          serviceTime: _serviceTime,
          isActive: _isActive,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved!'), behavior: SnackBarBehavior.floating),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }
}