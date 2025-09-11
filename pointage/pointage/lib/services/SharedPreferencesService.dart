// ignore_for_file: file_names

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  Future<String?> getValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> saveValue(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  Future<bool?> getBoolValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  Future<void> saveBoolValue(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  Future<void> removeValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}
