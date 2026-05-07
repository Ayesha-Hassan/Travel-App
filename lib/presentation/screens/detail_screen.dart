import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_travel_companion/core/services/notification_service.dart';
import 'package:smart_travel_companion/domain/entities/place.dart';
import 'package:smart_travel_companion/logic/blocs/places/places_bloc.dart';
import 'package:smart_travel_companion/logic/blocs/places/places_event.dart';
import 'package:smart_travel_companion/logic/blocs/places/places_state.dart';
import 'package:smart_travel_companion/logic/blocs/weather/weather_bloc.dart';
import 'package:smart_travel_companion/logic/blocs/weather/weather_event.dart';
import 'package:smart_travel_companion/logic/blocs/weather/weather_state.dart';
import 'package:smart_travel_companion/presentation/widgets/weather_card.dart';

class DetailScreen extends StatefulWidget {
  final Place place;
  final String heroTagPrefix;

  const DetailScreen({
    super.key,
    required this.place,
    required this.heroTagPrefix,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Controls AnimatedSize for the expandable description
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    context.read<WeatherBloc>().add(FetchWeather(lat: widget.place.lat, lon: widget.place.lng));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlacesBloc, PlacesState>(
      builder: (context, placesState) {
        // Keep the favorite state in sync with the BLoC (not just the initial object)
        final currentPlace = placesState.allPlaces.firstWhere(
          (p) => p.id == widget.place.id,
          orElse: () => widget.place,
        );

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(
                      currentPlace.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      context.read<PlacesBloc>().add(ToggleFavorite(currentPlace));
                    },
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              // Hero Image
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.45,
                child: Hero(
                  tag: '${widget.heroTagPrefix}_${widget.place.id}',
                  child: CachedNetworkImage(
                    imageUrl: widget.place.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Content
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        padding: const EdgeInsets.fromLTRB(25, 30, 25, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.place.title,
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.grey, size: 18),
                                const SizedBox(width: 5),
                                Text(
                                  widget.place.location,
                                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            // ── Weather Section with AnimatedSwitcher ──────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Current Weather',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    children: [
                                      CircleAvatar(backgroundColor: Colors.green, radius: 4),
                                      SizedBox(width: 6),
                                      Text(
                                        'Live',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            // AnimatedSwitcher transitions between loading, error and data widgets
                            BlocBuilder<WeatherBloc, WeatherState>(
                              builder: (context, state) {
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  transitionBuilder: (child, animation) => FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.1),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  ),
                                  child: _buildWeatherContent(state),
                                );
                              },
                            ),
                            const SizedBox(height: 30),
                            // ── About the Place with AnimatedSize ─────────────────
                            GestureDetector(
                              onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'About the place',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        AnimatedRotation(
                                          turns: _isDescriptionExpanded ? 0.5 : 0.0,
                                          duration: const Duration(milliseconds: 300),
                                          child: const Icon(Icons.keyboard_arrow_down_rounded),
                                        ),
                                      ],
                                    ),
                                    // AnimatedSize expands/collapses the description
                                    AnimatedSize(
                                      duration: const Duration(milliseconds: 350),
                                      curve: Curves.easeInOut,
                                      child: _isDescriptionExpanded
                                          ? Padding(
                                              padding: const EdgeInsets.only(top: 12),
                                              child: Text(
                                                widget.place.description,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                  height: 1.6,
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // ── Set Reminder Button ───────────────────────────────
                            OutlinedButton.icon(
                              onPressed: () async {
                                await NotificationService().showTripReminder(widget.place);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Reminder set for ${widget.place.title}!'),
                                      backgroundColor: Theme.of(context).primaryColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.notifications_active_outlined),
                              label: const Text('Set Trip Reminder'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom "View on Map" Button
              Positioned(
                bottom: 25,
                left: 25,
                right: 25,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/map', extra: widget.place),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text(
                    'View on Map',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeatherContent(WeatherState state) {
    if (state.status == WeatherStatus.loading) {
      return const SizedBox(
        key: ValueKey('weather_loading'),
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.status == WeatherStatus.failure) {
      return Padding(
        key: const ValueKey('weather_error'),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_rounded, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Weather unavailable: ${state.errorMessage}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    }
    if (state.weather != null) {
      return WeatherCard(key: const ValueKey('weather_data'), weather: state.weather!);
    }
    return const SizedBox.shrink(key: ValueKey('weather_empty'));
  }
}
