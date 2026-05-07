import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();
  @override
  List<Object?> get props => [];
}

class FetchWeather extends WeatherEvent {
  final double lat;
  final double lon;
  const FetchWeather({required this.lat, required this.lon});
  @override
  List<Object?> get props => [lat, lon];
}
