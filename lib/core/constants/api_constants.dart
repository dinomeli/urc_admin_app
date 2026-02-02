class ApiConstants {
  // برای محیط توسعه (محلی)
  // static const String baseUrl = 'http://localhost:7086';
  // برای emulator اندروید: 'http://10.0.2.2:7086';
  // برای دستگاه واقعی: 'http://192.168.1.xxx:7086';

  // محیط فعلی (production یا somee.com)
  static const String baseUrl = 'http://urc.somee.com';

  // اگر بعداً HTTPS فعال کردی:
  // static const String baseUrl = 'https://urc.somee.com';

  // ────────────────────────────────────────────────
  // Auth endpoints
  // ────────────────────────────────────────────────
  static const String login = '$baseUrl/api/auth/login';
  static const String register = '$baseUrl/api/auth/register';
  static const String refreshToken = '$baseUrl/api/auth/refresh';
  static const String logout = '$baseUrl/api/auth/logout';

  // ────────────────────────────────────────────────
  // Church Schedules
  // ────────────────────────────────────────────────
  static const String churchSchedules = '$baseUrl/api/ChurchSchedules';
  static const String generateSchedules = '$churchSchedules/generate';
  static const String scheduleById = '$churchSchedules/{id}'; // برای get/put/delete
  static const String assignment = '$churchSchedules/assignment';
  static const String assignmentById = '$churchSchedules/assignment/{id}';
  static const String weeklyPlan = '$churchSchedules/weekly-plan/{id}';
  static const String exportPdf = '$churchSchedules/{id}/pdf';
  static const String exportExcel = '$churchSchedules/export-excel';

  // ────────────────────────────────────────────────
  // اگر بعداً بخش‌های دیگه اضافه شد (مثلاً Users, Roles, Settings)
  // ────────────────────────────────────────────────
  // static const String users = '$baseUrl/api/admin/users';
  // static const String roles = '$baseUrl/api/roles';
}