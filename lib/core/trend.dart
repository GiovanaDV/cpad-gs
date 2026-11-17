enum TrendDirection { up, down, stable }

class TrendResult {
  final double percent;
  final TrendDirection direction;
  const TrendResult(this.percent, this.direction);
}

double average(List<double> values) =>
    values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;

/// Compara a média dos últimos [window] valores com a dos [window] anteriores.
TrendResult computeTrend(List<double> values, {int window = 7, double tolerance = 2}) {
  if (values.length < window * 2) return const TrendResult(0, TrendDirection.stable);
  final recent = average(values.sublist(values.length - window));
  final previous = average(values.sublist(values.length - 2 * window, values.length - window));
  if (previous == 0) return const TrendResult(0, TrendDirection.stable);
  final pct = (recent - previous) / previous * 100;
  if (pct > tolerance) return TrendResult(pct, TrendDirection.up);
  if (pct < -tolerance) return TrendResult(pct, TrendDirection.down);
  return TrendResult(pct, TrendDirection.stable);
}