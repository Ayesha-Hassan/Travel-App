import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_travel_companion/logic/blocs/places/places_bloc.dart';
import 'package:smart_travel_companion/logic/blocs/places/places_event.dart';
import 'package:smart_travel_companion/logic/blocs/places/places_state.dart';
import 'package:smart_travel_companion/presentation/widgets/place_card.dart';
import 'package:smart_travel_companion/presentation/widgets/shimmer_card.dart';
import 'package:smart_travel_companion/presentation/widgets/app_drawer.dart';
import 'package:smart_travel_companion/presentation/widgets/error_retry_widget.dart';
import 'package:smart_travel_companion/presentation/widgets/empty_state_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  final String _heroPrefix = 'home';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PlacesBloc>().add(const LoadMorePlaces());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<PlacesBloc>().add(SearchPlaces(query));
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<PlacesBloc>().add(const FetchPlaces(forceRefresh: true));
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) => Row(
                          children: [
                            IconButton(
                              onPressed: () => Scaffold.of(context).openDrawer(),
                              icon: const Icon(Icons.menu_rounded, size: 28),
                            ),
                            const SizedBox(width: 5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Smart Travel',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Companion',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black87,
                                    height: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.notifications_none_rounded),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Your ultimate travel guide to explore\nbeautiful places, check real-time\nweather and manage your favorites.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Explore Places',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                hintText: 'Search places...',
                                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () => _showFilterSheet(context),
                              icon: const Icon(Icons.tune_rounded, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      _buildFilterChips(),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              BlocBuilder<PlacesBloc, PlacesState>(
                builder: (context, state) {
                  if (state.status == PlacesStatus.loading && state.allPlaces.isEmpty) {
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const ShimmerCard(),
                          childCount: 5,
                        ),
                      ),
                    );
                  }

                  if (state.status == PlacesStatus.failure && state.allPlaces.isEmpty) {
                    return SliverFillRemaining(
                      child: ErrorRetryWidget(
                        errorMessage: state.errorMessage,
                        onRetry: () => context.read<PlacesBloc>().add(const FetchPlaces()),
                      ),
                    );
                  }

                  final places = state.filteredPlaces;
                  if (places.isEmpty) {
                    return const SliverFillRemaining(
                      child: EmptyStateWidget(message: 'No destinations found.'),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= places.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final place = places[index];
                          // _AnimatedPlaceCard properly starts at 0.0 and animates to 1.0
                          return _AnimatedPlaceCard(
                            key: ValueKey(place.id),
                            delay: Duration(milliseconds: 60 * (index % 8)),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: PlaceCard(place: place, heroTagPrefix: _heroPrefix),
                            ),
                          );
                        },
                        childCount: state.hasReachedMax ? places.length : places.length + 1,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    String selectedSort = 'Recommended';
    String selectedRegion = 'All Regions';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      setSheetState(() {
                        selectedSort = 'Recommended';
                        selectedRegion = 'All Regions';
                      });
                      context.read<PlacesBloc>().add(const ChangeFilter('All'));
                      context.pop();
                    },
                    child: const Text('Clear All', style: TextStyle(color: Colors.purple)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedSort,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: ['Recommended', 'Popular', 'Newest']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setSheetState(() => selectedSort = v);
                },
              ),
              const SizedBox(height: 20),
              const Text('Region', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedRegion,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: [
                  'All Regions', 'Asia', 'Europe', 'Africa',
                  'Oceania', 'Middle East', 'South America', 'North America'
                ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) {
                  if (v != null) setSheetState(() => selectedRegion = v);
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (selectedRegion != 'All Regions') {
                    context.read<PlacesBloc>().add(FilterByRegion(selectedRegion));
                  } else if (selectedSort == 'Newest') {
                    context.read<PlacesBloc>().add(const ChangeFilter('Recent'));
                  } else {
                    context.read<PlacesBloc>().add(const ChangeFilter('All'));
                  }
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return BlocBuilder<PlacesBloc, PlacesState>(
      builder: (context, state) {
        final filters = ['All', 'Favorites', 'Recent'];
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((filter) {
              final isSelected = state.currentFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => context.read<PlacesBloc>().add(ChangeFilter(filter)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[600],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

/// Properly animates opacity from 0.0 → 1.0 when first mounted.
class _AnimatedPlaceCard extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _AnimatedPlaceCard({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<_AnimatedPlaceCard> createState() => _AnimatedPlaceCardState();
}

class _AnimatedPlaceCardState extends State<_AnimatedPlaceCard> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _opacity = 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      opacity: _opacity,
      child: widget.child,
    );
  }
}
