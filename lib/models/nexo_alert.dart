import 'series.dart';

enum AlertSeverity { low, medium, high }

enum AlertKind { waterTrend, heat, rain, occurrenceCluster }

enum DecisionType { accepted, dismissed, forwarded }

extension AlertSeverityText on AlertSeverity {
  String get label => switch (this) {
        AlertSeverity.low => 'Baixa',
        AlertSeverity.medium => 'Média',
        AlertSeverity.high => 'Alta',
      };
}

extension DecisionTypeText on DecisionType {
  String get label => switch (this) {
        DecisionType.accepted => 'Aceito',
        DecisionType.dismissed => 'Descartado (falso alarme)',
        DecisionType.forwarded => 'Encaminhado para análise',
      };
}

class NexoAlert {
  final String id;
  final AlertKind kind;
  final AlertSeverity severity;
  final String title;
  final String summary;
  final double confidence;
  final String confidenceBreakdown;
  final List<String> evidence;
  final List<String> limitations;
  final String recommendation;
  final String? sector;
  final Series? series;
  final double? litersAtRisk;

  const NexoAlert({
    required this.id,
    required this.kind,
    required this.severity,
    required this.title,
    required this.summary,
    required this.confidence,
    required this.confidenceBreakdown,
    required this.evidence,
    required this.limitations,
    required this.recommendation,
    this.sector,
    this.series,
    this.litersAtRisk,
  });

  int get confidencePercent => (confidence * 100).round();

  String get confidenceLabel => confidence >= 0.75
      ? 'alta'
      : confidence >= 0.5
          ? 'média'
          : 'baixa';
}

class AlertDecision {
  final DecisionType type;
  final String note;
  final DateTime decidedAt;

  const AlertDecision({required this.type, required this.note, required this.decidedAt});

  Map<String, Object?> toJson() => {
        'type': type.name,
        'note': note,
        'decidedAt': decidedAt.toIso8601String(),
      };

  factory AlertDecision.fromJson(Map<String, dynamic> m) => AlertDecision(
        type: DecisionType.values.byName(m['type'] as String),
        note: m['note'] as String,
        decidedAt: DateTime.parse(m['decidedAt'] as String),
      );
}