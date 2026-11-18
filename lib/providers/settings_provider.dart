import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/alert_thresholds.dart';

class SettingsProvider extends ChangeNotifier {
  static const _thresholdsKey = 'alert_thresholds_v1';
  static const _consentKey = 'consent_v1';

  AlertThresholds thresholds = const AlertThresholds();
  bool consentAnswered = false;
  bool consentAccepted = false;
  DateTime? consentAt;

  Future<void>? _loading;

  /// Idempotente: pode ser chamado várias vezes (a splash espera por ele).
  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      try {
        final raw = prefs.getString(_thresholdsKey);
        if (raw != null) thresholds = AlertThresholds.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        // Limiares corrompidos: mantém os padrões.
      }
      try {
        final raw = prefs.getString(_consentKey);
        if (raw != null) {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          consentAnswered = true;
          consentAccepted = map['accepted'] as bool;
          consentAt = DateTime.tryParse(map['at'] as String? ?? '');
        }
      } catch (_) {
        // Consentimento ilegível: será pedido de novo.
      }
    } catch (_) {
      // Sem acesso ao armazenamento: segue com os padrões.
    }
    notifyListeners();
  }

  Future<void> setConsent(bool accepted) async {
    consentAnswered = true;
    consentAccepted = accepted;
    consentAt = DateTime.now();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_consentKey, jsonEncode({'accepted': accepted, 'at': consentAt!.toIso8601String()}));
  }

  Future<void> saveThresholds(AlertThresholds value) async {
    thresholds = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_thresholdsKey, jsonEncode(value.toJson()));
  }

  Future<void> resetThresholds() async {
    thresholds = const AlertThresholds();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_thresholdsKey);
  }
}