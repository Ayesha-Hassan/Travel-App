import 'package:smart_travel_companion/data/models/weather_model.dart';
import 'package:smart_travel_companion/data/services/api_service.dart';
import 'package:smart_travel_companion/domain/entities/weather.dart';
import 'package:smart_travel_companion/domain/repositories/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final ApiService apiService;

  WeatherRepositoryImpl(this.apiService);

  @override
  Future<Weather> getWeather(double lat, double lon) async {
    final response = await apiService.getWeather(lat, lon);
    return WeatherModel.fromJson(response.data);
  }
}
