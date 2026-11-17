import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/territory.dart';
import '../models/weather_day.dart';

class WeatherResult {
  final List<WeatherDay> days;
  final bool fromCache;
  final DateTime fetchedAt;

  const WeatherResult({required this.days, required this.fromCache, required this.fetchedAt});
}

class WeatherService {
  static const _cacheKey = 'weather_cache_v1';

  /// Busca na API Open-Meteo; se falhar, usa o último resultado salvo.
  Future<WeatherResult> fetch() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': '${Territory.latitude}',
        'longitude': '${Territory.longitude}',
        'daily': 'temperature_2m_max,precipitation_sum',
        'past_days': '30',
        'forecast_days': '7',
        'timezone': 'auto',
      });
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
      final now = DateTime.now();
      final days = _parse(res.body);
      await prefs.setString(_cacheKey, jsonEncode({'fetchedAt': now.toIso8601String(), 'body': res.body}));
      return WeatherResult(days: days, fromCache: false, fetchedAt: now);
    } catch (_) {
      final cached = prefs.getString(_cacheKey);
      if (cached == null) rethrow;
      final map = jsonDecode(cached) as Map<String, dynamic>;
      return WeatherResult(
        days: _parse(map['body'] as String),
        fromCache: true,
        fetchedAt: DateTime.parse(map['fetchedAt'] as String),
      );
    }
  }

  List<WeatherDay> _parse(String body) {
    final daily = (jsonDecode(body) as Map<String, dynamic>)['daily'] as Map<String, dynamic>;
    final times = List<String>.from(daily['time'] as List);
    final tmax = daily['temperature_2m_max'] as List;
    final rain = daily['precipitation_sum'] as List;
    return List.generate(times.length, (i) {
      return WeatherDay(
        date: DateTime.parse(times[i]),
        tempMax: (tmax[i] as num?)?.toDouble() ?? 0,
        precipitation: (rain[i] as num?)?.toDouble() ?? 0,
      );
    });
  }
}