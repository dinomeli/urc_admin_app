import 'package:flutter/material.dart';
import '../../data/models/notification_send_model.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationSendProvider with ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> send({
    required String title,
    required String body,
    String? token,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final model = NotificationSendModel(
        title: title,
        body: body,
        token: token?.isNotEmpty == true ? token : null,
      );

      await _repo.sendNotification(model);
      _successMessage = 'اعلان با موفقیت ارسال شد';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}