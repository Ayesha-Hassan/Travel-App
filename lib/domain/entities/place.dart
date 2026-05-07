import 'package:equatable/equatable.dart';

class Place extends Equatable {
  final int id;
  final String title;
  final String imageUrl;
  final String description;
  final String location;
  final String type;
  final double rating;
  final double lat;
  final double lng;
  final bool isFavorite;

  const Place({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.location,
    required this.type,
    required this.rating,
    required this.lat,
    required this.lng,
    this.isFavorite = false,
  });

  Place copyWith({
    int? id,
    String? title,
    String? imageUrl,
    String? description,
    String? location,
    String? type,
    double? rating,
    double? lat,
    double? lng,
    bool? isFavorite,
  }) {
    return Place(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      location: location ?? this.location,
      type: type ?? this.type,
      rating: rating ?? this.rating,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [id, title, imageUrl, description, location, type, rating, lat, lng, isFavorite];
}
