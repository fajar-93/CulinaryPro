import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  static const String _languagePrefKey = 'language_pref';
  
  // Default to id (Indonesia)
  String _languageCode = 'id'; 
  String get languageCode => _languageCode;

  LanguageProvider() {
    _loadFromPrefs();
  }

  void setLanguage(String code) {
    _languageCode = code;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _languageCode = prefs.getString(_languagePrefKey) ?? 'id';
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languagePrefKey, _languageCode);
  }
}
