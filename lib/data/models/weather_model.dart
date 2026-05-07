import 'package:smart_travel_companion/domain/entities/weather.dart';

class WeatherModel extends Weather {
  const WeatherModel({
    required super.temperature,
    required super.condition,
    required super.windSpeed,
    required super.humidity,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current_weather'] as Map<String, dynamic>? ?? {};

    // Humidity comes from the hourly array — take the first value of the current day
    int humidity = 0;
    final hourly = json['hourly'] as Map<String, dynamic>?;
    if (hourly != null) {
      final humidityList = hourly['relativehumidity_2m'] as List<dynamic>?;
      if (humidityList != null && humidityList.isNotEmpty) {
        humidity = (humidityList.first as num?)?.toInt() ?? 0;
      }
    }

    return WeatherModel(
      temperature: (current['temperature'] as num?)?.toDouble() ?? 0.0,
      condition: _getCondition((current['weathercode'] as num?)?.toInt() ?? 0),
      windSpeed: (current['windspeed'] as num?)?.toDouble() ?? 0.0,
      humidity: humidity,
    );
  }

  static String _getCondition(int code) {
    if (code == 0) return 'Clear Sky';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 67) return 'Rainy';
    if (code <= 77) return 'Snowy';
    if (code <= 82) return 'Heavy Rain';
    return 'Stormy';
  }
}
