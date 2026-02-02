import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/locale_provider.dart';
import '../providers/notification_send_provider.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _tokenController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<NotificationSendProvider>(context, listen: false);
    final tr = Provider.of<LocaleProvider>(context, listen: false).translate;

    try {
      await provider.send(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        token: _tokenController.text.trim().isNotEmpty ? _tokenController.text.trim() : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.successMessage ?? tr('Sent successfully', 'ارسال موفق')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? tr('Send error', 'خطا در ارسال')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Provider.of<LocaleProvider>(context).translate;
    final provider = Provider.of<NotificationSendProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Send Notification', 'ارسال اعلان')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: tr('Title', 'عنوان'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? tr('Title is required', 'عنوان الزامی است') : null,
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _bodyController,
                decoration: InputDecoration(
                  labelText: tr('Message', 'متن اعلان'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 5,
                validator: (v) => v!.isEmpty ? tr('Message is required', 'متن الزامی است') : null,
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _tokenController,
                decoration: InputDecoration(
                  labelText: tr('Device Token (optional)', 'توکن دستگاه (اختیاری)'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: tr('Leave empty to send to all', 'خالی بگذارید تا به همه ارسال شود'),
                ),
              ),
              const SizedBox(height: 32),

              if (provider.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00ADB5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(tr('Send', 'ارسال'), style: const TextStyle(fontSize: 18)),
                  ),
                ),

              const SizedBox(height: 16),

              if (provider.successMessage != null)
                Text(
                  provider.successMessage!,
                  style: const TextStyle(color: Colors.green, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              if (provider.errorMessage != null)
                Text(
                  provider.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}