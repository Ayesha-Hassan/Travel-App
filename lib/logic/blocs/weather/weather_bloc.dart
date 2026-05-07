import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel_companion/domain/repositories/weather_repository.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository repository;

  WeatherBloc({required this.repository}) : super(const WeatherState()) {
    on<FetchWeather>(_onFetchWeather);
  }

  Future<void> _onFetchWeather(FetchWeather event, Emitter<WeatherState> emit) async {
    emit(state.copyWith(status: WeatherStatus.loading));
    try {
      final weather = await repository.getWeather(event.lat, event.lon);
      emit(state.copyWith(status: WeatherStatus.success, weather: weather));
    } catch (e) {
      emit(state.copyWith(status: WeatherStatus.failure, errorMessage: e.toString()));
    }
  }
}
