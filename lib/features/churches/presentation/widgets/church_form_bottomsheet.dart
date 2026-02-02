import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/church.dart';
import '../providers/church_provider.dart';
import '../../../../core/providers/locale_provider.dart';

class ChurchFormBottomSheet extends StatefulWidget {
  final Church? church;

  const ChurchFormBottomSheet({super.key, this.church});

  @override
  State<ChurchFormBottomSheet> createState() => _ChurchFormBottomSheetState();
}

class _ChurchFormBottomSheetState extends State<ChurchFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _city;
  late String _address;

  @override
  void initState() {
    super.initState();
    _name = widget.church?.name ?? '';
    _city = widget.church?.city ?? '';
    _address = widget.church?.address ?? '';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final tr = Provider.of<LocaleProvider>(context, listen: false).translate;
    final provider = Provider.of<ChurchProvider>(context, listen: false);

    try {
      if (widget.church == null) {
        final newChurch = Church(id: 0, name: _name, city: _city, address: _address);
        await provider.addChurch(newChurch);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('Church added successfully', 'کلیسا با موفقیت اضافه شد'))),
        );
      } else {
        final updated = Church(id: widget.church!.id, name: _name, city: _city, address: _address);
        await provider.updateChurch(updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('Church updated successfully', 'کلیسا با موفقیت ویرایش شد'))),
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Error: ', 'خطا: ') + e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Provider.of<LocaleProvider>(context).translate;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.church == null ? tr('Add New Church', 'افزودن کلیسای جدید') : tr('Edit Church','ویرایش کلیسا'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            TextFormField(
              initialValue: _name,
              decoration: InputDecoration(
                labelText: tr('Church Name','نام کلیسا'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.church),
              ),
              validator: (v) => v!.isEmpty ? tr('Name is required','نام الزامی است') : null,
              onSaved: (v) => _name = v!,
            ),
            const SizedBox(height: 16),

            TextFormField(
              initialValue: _city,
              decoration: InputDecoration(
                labelText: tr('City','شهر'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.location_city),
              ),
              validator: (v) => v!.isEmpty ? tr('City is required','شهر الزامی است') : null,
              onSaved: (v) => _city = v!,
            ),
            const SizedBox(height: 16),

            TextFormField(
              initialValue: _address,
              decoration: InputDecoration(
                labelText: tr('Full Address', 'آدرس کامل'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.home),
              ),
              validator: (v) => v!.isEmpty ? tr('Address is required', 'آدرس الزامی است') : null,
              onSaved: (v) => _address = v!,
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(tr('Cancel','انصراف')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00ADB5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(widget.church == null ? tr('Add','افزودن') : tr('Save Changes','ذخیره تغییرات' )),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}