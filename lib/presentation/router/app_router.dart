import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_travel_companion/domain/entities/place.dart';
import 'package:smart_travel_companion/presentation/screens/main_layout.dart';
import 'package:smart_travel_companion/presentation/screens/home_screen.dart';
import 'package:smart_travel_companion/presentation/screens/detail_screen.dart';
import 'package:smart_travel_companion/presentation/screens/favorites_screen.dart';
import 'package:smart_travel_companion/presentation/screens/map_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _mapNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _favNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _mapNavigatorKey,
          routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) {
                final place = state.extra as Place?;
                return MapScreen(selectedPlace: place);
              },
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _favNavigatorKey,
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const Scaffold(body: Center(child: Text('Profile Screen'))),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>;
        final place = extras['place'] as Place;
        final heroTagPrefix = extras['heroTagPrefix'] as String;
        return DetailScreen(place: place, heroTagPrefix: heroTagPrefix);
      },
    ),
  ],
);
