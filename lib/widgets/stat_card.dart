import 'package:material_ui/material_ui.dart';
import '../core/app_theme.dart';
import '../core/trend.dart';
import 'app_card.dart';
import 'trend_chip.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final TrendResult? trend;
  final bool upIsBad;

  const StatCard({super.key, required this.label, required this.value, this.trend, this.upIsBad = true});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          if (trend != null) ...[
            const SizedBox(height: AppSpacing.sm),
            TrendChip(trend: trend!, upIsBad: upIsBad),
          ],
        ],
      ),
    );
  }
}