import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/locale_provider.dart';
import '../../../churches/presentation/providers/church_provider.dart';
import '../providers/church_settings_provider.dart';
import '../../data/models/church_service_setting.dart';

class ChurchSettingsFormScreen extends StatefulWidget {
  final ChurchServiceSetting? setting;

  const ChurchSettingsFormScreen({super.key, this.setting});

  @override
  State<ChurchSettingsFormScreen> createState() => _ChurchSettingsFormScreenState();
}

class _ChurchSettingsFormScreenState extends State<ChurchSettingsFormScreen> {
  final _formKey = GlobalKey<FormState>();

  int _churchId = 0;
  String _programType = '';
  DateTime? _serviceDate;
  TimeOfDay? _serviceTime;
  bool _isActive = true;

  final Color primaryColor = const Color(0xFF00ADB5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final churchProvider = Provider.of<ChurchProvider>(context, listen: false);
      if (churchProvider.churches.isEmpty) {
        churchProvider.fetchChurches();
      }

      if (widget.setting != null) {
        setState(() {
          _churchId = widget.setting!.churchId ?? 0;
          _programType = widget.setting!.programType ?? '';
          _serviceDate = widget.setting!.serviceDate;
          _serviceTime = widget.setting!.serviceStartTime;
          _isActive = widget.setting!.isActive;
        });
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _churchId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a church')),
      );
      return;
    }

    final tr = Provider.of<LocaleProvider>(context, listen: false).translate;
    final provider = Provider.of<ChurchSettingsProvider>(context, listen: false);

    try {
      if (widget.setting == null) {
        await provider.create(
          churchId: _churchId,
          programType: _programType,
          serviceDate: _serviceDate,
          serviceTime: _serviceTime,
          isActive: _isActive,
        );
      } else {
        await provider.update(
          widget.setting!.id!,
          churchId: _churchId,
          programType: _programType,
          serviceDate: _serviceDate,
          serviceTime: _serviceTime,
          isActive: _isActive,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('Saved successfully', 'با موفقیت ذخیره شد')), behavior: SnackBarBehavior.floating),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('Error: ', 'خطا: ') + e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Provider.of<LocaleProvider>(context).translate;
    final churchProvider = Provider.of<ChurchProvider>(context);
    final settingsProvider = Provider.of<ChurchSettingsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.setting == null ? tr('Create Setting', 'ایجاد تنظیم') : tr('Edit Setting', 'ویرایش تنظیم')),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(tr('Church Details', 'جزئیات کلیسا'), Icons.church_outlined),
                      const SizedBox(height: 20),

                      // Dropdown کلیسا
                      DropdownButtonFormField<int>(
                        value: _churchId == 0 ? null : _churchId,
                        decoration: _buildInputDecoration(tr('Select Church', 'انتخاب کلیسا'), Icons.location_on_outlined),
                        items: churchProvider.churches.map((church) {
                          return DropdownMenuItem<int>(
                            value: church.id,
                            child: Text(church.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _churchId = value);
                        },
                        validator: (v) => v == null || v == 0 ? tr('Required', 'الزامی است') : null,
                      ),
                      const SizedBox(height: 20),

                      // نوع برنامه
                      TextFormField(
                        initialValue: _programType,
                        decoration: _buildInputDecoration(tr('Program Type', 'نوع برنامه'), Icons.event_note_outlined),
                        onChanged: (value) => _programType = value,
                        validator: (v) => v!.isEmpty ? tr('Required', 'الزامی است') : null,
                      ),

                      const Divider(height: 40, thickness: 1),
                      _buildHeader(tr('Schedule & Status', 'زمان‌بندی و وضعیت'), Icons.calendar_today_outlined),
                      const SizedBox(height: 20),

                      // تاریخ و ساعت در یک ردیف
                      Row(
                        children: [
                          Expanded(
                            child: _buildPickerBox(
                              label: tr('Date', 'تاریخ'),
                              value: _serviceDate == null ? tr('Select', 'انتخاب') : DateFormat('yyyy/MM/dd').format(_serviceDate!),
                              icon: Icons.calendar_month,
                              onTap: _pickDate,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPickerBox(
                              label: tr('Time', 'ساعت'),
                              value: _serviceTime == null ? '--:--' : _serviceTime!.format(context),
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
                          color: _isActive ? primaryColor.withOpacity(0.05) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: _isActive ? primaryColor.withOpacity(0.2) : Colors.transparent),
                        ),
                        child: SwitchListTile(
                          title: Text(tr('Active Status', 'وضعیت انتشار'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(tr('Visibility in calendar', 'نمایش در تقویم عمومی')),
                          value: _isActive,
                          activeColor: primaryColor,
                          onChanged: (v) => setState(() => _isActive = v),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // دکمه ذخیره با هندلینگ لودینگ
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: settingsProvider.isLoading ? null : _save,
                  icon: settingsProvider.isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save_rounded, color: Colors.white),
                  label: Text(
                    settingsProvider.isLoading ? tr('Processing...', 'در حال پردازش...') : tr('Save Changes', 'ذخیره تغییرات'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    shadowColor: primaryColor.withOpacity(0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ابزارهای کمکی طراحی ---

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: primaryColor, width: 2)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: primaryColor),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
      ],
    );
  }

  Widget _buildPickerBox({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(icon, size: 18, color: primaryColor),
                const SizedBox(width: 8),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _serviceDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _serviceDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _serviceTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => _serviceTime = time);
  }
}