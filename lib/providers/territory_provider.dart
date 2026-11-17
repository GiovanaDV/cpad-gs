import 'package:flutter/foundation.dart';
import '../core/load_status.dart';
import '../models/water_reading.dart';
import '../models/weather_day.dart';
import '../services/synthetic_data_service.dart';
import '../services/weather_service.dart';

class TerritoryProvider extends ChangeNotifier {
  final SyntheticDataService _synthetic = SyntheticDataService();
  final WeatherService _weather = WeatherService();

  LoadStatus status = LoadStatus.loading;
  String? errorMessage;
  List<WaterReading> water = [];
  List<WeatherDay> weather = [];
  bool weatherFromCache = false;
  DateTime? weatherFetchedAt;

  Future<void> load() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([_synthetic.fetchWaterReadings(), _weather.fetch()]);
      water = results[0] as List<WaterReading>;
      final w = results[1] as WeatherResult;
      weather = w.days;
      weatherFromCache = w.fromCache;
      weatherFetchedAt = w.fetchedAt;
      status = LoadStatus.ready;
    } catch (_) {
      errorMessage = 'Sem conexão e sem dados salvos. Conecte-se à internet e tente novamente.';
      status = LoadStatus.error;
    }
    notifyListeners();
  }
}