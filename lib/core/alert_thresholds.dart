class AlertThresholds {
  final double waterTrendPercent;
  final double heatTempC;
  final double rainDailyMm;
  final int openOccurrences;

  const AlertThresholds({
    this.waterTrendPercent = 10,
    this.heatTempC = 32,
    this.rainDailyMm = 30,
    this.openOccurrences = 2,
  });

  AlertThresholds copyWith({
    double? waterTrendPercent,
    double? heatTempC,
    double? rainDailyMm,
    int? openOccurrences,
  }) =>
      AlertThresholds(
        waterTrendPercent: waterTrendPercent ?? this.waterTrendPercent,
        heatTempC: heatTempC ?? this.heatTempC,
        rainDailyMm: rainDailyMm ?? this.rainDailyMm,
        openOccurrences: openOccurrences ?? this.openOccurrences,
      );

  Map<String, Object?> toJson() => {
        'waterTrendPercent': waterTrendPercent,
        'heatTempC': heatTempC,
        'rainDailyMm': rainDailyMm,
        'openOccurrences': openOccurrences,
      };

  factory AlertThresholds.fromJson(Map<String, dynamic> m) => AlertThresholds(
        waterTrendPercent: (m['waterTrendPercent'] as num).toDouble(),
        heatTempC: (m['heatTempC'] as num).toDouble(),
        rainDailyMm: (m['rainDailyMm'] as num).toDouble(),
        openOccurrences: (m['openOccurrences'] as num).toInt(),
      );
}