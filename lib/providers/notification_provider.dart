import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider with ChangeNotifier {
  static const String _notifPrefKey = 'notification_pref';
  
  bool _isNotificationEnabled = true;
  bool get isNotificationEnabled => _isNotificationEnabled;

  NotificationProvider() {
    _loadFromPrefs();
  }

  void toggleNotification(bool value) {
    _isNotificationEnabled = value;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isNotificationEnabled = prefs.getBool(_notifPrefKey) ?? true;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifPrefKey, _isNotificationEnabled);
  }
}
