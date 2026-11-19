import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import '../core/format.dart';

class TrendLineChart extends StatelessWidget {
  final List<DateTime> dates;
  final List<double> values;
  final String semanticLabel;
  final double height;
  final String unit;
  final int decimals;

  const TrendLineChart({
    super.key,
    required this.dates,
    required this.values,
    required this.semanticLabel,
    this.height = 200,
    this.unit = '',
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = scheme.primary;
    final small = Theme.of(context).textTheme.labelSmall;
    final step = (dates.length / 4).ceil().clamp(1, 1000);
    final spots = [for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])];

    return Semantics(
      label: semanticLabel,
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => scheme.surface,
                  tooltipBorder: BorderSide(color: scheme.outline),
                  tooltipBorderRadius: BorderRadius.circular(8),
                  getTooltipItems: (touched) => touched.map((s) {
                    final i = s.x.round().clamp(0, dates.length - 1);
                    return LineTooltipItem(
                      '${DateFormat('dd/MM').format(dates[i])}\n',
                      TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                      children: [
                        TextSpan(
                          text: '${formatFull(s.y, decimals: decimals)}$unit',
                          style: TextStyle(color: scheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    getTitlesWidget: (v, meta) => Text(formatCompact(v), style: small),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                    getTitlesWidget: (v, meta) {
                      final i = v.round();
                      if (i < 0 || i >= dates.length || i % step != 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(DateFormat('dd/MM').format(dates[i]), style: small),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: color,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.12)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}