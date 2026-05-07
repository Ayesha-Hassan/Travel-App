import 'package:equatable/equatable.dart';
import 'package:smart_travel_companion/domain/entities/place.dart';

abstract class PlacesEvent extends Equatable {
  const PlacesEvent();

  @override
  List<Object?> get props => [];
}

class FetchPlaces extends PlacesEvent {
  final bool forceRefresh;
  const FetchPlaces({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class SearchPlaces extends PlacesEvent {
  final String query;
  const SearchPlaces(this.query);

  @override
  List<Object?> get props => [query];
}

class ToggleFavorite extends PlacesEvent {
  final Place place;
  const ToggleFavorite(this.place);

  @override
  List<Object?> get props => [place];
}

class ChangeFilter extends PlacesEvent {
  final String filter;
  const ChangeFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

class FilterByRegion extends PlacesEvent {
  final String region;
  const FilterByRegion(this.region);

  @override
  List<Object?> get props => [region];
}

class LoadMorePlaces extends PlacesEvent {
  const LoadMorePlaces();
}
