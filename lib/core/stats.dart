import 'trend.dart';

/// R² de uma regressão linear simples dos valores contra o índice (0 = sem ajuste, 1 = reta perfeita).
double rSquared(List<double> values) {
  final n = values.length;
  if (n < 3) return 0;
  final xMean = (n - 1) / 2;
  final yMean = average(values);
  var sxx = 0.0, sxy = 0.0, syy = 0.0;
  for (var i = 0; i < n; i++) {
    final dx = i - xMean;
    final dy = values[i] - yMean;
    sxx += dx * dx;
    sxy += dx * dy;
    syy += dy * dy;
  }
  if (sxx == 0 || syy == 0) return 0;
  return (sxy * sxy) / (sxx * syy);
}