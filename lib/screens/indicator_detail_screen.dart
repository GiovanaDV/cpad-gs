import 'package:material_ui/material_ui.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart';
import '../core/format.dart';
import '../core/trend.dart';
import '../models/series.dart';
import '../widgets/app_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/trend_line_chart.dart';

class IndicatorDetailScreen extends StatelessWidget {
  final Series series;
  const IndicatorDetailScreen({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    final v = series.values;
    final minV = v.reduce((a, b) => a < b ? a : b);
    final maxV = v.reduce((a, b) => a > b ? a : b);
    final text = Theme.of(context).textTheme;
    String fmt(double x) => '${formatCompact(x)} ${series.unit}';

    return Scaffold(
      appBar: AppBar(title: Text(series.title)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            child: TrendLineChart(
              dates: series.dates,
              values: v,
              height: 240,
              semanticLabel: 'Gráfico de ${series.title}. Mínimo ${fmt(minV)}, máximo ${fmt(maxV)}.',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: StatCard(label: 'Mínimo', value: fmt(minV))),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: StatCard(label: 'Máximo', value: fmt(maxV))),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: StatCard(label: 'Média do período', value: fmt(average(v)))),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatCard(label: 'Tendência', value: 'Recente', trend: computeTrend(v), upIsBad: series.upIsBad),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sobre este indicador', style: text.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(series.description),
                const SizedBox(height: AppSpacing.md),
                Text('Fonte dos dados', style: text.titleSmall),
                Text(series.source),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.alerts),
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Ver alertas do território'),
          ),
        ],
      ),
    );
  }
}