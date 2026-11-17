import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart';
import '../core/format.dart';
import '../core/territory.dart';
import '../core/trend.dart';
import '../models/series.dart';
import '../providers/territory_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/simple_bar_chart.dart';
import '../widgets/state_view.dart';
import '../widgets/stat_card.dart';
import '../widgets/status_gate.dart';
import '../widgets/trend_line_chart.dart';

class WaterDashboardScreen extends StatefulWidget {
  const WaterDashboardScreen({super.key});

  @override
  State<WaterDashboardScreen> createState() => _WaterDashboardScreenState();
}

class _WaterDashboardScreenState extends State<WaterDashboardScreen> {
  String? _sector; // null = todos os setores

  @override
  Widget build(BuildContext context) {
    final t = context.watch<TerritoryProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Consumo de água')),
      body: StatusGate(
        status: t.status,
        error: t.errorMessage,
        onRetry: t.load,
        builder: (_) => _content(context, t),
      ),
    );
  }

  Widget _content(BuildContext context, TerritoryProvider t) {
    final entries = t.dailyWater(sector: _sector);
    if (entries.isEmpty) return StateView.empty('Sem leituras de consumo disponíveis.');

    final dates = entries.map((e) => e.key).toList();
    final values = entries.map((e) => e.value).toList();
    final trend = computeTrend(values);
    final avg7 = average(values.sublist(values.length - 7));
    final scope = _sector == null ? 'todos os setores' : 'setor $_sector';

    final sectorAvgs = [
      for (final s in Territory.sectors)
        () {
          final v = t.dailyWater(sector: s).map((e) => e.value).toList();
          return average(v.sublist(v.length - 7));
        }(),
    ];

    final series = Series(
      title: 'Consumo de água ($scope)',
      unit: 'L/dia',
      description:
          'Soma diária do consumo medido nos hidrômetros do território. A tendência compara a média dos '
          'últimos 7 dias com a dos 7 dias anteriores. Aumentos persistentes podem indicar vazamento ou '
          'desperdício, mas também feriados, calor ou eventos locais.',
      source: 'Dados sintéticos gerados para este projeto (simulam uma API da companhia de água).',
      dates: dates,
      values: values,
    );

    return RefreshIndicator(
      onRefresh: t.load,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final s in <String?>[null, ...Territory.sectors])
                ChoiceChip(
                  label: Text(s ?? 'Todos'),
                  selected: _sector == s,
                  onSelected: (_) => setState(() => _sector = s),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: StatCard(label: 'Média dos últimos 7 dias', value: '${formatCompact(avg7)} L/dia')),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: StatCard(label: 'Tendência', value: 'Consumo', trend: trend)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            semanticLabel: 'Abrir detalhes do indicador consumo de água',
            onTap: () => Navigator.pushNamed(context, AppRoutes.indicatorDetail, arguments: series),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Histórico de 60 dias ($scope)', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                TrendLineChart(
                  dates: dates,
                  values: values,
                  semanticLabel:
                      'Gráfico de linha do consumo diário de água, $scope. Média dos últimos 7 dias: '
                      '${formatCompact(avg7)} litros por dia.',
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('Toque para ver detalhes', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Média diária por setor (7 dias)', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                SimpleBarChart(
                  labels: Territory.sectors,
                  values: sectorAvgs,
                  semanticLabel: 'Gráfico de barras com o consumo médio diário por setor.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}