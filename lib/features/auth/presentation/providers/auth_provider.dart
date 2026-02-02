import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  TextDirection get textDirection =>
      _locale.languageCode == 'fa' ? TextDirection.rtl : TextDirection.ltr;

  void setLocale(Locale locale) {
    if (!['en', 'fa'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
  }

  // متد کمکی برای گرفتن متن دو زبانه
  String translate(String en, String fa) {
    return _locale.languageCode == 'fa' ? fa : en;
  }
}