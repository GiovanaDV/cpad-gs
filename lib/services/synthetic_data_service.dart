import 'dart:math';
import '../core/territory.dart';
import '../models/occurrence.dart';
import '../models/water_reading.dart';

/// Simula uma API de dados do território (dados sintéticos e determinísticos).
class SyntheticDataService {
  Future<List<WaterReading>> fetchWaterReadings({int days = 60}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final rnd = Random(42);
    final now = DateTime.now();
    final readings = <WaterReading>[];

    for (var d = 0; d < days; d++) {
      final date = DateTime(now.year, now.month, now.day - (days - 1 - d));
      final weekend = date.weekday >= 6;
      for (final sector in Territory.sectors) {
        var liters = 40000.0;
        if (sector == 'Leste') liters *= 1.1;
        if (weekend) liters *= 1.08;
        liters *= 1 + (rnd.nextDouble() - 0.5) * 0.08;
        // Vazamento simulado: consumo do setor Sul sobe nos últimos 12 dias.
        if (sector == 'Sul' && d >= days - 12) {
          liters *= 1 + (d - (days - 12)) * 0.025;
        }
        readings.add(WaterReading(date: date, sector: sector, liters: liters));
      }
    }
    return readings;
  }

  List<Occurrence> sampleOccurrences() {
    final now = DateTime.now();
    Occurrence make(String cat, String sector, String desc, int daysAgo, int? hoursToResolve) {
      final created = now.subtract(Duration(days: daysAgo));
      return Occurrence(
        category: cat,
        sector: sector,
        description: desc,
        createdAt: created,
        resolvedAt: hoursToResolve == null ? null : created.add(Duration(hours: hoursToResolve)),
        source: 'sintético',
      );
    }

    return [
      make('Vazamento', 'Sul', 'Água escorrendo na calçada', 2, null),
      make('Vazamento', 'Sul', 'Cavalete com vazamento', 4, null),
      make('Vazamento', 'Sul', 'Poça constante na rua', 6, 30),
      make('Falta de água', 'Norte', 'Sem água desde a manhã', 9, 8),
      make('Alagamento', 'Leste', 'Rua alagada após chuva', 12, 20),
      make('Vazamento', 'Oeste', 'Tubulação rompida', 15, 12),
    ];
  }
}