import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static const _kUser = 'username';
  static const _kHistory = 'history';

  static Future<String?> getUserName() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kUser);
  }

  static Future<void> setUserName(String name) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kUser, name);
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList(_kHistory) ?? <String>[];
    return list.map((s) => Map<String, dynamic>.from(jsonDecode(s))).toList();
  }

  static Future<void> addHistory(Map<String, dynamic> entry) async {
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList(_kHistory) ?? <String>[];
    list.insert(0, jsonEncode(entry));
    await p.setStringList(_kHistory, list);
  }

  static Future<void> clearHistory() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kHistory);
  }
}