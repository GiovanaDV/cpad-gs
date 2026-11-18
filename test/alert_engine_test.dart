import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/core/alert_thresholds.dart';
import 'package:nexo/models/nexo_alert.dart';
import 'package:nexo/models/occurrence.dart';
import 'package:nexo/models/weather_day.dart';
import 'package:nexo/services/alert_engine.dart';
import 'package:nexo/services/synthetic_data_service.dart';

void main() {
  final synthetic = SyntheticDataService();
  final now = DateTime(2026, 11, 18, 10);

  test('detecta a tendência de alta de consumo do setor Sul', () async {
    final water = await synthetic.fetchWaterReadings();
    final alerts = AlertEngine.generate(
      water: water,
      weather: [],
      occurrences: [],
      thresholds: const AlertThresholds(),
      now: now,
    );
    final waterAlerts = alerts.where((a) => a.kind == AlertKind.waterTrend).toList();
    expect(waterAlerts.map((a) => a.sector), contains('Sul'));
    expect(waterAlerts.map((a) => a.sector), isNot(contains('Norte')));
  });

  test('com limiar muito alto não gera alerta de consumo', () async {
    final water = await synthetic.fetchWaterReadings();
    final alerts = AlertEngine.generate(
      water: water,
      weather: [],
      occurrences: [],
      thresholds: const AlertThresholds(waterTrendPercent: 100),
      now: now,
    );
    expect(alerts.where((a) => a.kind == AlertKind.waterTrend), isEmpty);
  });

  test('gera alerta de calor quando a previsão passa do limiar', () {
    final weather = [
      WeatherDay(date: DateTime(2026, 11, 19), tempMax: 37, precipitation: 0),
      WeatherDay(date: DateTime(2026, 11, 20), tempMax: 29, precipitation: 0),
    ];
    final alerts = AlertEngine.generate(
      water: [],
      weather: weather,
      occurrences: [],
      thresholds: const AlertThresholds(),
      now: now,
    );
    final heat = alerts.where((a) => a.kind == AlertKind.heat).toList();
    expect(heat, hasLength(1));
    expect(heat.first.severity, AlertSeverity.high);
  });

  test('ocorrências abertas concentradas geram alerta com confiança limitada', () {
    Occurrence open(String sector) => Occurrence(
          category: 'Vazamento',
          sector: sector,
          description: 'teste',
          createdAt: DateTime(2026, 11, 15),
          source: 'sintético',
        );
    final alerts = AlertEngine.generate(
      water: [],
      weather: [],
      occurrences: [open('Leste'), open('Leste')],
      thresholds: const AlertThresholds(),
      now: now,
    );
    final cluster = alerts.where((a) => a.kind == AlertKind.occurrenceCluster).toList();
    expect(cluster, hasLength(1));
    expect(cluster.first.confidence, lessThanOrEqualTo(0.8));
  });

  test('sem dados não gera alertas', () {
    final alerts = AlertEngine.generate(
      water: [],
      weather: [],
      occurrences: [],
      thresholds: const AlertThresholds(),
      now: now,
    );
    expect(alerts, isEmpty);
  });

  test('todo alerta traz evidência, limitações e confiança máxima de 95%', () async {
    final water = await synthetic.fetchWaterReadings();
    final alerts = AlertEngine.generate(
      water: water,
      weather: [],
      occurrences: synthetic.sampleOccurrences(),
      thresholds: const AlertThresholds(),
      now: now,
    );
    expect(alerts, isNotEmpty);
    for (final a in alerts) {
      expect(a.evidence, isNotEmpty);
      expect(a.limitations, isNotEmpty);
      expect(a.confidence, lessThanOrEqualTo(0.95));
    }
  });
}