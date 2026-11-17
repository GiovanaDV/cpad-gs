class Occurrence {
  final int? id;
  final String category;
  final String sector;
  final String description;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String source; // 'cidadão' ou 'sintético'

  const Occurrence({
    this.id,
    required this.category,
    required this.sector,
    required this.description,
    required this.createdAt,
    this.resolvedAt,
    required this.source,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'category': category,
        'sector': sector,
        'description': description,
        'created_at': createdAt.toIso8601String(),
        'resolved_at': resolvedAt?.toIso8601String(),
        'source': source,
      };

  factory Occurrence.fromMap(Map<String, Object?> m) => Occurrence(
        id: m['id'] as int?,
        category: m['category'] as String,
        sector: m['sector'] as String,
        description: m['description'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
        resolvedAt: m['resolved_at'] == null ? null : DateTime.parse(m['resolved_at'] as String),
        source: m['source'] as String,
      );
}