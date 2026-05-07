import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  final double temperature;
  final String condition;
  final double windSpeed;
  final int humidity;

  const Weather({
    required this.temperature,
    required this.condition,
    required this.windSpeed,
    required this.humidity,
  });

  @override
  List<Object?> get props => [temperature, condition, windSpeed, humidity];
}
