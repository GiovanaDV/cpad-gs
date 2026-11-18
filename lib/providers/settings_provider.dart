import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/alert_thresholds.dart';

class SettingsProvider extends ChangeNotifier {
  static const _key = 'alert_thresholds_v1';

  AlertThresholds thresholds = const AlertThresholds();

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      thresholds = AlertThresholds.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      notifyListeners();
    } catch (_) {
      // Configuração corrompida: mantém os limiares padrão.
    }
  }

  Future<void> saveThresholds(AlertThresholds value) async {
    thresholds = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(value.toJson()));
  }
}