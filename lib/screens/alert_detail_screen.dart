import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../models/nexo_alert.dart';
import '../providers/alerts_provider.dart';
import '../widgets/alert_widgets.dart';
import '../widgets/app_card.dart';
import '../widgets/bullet_list.dart';
import '../widgets/human_decision_banner.dart';
import '../widgets/state_view.dart';
import '../widgets/trend_line_chart.dart';

class AlertDetailScreen extends StatefulWidget {
  final String alertId;
  const AlertDetailScreen({super.key, required this.alertId});

  @override
  State<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends State<AlertDetailScreen> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlertsProvider>();
    final alert = provider.byId(widget.alertId);

    if (alert == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhe do alerta')),
        body: StateView.empty('Este alerta não está mais ativo.\nOs dados foram atualizados.'),
      );
    }

    final text = Theme.of(context).textTheme;
    final decision = provider.decisionFor(alert);
    final series = alert.series;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do alerta')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const HumanDecisionBanner(),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SeverityChip(severity: alert.severity),
                const SizedBox(height: AppSpacing.sm),
                Text(alert.title, style: text.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(alert.summary),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _section(
            context,
            'Nível de confiança',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConfidenceMeter(alert: alert),
                const SizedBox(height: AppSpacing.sm),
                Text('Como foi calculada', style: text.titleSmall),
                Text(alert.confidenceBreakdown, style: text.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _section(context, 'Evidências (por que este alerta apareceu)',
              BulletList(items: alert.evidence, icon: Icons.check_circle_outline)),
          if (series != null) ...[
            const SizedBox(height: AppSpacing.md),
            _section(
              context,
              series.title,
              TrendLineChart(
                dates: series.dates,
                values: series.values,
                unit: ' ${series.unit}',
                decimals: series.unit == '°C' ? 1 : 0,
                semanticLabel: 'Gráfico de ${series.title} que embasa este alerta.',
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _section(
            context,
            'Limitações e quando não confiar',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BulletList(items: alert.limitations, icon: Icons.warning_amber_rounded),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Este alerta é um indício estatístico, não uma confirmação do problema.',
                  style: text.labelMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _section(context, 'Sugestão de verificação', Text(alert.recommendation)),
          const SizedBox(height: AppSpacing.lg),
          Text('Decisão do gestor', style: text.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          if (decision != null) _decidedView(context, provider, alert, decision) else _decisionForm(context, provider, alert),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, Widget child) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }

  Widget _decisionForm(BuildContext context, AlertsProvider provider, NexoAlert alert) {
    final outlined = OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _noteController,
          maxLength: 200,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Observação (opcional)',
            helperText: 'Não inclua dados pessoais.',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        FilledButton.icon(
          onPressed: () => _decide(provider, alert, DecisionType.accepted),
          icon: const Icon(Icons.check),
          label: const Text('Aceitar alerta'),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          style: outlined,
          onPressed: () => _decide(provider, alert, DecisionType.forwarded),
          icon: const Icon(Icons.forward_to_inbox_outlined),
          label: const Text('Encaminhar para análise'),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          style: outlined,
          onPressed: () => _decide(provider, alert, DecisionType.dismissed),
          icon: const Icon(Icons.close),
          label: const Text('Descartar (falso alarme)'),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Sua decisão fica registrada neste aparelho. O app não executa nenhuma ação automática.',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  Widget _decidedView(BuildContext context, AlertsProvider provider, NexoAlert alert, AlertDecision decision) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text('Decisão registrada: ${decision.type.label}', style: text.titleSmall)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(DateFormat('dd/MM/yyyy HH:mm').format(decision.decidedAt), style: text.labelSmall),
          if (decision.note.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('Observação: ${decision.note}'),
          ],
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: () => provider.reopen(alert),
            icon: const Icon(Icons.undo),
            label: const Text('Reabrir para nova decisão'),
          ),
        ],
      ),
    );
  }

  Future<void> _decide(AlertsProvider provider, NexoAlert alert, DecisionType type) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registrar decisão?'),
        content: Text(
          'Você vai registrar: "${type.label}". Esta é uma decisão humana, salva apenas neste aparelho. '
          'O app não executa nenhuma ação automática.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(96, 48)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await provider.decide(alert, type, note: _noteController.text.trim());
    if (!mounted) return;
    _noteController.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Decisão registrada.')));
  }
}