import 'package:material_ui/material_ui.dart';
import '../core/app_theme.dart';
import '../core/format.dart';
import '../core/trend.dart';

class TrendChip extends StatelessWidget {
  final TrendResult trend;
  final bool upIsBad;

  const TrendChip({super.key, required this.trend, this.upIsBad = true});

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (trend.direction) {
      TrendDirection.up => (Icons.trending_up, 'Alta'),
      TrendDirection.down => (Icons.trending_down, 'Queda'),
      TrendDirection.stable => (Icons.trending_flat, 'Estável'),
    };
    final bad = switch (trend.direction) {
      TrendDirection.up => upIsBad,
      TrendDirection.down => !upIsBad,
      TrendDirection.stable => null,
    };
    final color = bad == null
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : (bad ? AppColors.riskHigh : AppColors.riskLow);
    final text = '$label ${formatPercent(trend.percent)} vs 7 dias anteriores';

    return Semantics(
      label: 'Tendência: $text',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color)),
            ),
          ],
        ),
      ),
    );
  }
}