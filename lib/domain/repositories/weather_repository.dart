import 'package:smart_travel_companion/domain/entities/weather.dart';

abstract class WeatherRepository {
  Future<Weather> getWeather(double lat, double lon);
}
