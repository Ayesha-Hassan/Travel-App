import 'package:equatable/equatable.dart';
import 'package:smart_travel_companion/domain/entities/place.dart';

enum PlacesStatus { initial, loading, success, failure }

class PlacesState extends Equatable {
  final PlacesStatus status;
  final List<Place> allPlaces;
  final List<Place> filteredPlaces;
  final List<Place> favoritePlaces;
  final String errorMessage;
  final String currentFilter;
  final bool hasReachedMax;
  final int currentPage;

  const PlacesState({
    this.status = PlacesStatus.initial,
    this.allPlaces = const [],
    this.filteredPlaces = const [],
    this.favoritePlaces = const [],
    this.errorMessage = '',
    this.currentFilter = 'All',
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  PlacesState copyWith({
    PlacesStatus? status,
    List<Place>? allPlaces,
    List<Place>? filteredPlaces,
    List<Place>? favoritePlaces,
    String? errorMessage,
    String? currentFilter,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return PlacesState(
      status: status ?? this.status,
      allPlaces: allPlaces ?? this.allPlaces,
      filteredPlaces: filteredPlaces ?? this.filteredPlaces,
      favoritePlaces: favoritePlaces ?? this.favoritePlaces,
      errorMessage: errorMessage ?? this.errorMessage,
      currentFilter: currentFilter ?? this.currentFilter,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allPlaces,
        filteredPlaces,
        favoritePlaces,
        errorMessage,
        currentFilter,
        hasReachedMax,
        currentPage,
      ];
}
