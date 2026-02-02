extension DateTimeExt on DateTime {
  String toPersianDate() {
    // استفاده از intl یا package jalali
    return DateFormat('yyyy/MM/dd').format(this);  // یا جلالی
  }
}