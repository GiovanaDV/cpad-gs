import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart';
import '../core/load_status.dart';
import '../providers/alerts_provider.dart';
import 'alert_widgets.dart';
import 'app_card.dart';

class AlertsHomeCard extends StatelessWidget {
  const AlertsHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = context.watch<AlertsProvider>();
    if (alerts.status != LoadStatus.ready) return const SizedBox.shrink();

    final text = Theme.of(context).textTheme;
    final pending = alerts.pending;
    void open() => Navigator.pushNamed(context, AppRoutes.alerts);

    if (pending.isEmpty) {
      final message = alerts.alerts.isEmpty
          ? 'Nenhum alerta ativo no momento.'
          : 'Todos os alertas já têm decisão registrada.';
      return AppCard(
        onTap: open,
        semanticLabel: '$message Toque para abrir a lista de alertas.',
        child: Row(
          children: [
            const Icon(Icons.verified_outlined, color: AppColors.riskLow),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(message, style: text.titleSmall)),
            const Icon(Icons.chevron_right),
          ],
        ),
      );
    }

    final top = pending.first;
    final count = pending.length;
    final headline = '$count ${count == 1 ? 'alerta aguardando' : 'alertas aguardando'} decisão';
    return AppCard(
      onTap: open,
      semanticLabel: '$headline. Prioridade mais alta: ${top.title}. Toque para abrir.',
      child: Row(
        children: [
          Icon(AlertStyle.icon(top.severity), color: AlertStyle.color(top.severity)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(headline, style: text.titleMedium),
                Text('Prioridade mais alta: ${top.title}', style: text.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}