import 'package:dio/dio.dart';
import '../../../../core/networking/dio_client.dart';
import '../models/notification_send_model.dart';

class NotificationRepository {
  Future<void> sendNotification(NotificationSendModel model) async {
    try {
      final response = await DioClient.instance.post(
        '/api/notification/send',
        data: model.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('خطا در ارسال اعلان: ${response.statusMessage}');
      }

      // اگر سرور پیام موفقیت برگردوند، می‌تونی اینجا چک کنی
      print('ارسال موفق: ${response.data}');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? e.message ?? 'خطا در ارتباط با سرور',
      );
    }
  }
}