/// Série temporal enviada como parâmetro para a tela de detalhe do indicador.
class Series {
  final String title;
  final String unit;
  final String description;
  final String source;
  final List<DateTime> dates;
  final List<double> values;
  final bool upIsBad;

  const Series({
    required this.title,
    required this.unit,
    required this.description,
    required this.source,
    required this.dates,
    required this.values,
    this.upIsBad = true,
  });
}