import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../core/alert_thresholds.dart';
import '../core/format.dart';
import '../core/stats.dart';
import '../core/territory.dart';
import '../core/trend.dart';
import '../models/nexo_alert.dart';
import '../models/occurrence.dart';
import '../models/series.dart';
import '../models/water_reading.dart';
import '../models/weather_day.dart';

/// Gera alertas a partir de regras e tendências simples. Nunca executa ações:
/// só produz indícios com evidência, confiança e limitações.
class AlertEngine {
  static const _maxConfidence = 0.95;

  static List<NexoAlert> generate({
    required List<WaterReading> water,
    required List<WeatherDay> weather,
    required List<Occurrence> occurrences,
    required AlertThresholds thresholds,
    DateTime? now,
  }) {
    final today = _dateOnly(now ?? DateTime.now());
    final alerts = [
      ..._waterAlerts(water, occurrences, thresholds, today),
      ..._heatAlerts(weather, thresholds, today),
      ..._rainAlerts(weather, occurrences, thresholds, today),
      ..._clusterAlerts(occurrences, thresholds, today),
    ];
    alerts.sort((a, b) {
      final bySeverity = b.severity.index.compareTo(a.severity.index);
      return bySeverity != 0 ? bySeverity : b.confidence.compareTo(a.confidence);
    });
    return alerts;
  }

  // ---------- Consumo de água ----------

  static List<NexoAlert> _waterAlerts(
    List<WaterReading> water,
    List<Occurrence> occurrences,
    AlertThresholds th,
    DateTime today,
  ) {
    final result = <NexoAlert>[];
    for (final sector in Territory.sectors) {
      final rows = water.where((r) => r.sector == sector).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      if (rows.length < 21) continue; // dados insuficientes: não arrisca um alerta

      final values = rows.map((r) => r.liters).toList();
      final n = values.length;
      final trend = computeTrend(values);
      if (trend.percent < th.waterTrendPercent) continue;

      final last7 = values.sublist(n - 7);
      final baseline = average(values.sublist(n - 14, n - 7));
      final avgLast7 = average(last7);
      final excess = last7.fold<double>(0, (s, v) => s + math.max(0.0, v - baseline));
      final above = last7.where((v) => v > baseline).length;
      final r2 = rSquared(values.sublist(n - 14));
      final sufficiency = math.min(n / 30, 1.0);
      final leaks = occurrences
          .where((o) => o.sector == sector && o.category == 'Vazamento' && o.resolvedAt == null)
          .length;
      final bonus = math.min(leaks * 0.05, 0.10);
      final confidence =
          (0.2 * sufficiency + 0.4 * (above / 7) + 0.4 * r2 + bonus).clamp(0.1, _maxConfidence).toDouble();

      final breakdown = StringBuffer()
        ..writeln('Confiança = 20% quantidade de dados + 40% consistência + 40% ajuste linear (+ bônus), no máximo 95%.')
        ..write('Dados: ${(sufficiency * 100).round()}% ($n dias) · '
            'Consistência: $above de 7 dias acima da média anterior · '
            'Ajuste linear (R²): ${_dec(r2, 2)}');
      if (bonus > 0) {
        breakdown.write(' · Vazamentos abertos no setor: +${(bonus * 100).round()} pontos');
      }

      result.add(NexoAlert(
        id: 'water:$sector:${_stamp(today)}',
        kind: AlertKind.waterTrend,
        severity: trend.percent >= th.waterTrendPercent * 2 ? AlertSeverity.high : AlertSeverity.medium,
        title: 'Alta no consumo de água · setor $sector',
        summary: 'Consumo ${formatPercent(trend.percent)} em 7 dias: possível vazamento ou desperdício.',
        confidence: confidence,
        confidenceBreakdown: breakdown.toString(),
        evidence: [
          'Média dos últimos 7 dias: ${formatFull(avgLast7)} L/dia, ${formatPercent(trend.percent)} '
              'sobre os 7 dias anteriores (${formatFull(baseline)} L/dia).',
          'Limiar configurado: alerta quando a alta passa de ${_dec(th.waterTrendPercent, 0)}%.',
          'Consumo acima da média anterior em $above de 7 dias.',
          'Excesso estimado na semana: cerca de ${formatFull(excess)} L.',
          if (leaks > 0) '$leaks ocorrência(s) de vazamento aberta(s) neste setor corroboram o indício.',
        ],
        limitations: const [
          'Dados sintéticos de demonstração. Em produção, dependem da qualidade da telemetria dos hidrômetros.',
          'A tendência compara só duas semanas: feriados, eventos e calor também elevam o consumo sem haver vazamento.',
          'O alerta não indica o ponto exato do vazamento.',
        ],
        recommendation:
            'Programar uma inspeção em campo no setor $sector antes de qualquer manobra na rede. A decisão de agir é do gestor.',
        sector: sector,
        litersAtRisk: excess,
        series: Series(
          title: 'Consumo de água (setor $sector)',
          unit: 'L/dia',
          description: 'Consumo diário do setor $sector. A tendência compara a média dos últimos 7 dias com a dos 7 anteriores.',
          source: 'Dados sintéticos gerados para este projeto (simulam uma API da companhia de água).',
          dates: rows.map((r) => r.date).toList(),
          values: values,
        ),
      ));
    }
    return result;
  }

  // ---------- Calor ----------

  static List<NexoAlert> _heatAlerts(List<WeatherDay> weather, AlertThresholds th, DateTime today) {
    final forecast = _forecast(weather, today);
    final hot = forecast.where((d) => d.tempMax >= th.heatTempC).toList();
    if (hot.isEmpty) return [];

    final maxTemp = hot.map((d) => d.tempMax).reduce(math.max);
    final daysAhead = _dateOnly(hot.first.date).difference(today).inDays;
    final severity = maxTemp >= th.heatTempC + 4
        ? AlertSeverity.high
        : (hot.length == 1 && maxTemp < th.heatTempC + 2 ? AlertSeverity.low : AlertSeverity.medium);
    final lead = (0.9 - 0.07 * daysAhead).clamp(0.3, 0.9).toDouble();
    final confidence = (lead * 0.85).clamp(0.2, _maxConfidence).toDouble();

    return [
      NexoAlert(
        id: 'heat:${_stamp(today)}',
        kind: AlertKind.heat,
        severity: severity,
        title: 'Calor intenso previsto',
        summary: 'Máxima de ${maxTemp.toStringAsFixed(0)} °C prevista em ${_d(hot.first.date)}: a demanda por água pode subir.',
        confidence: confidence,
        confidenceBreakdown: 'Confiança = qualidade da previsão pela antecedência (${(lead * 100).round()}%) '
            'com desconto de 15% porque a ligação entre calor e consumo é uma suposição da regra.\n'
            'Primeiro dia crítico: daqui a $daysAhead dia(s).',
        evidence: [
          'Máxima prevista de ${maxTemp.toStringAsFixed(0)} °C.',
          '${hot.length} dia(s) com máxima de ${th.heatTempC.toStringAsFixed(0)} °C ou mais: ${hot.map((d) => _d(d.date)).join(', ')}.',
          'Limiar configurado: ${th.heatTempC.toStringAsFixed(0)} °C.',
        ],
        limitations: [
          'Previsões perdem precisão com a antecedência. O primeiro dia crítico está a $daysAhead dia(s).',
          'A previsão vem de uma grade regional (Open-Meteo). O microclima do bairro pode diferir.',
          'A relação entre calor e consumo é uma suposição da regra, ainda não validada com os dados deste bairro.',
        ],
        recommendation:
            'Avaliar reforço do monitoramento do abastecimento e orientar a população sobre o uso consciente da água. A decisão é do gestor.',
        series: Series(
          title: 'Temperatura máxima diária',
          unit: '°C',
          description: 'Temperatura máxima dos últimos 30 dias, seguida da previsão para os próximos 7.',
          source: 'Open-Meteo (API pública). Sem internet, o app usa a última resposta salva.',
          dates: weather.map((d) => d.date).toList(),
          values: weather.map((d) => d.tempMax).toList(),
        ),
      ),
    ];
  }

  // ---------- Chuva ----------

  static List<NexoAlert> _rainAlerts(
    List<WeatherDay> weather,
    List<Occurrence> occurrences,
    AlertThresholds th,
    DateTime today,
  ) {
    final forecast = _forecast(weather, today);
    final wet = forecast.where((d) => d.precipitation >= th.rainDailyMm).toList();
    if (wet.isEmpty) return [];

    final maxRain = wet.map((d) => d.precipitation).reduce(math.max);
    final daysAhead = _dateOnly(wet.first.date).difference(today).inDays;
    final confidence = (0.8 - 0.09 * daysAhead).clamp(0.2, 0.8).toDouble();
    final floods = occurrences.where((o) => o.category == 'Alagamento').length;

    return [
      NexoAlert(
        id: 'rain:${_stamp(today)}',
        kind: AlertKind.rain,
        severity: maxRain >= th.rainDailyMm * 2 ? AlertSeverity.high : AlertSeverity.medium,
        title: 'Chuva forte prevista',
        summary: '${maxRain.toStringAsFixed(0)} mm previstos em ${_d(wet.first.date)}: risco de alagamentos.',
        confidence: confidence,
        confidenceBreakdown:
            'Confiança = 80% de base para previsão de chuva, menos 9 pontos por dia de antecedência ($daysAhead dia(s)). '
            'Chuva é a variável mais incerta da previsão.',
        evidence: [
          'Chuva prevista de ${maxRain.toStringAsFixed(0)} mm (limiar: ${th.rainDailyMm.toStringAsFixed(0)} mm/dia).',
          '${wet.length} dia(s) acima do limiar: ${wet.map((d) => _d(d.date)).join(', ')}.',
          if (floods > 0) '$floods ocorrência(s) de alagamento já registrada(s) no território.',
        ],
        limitations: const [
          'Volume, horário e local da chuva podem mudar bastante até a data prevista.',
          'O alerta usa o total diário. Alagamentos dependem da intensidade por hora.',
          'Não considera o estado atual da drenagem do bairro.',
        ],
        recommendation:
            'Verificar os pontos críticos de drenagem e deixar a equipe de resposta de prontidão. O acionamento é decisão do gestor.',
      ),
    ];
  }

  // ---------- Concentração de ocorrências ----------

  static List<NexoAlert> _clusterAlerts(List<Occurrence> occurrences, AlertThresholds th, DateTime today) {
    final result = <NexoAlert>[];
    for (final sector in Territory.sectors) {
      final open = occurrences.where((o) => o.sector == sector && o.resolvedAt == null).toList();
      if (open.length < th.openOccurrences) continue;

      final counts = <String, int>{};
      for (final o in open) {
        counts[o.category] = (counts[o.category] ?? 0) + 1;
      }
      final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
      final share = top.value / open.length;
      final confidence =
          ((0.25 + 0.15 * open.length) * (0.6 + 0.4 * share)).clamp(0.2, 0.8).toDouble();
      final oldest = open.map((o) => o.createdAt).reduce((a, b) => a.isBefore(b) ? a : b);
      final oldestDays = today.difference(_dateOnly(oldest)).inDays;

      result.add(NexoAlert(
        id: 'cluster:$sector:${_stamp(today)}',
        kind: AlertKind.occurrenceCluster,
        severity: open.length > th.openOccurrences ? AlertSeverity.high : AlertSeverity.medium,
        title: 'Ocorrências concentradas · setor $sector',
        summary: '${open.length} ocorrências abertas, a maioria de ${top.key.toLowerCase()}.',
        confidence: confidence,
        confidenceBreakdown:
            'Confiança = (25% + 15% por ocorrência aberta) ajustada pela categoria dominante (${(share * 100).round()}%), no máximo 80%. '
            'Amostras pequenas têm confiança limitada.',
        evidence: [
          '${open.length} ocorrências abertas no setor $sector (limiar: ${th.openOccurrences}).',
          'Categoria predominante: ${top.key} (${top.value} de ${open.length}).',
          'A ocorrência aberta mais antiga tem $oldestDays dia(s).',
        ],
        limitations: const [
          'Amostra pequena: poucas ocorrências bastam para disparar o alerta.',
          'Relatos dependem de quem usa o app. Áreas com menos acesso à tecnologia podem estar sub-representadas (viés de notificação).',
          'Várias pessoas reportando o mesmo problema não são agrupadas automaticamente.',
        ],
        recommendation: 'Priorizar a vistoria das ocorrências do setor $sector. A ordem de atendimento é decisão do gestor.',
        sector: sector,
      ));
    }
    return result;
  }

  // ---------- Utilitários ----------

  static List<WeatherDay> _forecast(List<WeatherDay> weather, DateTime today) {
    final end = today.add(const Duration(days: 7));
    return weather.where((d) {
      final day = _dateOnly(d.date);
      return !day.isBefore(today) && day.isBefore(end);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  static String _stamp(DateTime d) => DateFormat('yyyyMMdd').format(d);
  static String _d(DateTime d) => DateFormat('dd/MM').format(d);
  static String _dec(double v, int digits) => v.toStringAsFixed(digits).replaceAll('.', ',');
}