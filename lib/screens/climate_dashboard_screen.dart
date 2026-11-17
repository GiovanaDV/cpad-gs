import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart';
import '../core/format.dart';
import '../core/trend.dart';
import '../models/series.dart';
import '../providers/territory_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/info_banner.dart';
import '../widgets/simple_bar_chart.dart';
import '../widgets/state_view.dart';
import '../widgets/stat_card.dart';
import '../widgets/status_gate.dart';
import '../widgets/trend_line_chart.dart';

class ClimateDashboardScreen extends StatelessWidget {
  const ClimateDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<TerritoryProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Clima local')),
      body: StatusGate(
        status: t.status,
        error: t.errorMessage,
        onRetry: t.load,
        builder: (_) => _content(context, t),
      ),
    );
  }

  Widget _content(BuildContext context, TerritoryProvider t) {
    if (t.weather.isEmpty) return StateView.empty('Sem dados de clima disponíveis.');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final past = t.weather.where((d) => d.date.isBefore(today)).toList();
    final forecast = t.weather.where((d) => !d.date.isBefore(today)).toList();

    final pastTemps = past.map((d) => d.tempMax).toList();
    final trend = computeTrend(pastTemps);
    final avgTemp7 = pastTemps.length >= 7 ? average(pastTemps.sublist(pastTemps.length - 7)) : average(pastTemps);
    final maxForecast = forecast.isEmpty ? 0.0 : forecast.map((d) => d.tempMax).reduce(math.max);
    final rain7 = forecast.fold<double>(0, (s, d) => s + d.precipitation);

    final series = Series(
      title: 'Temperatura máxima diária',
      unit: '°C',
      description:
          'Temperatura máxima registrada nos últimos 30 dias, seguida da previsão para os próximos 7. '
          'Previsões de longo prazo são menos precisas, e microclimas do bairro podem diferir da estação de referência.',
      source: 'Open-Meteo (API pública e gratuita). Se estiver sem internet, o app usa a última resposta salva.',
      dates: t.weather.map((d) => d.date).toList(),
      values: t.weather.map((d) => d.tempMax).toList(),
    );

    return RefreshIndicator(
      onRefresh: t.load,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (t.weatherFromCache && t.weatherFetchedAt != null) ...[
            InfoBanner(
              icon: Icons.cloud_off,
              text: 'Sem conexão: exibindo dados salvos em ${DateFormat('dd/MM HH:mm').format(t.weatherFetchedAt!)}.',
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: StatCard(label: 'Máxima prevista (7 dias)', value: '${maxForecast.toStringAsFixed(0)} °C')),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: StatCard(label: 'Chuva prevista (7 dias)', value: '${rain7.toStringAsFixed(0)} mm')),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          StatCard(
            label: 'Temperatura máxima média (últimos 7 dias)',
            value: '${avgTemp7.toStringAsFixed(1).replaceAll('.', ',')} °C',
            trend: trend,
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            semanticLabel: 'Abrir detalhes do indicador temperatura',
            onTap: () => Navigator.pushNamed(context, AppRoutes.indicatorDetail, arguments: series),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Temperatura máxima (30 dias + previsão)', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                TrendLineChart(
                  dates: series.dates,
                  values: series.values,
                  semanticLabel:
                      'Gráfico de linha da temperatura máxima diária. Máxima prevista nos próximos 7 dias: '
                      '${maxForecast.toStringAsFixed(0)} graus.',
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('Os 7 últimos pontos são previsão. Toque para ver detalhes.',
                    style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chuva prevista (mm por dia)', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                SimpleBarChart(
                  labels: forecast.map((d) => DateFormat('dd/MM').format(d.date)).toList(),
                  values: forecast.map((d) => d.precipitation).toList(),
                  semanticLabel: 'Gráfico de barras da chuva prevista para os próximos 7 dias. '
                      'Total: ${rain7.toStringAsFixed(0)} milímetros.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}