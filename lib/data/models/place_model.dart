import 'package:smart_travel_companion/domain/entities/place.dart';

class PlaceModel extends Place {
  PlaceModel({
    required super.id,
    required super.title,
    required super.imageUrl,
    required super.description,
    required super.location,
    required super.type,
    required super.rating,
    required super.lat,
    required super.lng,
    super.isFavorite,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    
    // Seed mock data based on ID for a rich simulation
    final List<String> locations = ['Paris, France', 'Kyoto, Japan', 'Bali, Indonesia', 'Swiss Alps, Switzerland', 'New York, USA', 'Cairo, Egypt', 'Sydney, Australia', 'Cape Town, South Africa', 'Amazon Forest, Brazil', 'Petra, Jordan'];
    final List<String> types = ['City', 'Culture', 'Beach', 'Nature', 'Metropolis', 'History', 'Adventure', 'Scenery', 'Wildlife', 'Ancient'];
    
    final location = json['country'] ?? locations[id % locations.length];
    final type = json['type'] ?? types[id % types.length];
    final rating = (json['rating'] ?? (4.0 + (id % 10) / 10)).toDouble();
    
    // Deterministic coordinates for map markers
    final lat = (json['lat'] ?? (10.0 + (id * 7) % 50)).toDouble();
    final lng = (json['lng'] ?? (20.0 + (id * 13) % 100)).toDouble();

    return PlaceModel(
      id: id,
      title: json['name'] ?? json['title'] ?? 'Destination $id',
      imageUrl: json['image'] ?? 'https://picsum.photos/seed/$id/600/400',
      description: json['description'] ?? 'Explore the hidden gems of $location. This $type destination offers a unique experience with its rich culture and stunning landscapes. Perfect for a memorable journey.',
      location: location,
      type: type,
      rating: rating,
      lat: lat,
      lng: lng,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title,
      'image': imageUrl,
      'description': description,
      'country': location,
      'type': type,
      'rating': rating,
      'lat': lat,
      'lng': lng,
      'isFavorite': isFavorite,
    };
  }
}
