import 'package:smart_travel_companion/domain/entities/place.dart';

abstract class PlaceRepository {
  Future<List<Place>> getPlaces({bool forceRefresh = false});
}
