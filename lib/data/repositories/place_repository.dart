import 'package:smart_travel_companion/data/models/place_model.dart';
import 'package:smart_travel_companion/data/services/api_service.dart';
import 'package:smart_travel_companion/data/services/cache_service.dart';
import 'package:smart_travel_companion/domain/entities/place.dart';
import 'package:smart_travel_companion/domain/repositories/place_repository.dart';

class PlaceRepositoryImpl implements PlaceRepository {
  final ApiService apiService;
  final CacheService cacheService;

  PlaceRepositoryImpl({required this.apiService, required this.cacheService});

  @override
  Future<List<Place>> getPlaces({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedData = cacheService.getPlaces();
      if (cachedData != null) {
        return cachedData.map((json) => PlaceModel.fromJson(json)).toList();
      }
    }

    try {
      final response = await apiService.getDestinations();
      final List<dynamic> data = response.data;
      
      await cacheService.savePlaces(data);
      return data.map((json) => PlaceModel.fromJson(json)).toList();
    } catch (e) {
      final cachedData = cacheService.getPlaces();
      if (cachedData != null) {
        return cachedData.map((json) => PlaceModel.fromJson(json)).toList();
      }
      rethrow;
    }
  }
}
