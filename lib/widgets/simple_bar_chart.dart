import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/format.dart';

class SimpleBarChart extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  final String semanticLabel;
  final double height;
  final String unit;
  final int decimals;

  const SimpleBarChart({
    super.key,
    required this.labels,
    required this.values,
    required this.semanticLabel,
    this.height = 180,
    this.unit = '',
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = scheme.secondary;
    final small = Theme.of(context).textTheme.labelSmall;

    return Semantics(
      label: semanticLabel,
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          child: BarChart(
            BarChartData(
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => scheme.surface,
                  tooltipBorder: BorderSide(color: scheme.outline),
                  tooltipBorderRadius: BorderRadius.circular(8),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                    '${labels[group.x]}\n',
                    TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                    children: [
                      TextSpan(
                        text: '${formatFull(rod.toY, decimals: decimals)}$unit',
                        style: TextStyle(color: scheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < values.length; i++)
                  BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                      toY: values[i],
                      color: color,
                      width: 18,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ]),
              ],
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
                    getTitlesWidget: (v, meta) {
                      final i = v.toInt();
                      if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(labels[i], style: small),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}