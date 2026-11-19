import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart';
import '../core/territory.dart';
import '../models/occurrence.dart';
import '../providers/occurrences_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/simple_bar_chart.dart';
import '../widgets/state_view.dart';
import '../widgets/stat_card.dart';
import '../widgets/status_gate.dart';

class ServicesDashboardScreen extends StatelessWidget {
  const ServicesDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final o = context.watch<OccurrencesProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Serviços e ocorrências')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.report),
        icon: const Icon(Icons.add),
        label: const Text('Registrar'),
      ),
      body: StatusGate(
        status: o.status,
        error: o.errorMessage,
        onRetry: o.load,
        builder: (_) => _content(context, o),
      ),
    );
  }

  Widget _content(BuildContext context, OccurrencesProvider o) {
    final items = o.items;
    if (items.isEmpty) return StateView.empty('Nenhuma ocorrência registrada ainda.');

    final open = items.where((i) => i.resolvedAt == null).toList();
    final resolved = items.where((i) => i.resolvedAt != null).toList();
    final avgHours = resolved.isEmpty
        ? null
        : resolved.map((i) => i.resolvedAt!.difference(i.createdAt).inMinutes / 60).reduce((a, b) => a + b) /
            resolved.length;
    final openBySector = [
      for (final s in Territory.sectors) open.where((i) => i.sector == s).length.toDouble(),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: StatCard(label: 'Ocorrências abertas', value: '${open.length}')),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatCard(
                label: 'Tempo médio de resposta',
                value: avgHours == null ? '—' : '${avgHours.toStringAsFixed(0)} h',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Indicador de benefício social: quanto menor o tempo de resposta, menos tempo a população fica sem solução.',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ocorrências abertas por setor', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              SimpleBarChart(
                labels: Territory.sectors,
                values: openBySector,
                semanticLabel: 'Gráfico de barras com o número de ocorrências abertas por setor.',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Ocorrências recentes', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        for (final item in items.take(10)) ...[
          _OccurrenceTile(item),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _OccurrenceTile extends StatelessWidget {
  final Occurrence item;
  const _OccurrenceTile(this.item);

  @override
  Widget build(BuildContext context) {
    final isOpen = item.resolvedAt == null;
    final status = isOpen ? 'Aberta' : 'Resolvida';
    final date = DateFormat('dd/MM HH:mm').format(item.createdAt);
    final text = Theme.of(context).textTheme;
    return Semantics(
      label: '${item.category}, setor ${item.sector}, $status, registrada em $date. ${item.description}',
      child: ExcludeSemantics(
        child: AppCard(
          child: Row(
            children: [
              Icon(isOpen ? Icons.report_problem_outlined : Icons.check_circle_outline,
                  color: isOpen ? AppColors.riskMedium : AppColors.riskLow),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${item.category} · ${item.sector}', style: text.titleSmall),
                    Text(item.description, style: text.bodyMedium),
                    Text('$status · $date · ${item.source}', style: text.labelSmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}