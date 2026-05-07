import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_travel_companion/domain/entities/place.dart';
import 'package:smart_travel_companion/domain/repositories/place_repository.dart';
import 'places_event.dart';
import 'places_state.dart';

class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  final PlaceRepository repository;
  static const int _pageSize = 5;
  static const String _favKey = 'favorite_ids';

  PlacesBloc({required this.repository}) : super(const PlacesState()) {
    on<FetchPlaces>(_onFetchPlaces);
    on<SearchPlaces>(_onSearchPlaces);
    on<ToggleFavorite>(_onToggleFavorite);
    on<ChangeFilter>(_onChangeFilter);
    on<FilterByRegion>(_onFilterByRegion);
    on<LoadMorePlaces>(_onLoadMorePlaces);
  }

  // ── Persist helpers ──────────────────────────────────────────────────────────

  Future<Set<int>> _loadFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_favKey) ?? [];
    return ids.map(int.parse).toSet();
  }

  Future<void> _saveFavoriteIds(List<Place> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favKey, favorites.map((p) => p.id.toString()).toList());
  }

  // ── Handlers ─────────────────────────────────────────────────────────────────

  Future<void> _onFetchPlaces(FetchPlaces event, Emitter<PlacesState> emit) async {
    emit(state.copyWith(status: PlacesStatus.loading));
    try {
      final favIds = await _loadFavoriteIds();
      final rawPlaces = await repository.getPlaces(forceRefresh: event.forceRefresh);

      // Restore persisted favorite state
      final places = rawPlaces.map((p) => p.copyWith(isFavorite: favIds.contains(p.id))).toList();

      final initialDisplay = places.take(_pageSize).toList();
      final favoritePlaces = places.where((p) => p.isFavorite).toList();
      emit(state.copyWith(
        status: PlacesStatus.success,
        allPlaces: places,
        filteredPlaces: initialDisplay,
        favoritePlaces: favoritePlaces,
        hasReachedMax: places.length <= _pageSize,
        currentPage: 1,
      ));
    } catch (e) {
      emit(state.copyWith(status: PlacesStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onSearchPlaces(SearchPlaces event, Emitter<PlacesState> emit) {
    if (event.query.isEmpty) {
      _applyFilter(emit, state.currentFilter);
    } else {
      final filtered = state.allPlaces
          .where((p) =>
              p.title.toLowerCase().contains(event.query.toLowerCase()) ||
              p.location.toLowerCase().contains(event.query.toLowerCase()))
          .toList();
      emit(state.copyWith(filteredPlaces: filtered, hasReachedMax: true));
    }
  }

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<PlacesState> emit) async {
    final isFav = state.favoritePlaces.any((p) => p.id == event.place.id);
    final updatedPlace = event.place.copyWith(isFavorite: !isFav);

    final List<Place> updatedFavs;
    if (isFav) {
      updatedFavs = state.favoritePlaces.where((p) => p.id != event.place.id).toList();
    } else {
      updatedFavs = List.from(state.favoritePlaces)..add(updatedPlace);
    }

    final updatedAll = state.allPlaces.map((p) {
      if (p.id == event.place.id) return updatedPlace;
      return p;
    }).toList();

    // Persist favorites
    await _saveFavoriteIds(updatedFavs);

    emit(state.copyWith(
      favoritePlaces: updatedFavs,
      allPlaces: updatedAll,
    ));

    _applyFilter(emit, state.currentFilter);
  }

  void _onChangeFilter(ChangeFilter event, Emitter<PlacesState> emit) {
    _applyFilter(emit, event.filter);
  }

  void _onFilterByRegion(FilterByRegion event, Emitter<PlacesState> emit) {
    final filtered = state.allPlaces
        .where((p) => p.location.toLowerCase().contains(event.region.toLowerCase()))
        .toList();
    emit(state.copyWith(
      currentFilter: 'Region:${event.region}',
      filteredPlaces: filtered.take(_pageSize).toList(),
      currentPage: 1,
      hasReachedMax: filtered.length <= _pageSize,
    ));
  }

  void _onLoadMorePlaces(LoadMorePlaces event, Emitter<PlacesState> emit) {
    if (state.hasReachedMax) return;

    final nextIndex = state.currentPage * _pageSize;
    final sourceList = _getSourceList(state.currentFilter);

    if (nextIndex >= sourceList.length) {
      emit(state.copyWith(hasReachedMax: true));
      return;
    }

    final morePlaces = sourceList.skip(nextIndex).take(_pageSize).toList();
    emit(state.copyWith(
      filteredPlaces: List.from(state.filteredPlaces)..addAll(morePlaces),
      currentPage: state.currentPage + 1,
      hasReachedMax: (nextIndex + _pageSize) >= sourceList.length,
    ));
  }

  void _applyFilter(Emitter<PlacesState> emit, String filter) {
    final sourceList = _getSourceList(filter);
    final initialDisplay = sourceList.take(_pageSize).toList();

    emit(state.copyWith(
      currentFilter: filter,
      filteredPlaces: initialDisplay,
      currentPage: 1,
      hasReachedMax: sourceList.length <= _pageSize,
    ));
  }

  List<Place> _getSourceList(String filter) {
    switch (filter) {
      case 'Favorites':
        return state.allPlaces.where((p) => p.isFavorite).toList();
      case 'Recent':
        return state.allPlaces.reversed.toList();
      default:
        return state.allPlaces;
    }
  }
}
