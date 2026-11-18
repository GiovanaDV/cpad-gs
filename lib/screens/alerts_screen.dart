import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart';
import '../core/format.dart';
import '../providers/alerts_provider.dart';
import '../widgets/alert_widgets.dart';
import '../widgets/human_decision_banner.dart';
import '../widgets/state_view.dart';
import '../widgets/stat_card.dart';
import '../widgets/status_gate.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = context.watch<AlertsProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        actions: [
          IconButton(
            tooltip: 'Ajustar limiares de alerta',
            icon: const Icon(Icons.tune),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: StatusGate(
        status: alerts.status,
        error: alerts.errorMessage,
        onRetry: alerts.reload,
        builder: (_) => _content(context, alerts),
      ),
    );
  }

  Widget _content(BuildContext context, AlertsProvider alerts) {
    final text = Theme.of(context).textTheme;
    final pending = alerts.pending;
    final decided = alerts.decided;
    final liters = alerts.litersAtRisk;

    return RefreshIndicator(
      onRefresh: alerts.reload,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const HumanDecisionBanner(),
          const SizedBox(height: AppSpacing.md),
          if (alerts.alerts.isEmpty)
            SizedBox(
              height: 320,
              child: StateView.empty(
                'Nenhum alerta ativo.\nOs dados do território estão dentro dos limiares configurados.',
              ),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: StatCard(label: 'Aguardando decisão', value: '${pending.length}')),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: StatCard(label: 'Com decisão humana', value: '${decided.length}')),
              ],
            ),
            if (liters > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              StatCard(label: 'Água em risco de desperdício (estimativa semanal)', value: '${formatFull(liters)} L'),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Indicador de benefício social: litros que podem ser poupados se o problema for tratado '
                'rapidamente. É uma estimativa, não uma medição.',
                style: text.labelSmall,
              ),
            ],
            if (pending.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text('Aguardando decisão', style: text.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              for (final a in pending) ...[
                AlertCard(
                  alert: a,
                  decision: null,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.alertDetail, arguments: a.id),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
            if (decided.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text('Já decididos', style: text.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              for (final a in decided) ...[
                AlertCard(
                  alert: a,
                  decision: alerts.decisionFor(a),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.alertDetail, arguments: a.id),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ],
        ],
      ),
    );
  }
}