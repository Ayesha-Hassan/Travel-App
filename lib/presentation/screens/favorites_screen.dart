import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_travel_companion/domain/entities/place.dart';
import 'package:smart_travel_companion/logic/blocs/places/places_bloc.dart';
import 'package:smart_travel_companion/logic/blocs/places/places_state.dart';
import 'package:smart_travel_companion/presentation/widgets/place_card.dart';
import 'package:smart_travel_companion/presentation/widgets/empty_state_widget.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Place> _list = [];
  final String _heroPrefix = 'fav';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: BlocListener<PlacesBloc, PlacesState>(
        listener: (context, state) {
          _syncList(state.favoritePlaces);
        },
        child: BlocBuilder<PlacesBloc, PlacesState>(
          builder: (context, state) {
            if (_list.isEmpty && state.favoritePlaces.isEmpty) {
              return const EmptyStateWidget(
                message: 'No favorites yet.',
                icon: Icons.favorite_border,
              );
            }
            return AnimatedList(
              key: _listKey,
              initialItemCount: _list.length,
              padding: const EdgeInsets.all(20),
              itemBuilder: (context, index, animation) {
                return _buildItem(_list[index], animation);
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _list.addAll(context.read<PlacesBloc>().state.favoritePlaces);
  }

  void _syncList(List<Place> newList) {
    // Handling removals
    for (int i = 0; i < _list.length; i++) {
      final item = _list[i];
      if (!newList.any((p) => p.id == item.id)) {
        final removedItem = _list.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildItem(removedItem, animation),
          duration: const Duration(milliseconds: 300),
        );
        i--;
      }
    }

    // Handling additions
    for (int i = 0; i < newList.length; i++) {
      final item = newList[i];
      if (!_list.any((p) => p.id == item.id)) {
        _list.insert(i, item);
        _listKey.currentState?.insertItem(i, duration: const Duration(milliseconds: 300));
      }
    }
  }

  Widget _buildItem(Place place, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: PlaceCard(place: place, heroTagPrefix: _heroPrefix),
        ),
      ),
    );
  }
}
