import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  TextDirection get textDirection => _locale.languageCode == 'fa' ? TextDirection.rtl : TextDirection.ltr;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('app_locale') ?? 'en';
    _locale = Locale(langCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'fa'].contains(locale.languageCode)) return;

    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', locale.languageCode);
    notifyListeners(); // این خط باعث می‌شه همه جا rebuild بشه
  }

  String translate(String en, String fa) {
    // این خط رو درست کردیم:
    return _locale.languageCode == 'fa' ? fa : en;
  }
}