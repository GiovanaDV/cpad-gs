String formatCompact(double v) {
  final abs = v.abs();
  String s;
  if (abs >= 1000000) {
    s = '${(v / 1000000).toStringAsFixed(1)}M';
  } else if (abs >= 1000) {
    s = '${(v / 1000).toStringAsFixed(abs >= 10000 ? 0 : 1)}k';
  } else {
    s = v.toStringAsFixed(abs >= 100 ? 0 : 1);
  }
  return s.replaceAll('.', ',');
}

String formatPercent(double p) =>
    '${p >= 0 ? '+' : ''}${p.toStringAsFixed(1).replaceAll('.', ',')}%';


/// Número completo no padrão brasileiro: 163447.4 -> "163.447" (ou "163.447,4" com decimals: 1).
String formatFull(double v, {int decimals = 0}) {
  final parts = v.toStringAsFixed(decimals).split('.');
  final intPart = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  return decimals == 0 ? intPart : '$intPart,${parts[1]}';
}