import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/load_status.dart';
import '../models/nexo_alert.dart';
import '../services/alert_engine.dart';
import 'occurrences_provider.dart';
import 'settings_provider.dart';
import 'territory_provider.dart';

/// Recalcula os alertas sempre que dados, ocorrências ou limiares mudam
/// e guarda as decisões humanas tomadas sobre eles.
class AlertsProvider extends ChangeNotifier {
  static const _key = 'alert_decisions_v1';

  final TerritoryProvider _territory;
  final OccurrencesProvider _occurrences;
  final SettingsProvider _settings;

  List<NexoAlert> alerts = [];
  Map<String, AlertDecision> _decisions = {};

  AlertsProvider(this._territory, this._occurrences, this._settings) {
    _territory.addListener(_recompute);
    _occurrences.addListener(_recompute);
    _settings.addListener(_recompute);
    _compute();
    _loadDecisions();
  }

  LoadStatus get status {
    if (_territory.status == LoadStatus.error || _occurrences.status == LoadStatus.error) {
      return LoadStatus.error;
    }
    if (_territory.status == LoadStatus.loading || _occurrences.status == LoadStatus.loading) {
      return LoadStatus.loading;
    }
    return LoadStatus.ready;
  }

  String? get errorMessage => _territory.errorMessage ?? _occurrences.errorMessage;

  AlertDecision? decisionFor(NexoAlert alert) => _decisions[alert.id];

  NexoAlert? byId(String id) {
    for (final a in alerts) {
      if (a.id == id) return a;
    }
    return null;
  }

  List<NexoAlert> get pending => alerts.where((a) => !_decisions.containsKey(a.id)).toList();
  List<NexoAlert> get decided => alerts.where((a) => _decisions.containsKey(a.id)).toList();

  /// Indicador de benefício social: litros em risco de desperdício (estimativa semanal).
  double get litersAtRisk => alerts.fold<double>(0, (s, a) => s + (a.litersAtRisk ?? 0));

  Future<void> reload() => Future.wait([_territory.load(), _occurrences.load()]);

  Future<void> decide(NexoAlert alert, DecisionType type, {String note = ''}) async {
    _decisions[alert.id] = AlertDecision(type: type, note: note, decidedAt: DateTime.now());
    notifyListeners();
    await _persist();
  }

  Future<void> reopen(NexoAlert alert) async {
    _decisions.remove(alert.id);
    notifyListeners();
    await _persist();
  }

  Future<void> clearDecisions() async {
    _decisions = {};
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  void _recompute() {
    _compute();
    notifyListeners();
  }

  void _compute() {
    if (_territory.status == LoadStatus.ready && _occurrences.status == LoadStatus.ready) {
      alerts = AlertEngine.generate(
        water: _territory.water,
        weather: _territory.weather,
        occurrences: _occurrences.items,
        thresholds: _settings.thresholds,
      );
    } else {
      alerts = [];
    }
  }

  Future<void> _loadDecisions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _decisions = map.map((k, v) => MapEntry(k, AlertDecision.fromJson(v as Map<String, dynamic>)));
      notifyListeners();
    } catch (_) {
      // Decisões corrompidas são ignoradas.
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_decisions.map((k, v) => MapEntry(k, v.toJson()))));
  }

  @override
  void dispose() {
    _territory.removeListener(_recompute);
    _occurrences.removeListener(_recompute);
    _settings.removeListener(_recompute);
    super.dispose();
  }
}