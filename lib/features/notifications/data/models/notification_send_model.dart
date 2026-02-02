class NotificationSendModel {
  final String title;
  final String body;
  final String? token; // اگر خالی باشه، به همه ارسال می‌شه

  NotificationSendModel({
    required this.title,
    required this.body,
    this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'token': token ?? '', // اگر null باشه، خالی بفرست
    };
  }
}