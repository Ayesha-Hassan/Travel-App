import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_travel_companion/core/services/notification_service.dart';
import 'package:smart_travel_companion/domain/repositories/place_repository.dart';
import 'package:smart_travel_companion/domain/repositories/weather_repository.dart';
import 'package:smart_travel_companion/data/repositories/place_repository.dart';
import 'package:smart_travel_companion/data/repositories/weather_repository.dart';
import 'package:smart_travel_companion/data/services/api_service.dart';
import 'package:smart_travel_companion/data/services/cache_service.dart';
import 'package:smart_travel_companion/logic/blocs/places/places_bloc.dart';
import 'package:smart_travel_companion/logic/blocs/places/places_event.dart';
import 'package:smart_travel_companion/logic/blocs/weather/weather_bloc.dart';
import 'package:smart_travel_companion/logic/blocs/theme/theme_bloc.dart';
import 'package:smart_travel_companion/presentation/router/app_router.dart';
import 'package:smart_travel_companion/presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final dio = Dio();
  final apiService = ApiService(dio);
  final cacheService = CacheService(prefs);
  final notificationService = NotificationService();
  
  await notificationService.init();

  final placeRepository = PlaceRepositoryImpl(apiService: apiService, cacheService: cacheService);
  final weatherRepository = WeatherRepositoryImpl(apiService);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PlaceRepository>(create: (_) => placeRepository),
        RepositoryProvider<WeatherRepository>(create: (_) => weatherRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(create: (_) => ThemeBloc(prefs)),
          BlocProvider<PlacesBloc>(
            create: (_) => PlacesBloc(repository: placeRepository)..add(const FetchPlaces()),
          ),
          BlocProvider<WeatherBloc>(
            create: (_) => WeatherBloc(repository: weatherRepository),
          ),
        ],
        child: const TravelApp(),
      ),
    ),
  );
}

class TravelApp extends StatelessWidget {
  const TravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp.router(
          title: 'Smart Travel Companion',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: appRouter,
        );
      },
    );
  }
}
