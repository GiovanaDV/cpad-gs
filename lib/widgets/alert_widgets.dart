import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/nexo_alert.dart';
import 'app_card.dart';

class AlertStyle {
  static Color color(AlertSeverity s) => switch (s) {
        AlertSeverity.low => AppColors.riskLow,
        AlertSeverity.medium => AppColors.riskMedium,
        AlertSeverity.high => AppColors.riskHigh,
      };

  static IconData icon(AlertSeverity s) => switch (s) {
        AlertSeverity.low => Icons.info_outline,
        AlertSeverity.medium => Icons.warning_amber_rounded,
        AlertSeverity.high => Icons.error_outline,
      };
}

class SeverityChip extends StatelessWidget {
  final AlertSeverity severity;
  const SeverityChip({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = AlertStyle.color(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AlertStyle.icon(severity), size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Prioridade ${severity.label}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class ConfidenceMeter extends StatelessWidget {
  final NexoAlert alert;
  const ConfidenceMeter({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Confiança ${alert.confidenceLabel}, ${alert.confidencePercent} por cento',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confiança ${alert.confidenceLabel} · ${alert.confidencePercent}%',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: alert.confidence, minHeight: 6),
            ),
          ],
        ),
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  final NexoAlert alert;
  final AlertDecision? decision;
  final VoidCallback onTap;

  const AlertCard({super.key, required this.alert, required this.decision, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final status = decision == null ? 'Aguardando decisão humana' : 'Decisão: ${decision!.type.label}';
    return AppCard(
      onTap: onTap,
      semanticLabel: 'Alerta de prioridade ${alert.severity.label}. ${alert.title}. '
          'Confiança ${alert.confidenceLabel}. $status. Toque para ver detalhes.',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SeverityChip(severity: alert.severity),
            const SizedBox(height: AppSpacing.sm),
            Text(alert.title, style: text.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(alert.summary, style: text.bodySmall),
            const SizedBox(height: AppSpacing.md),
            ConfidenceMeter(alert: alert),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  decision == null ? Icons.hourglass_empty : Icons.check_circle_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: Text(status, style: text.labelSmall)),
                const Icon(Icons.chevron_right),
              ],
            ),
          ],
        ),
      ),
    );
  }
}