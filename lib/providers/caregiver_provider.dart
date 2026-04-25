import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaregiverProvider extends ChangeNotifier {
  bool _enabled = false;
  String _name = '';
  static const _enabledKey = 'caregiver_enabled';
  static const _nameKey = 'caregiver_name';

  bool get enabled => _enabled;
  String get name => _name;

  CaregiverProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledKey) ?? false;
    _name = prefs.getString(_nameKey) ?? '';
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
    notifyListeners();
  }

  Future<void> setName(String name) async {
    _name = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    notifyListeners();
  }
}
