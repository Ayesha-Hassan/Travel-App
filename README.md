# 🌍 Smart Travel Companion

A feature-rich Flutter application built as a final assignment for the SMD (Software Mobile Development) course. It serves as a smart travel guide — explore beautiful destinations worldwide, check live weather, save favorites, and view locations on an interactive map.

---

## ✨ Features

### Core
| Feature | Details |
|---|---|
| **Explore Places** | Browse 12 curated world destinations fetched from the JSONPlaceholder API and enriched with static travel metadata |
| **Search with Debounce** | Real-time search (300ms debounce) filters by city or country |
| **Filters** | Chip filters (All / Favorites / Recent) + bottom-sheet filter by Region and Sort order |
| **Favorites** | Toggle favorites with a heart icon; persisted across app restarts via SharedPreferences |
| **Pull-to-refresh** | Swipe down to force a fresh API fetch |
| **Pagination** | Loads 5 places at a time; fetches more as you scroll to the bottom |
| **Live Weather** | Open-Meteo API shows real-time temperature, wind speed, and condition for each destination |
| **Interactive Map** | flutter_map + OpenStreetMap tiles with a marker pinned at each place's coordinates |
| **Push Notifications** | Set a trip reminder from the Detail screen (Android) |
| **Dark Mode** | Full light / dark theme toggle, persisted between sessions |
| **Offline Support** | API responses cached locally (1-hour TTL); serves cache on network failure |

### Animations
| Animation | Where used |
|---|---|
| `Hero` | Image card → Detail screen transition |
| `AnimatedContainer` | Filter chips animate color/shape on selection |
| `AnimatedOpacity` (0→1) | Place cards fade in with staggered delay when list loads |
| `AnimatedList` | Favorites screen — items slide + fade in/out when added or removed |
| `AnimatedSize` | "About the place" section smoothly expands/collapses on tap |
| `AnimatedSwitcher` | Weather section transitions between loading, error, and data states with fade+slide |
| `AnimatedRotation` | Expand/collapse arrow icon rotates 180° |

---

## 🏗 Architecture

This project follows **Clean Architecture** principles:

```
lib/
├── core/               # Cross-cutting concerns (NotificationService, theme, router stubs)
├── data/
│   ├── models/         # JSON deserialization (PlaceModel, WeatherModel)
│   ├── repositories/   # Concrete implementations (PlaceRepositoryImpl, WeatherRepositoryImpl)
│   └── services/       # ApiService (Dio), CacheService (SharedPreferences)
├── domain/
│   ├── entities/       # Pure business objects (Place, Weather) — no Flutter dependency
│   └── repositories/   # Abstract interfaces (PlaceRepository, WeatherRepository)
├── logic/
│   └── blocs/
│       ├── places/     # PlacesBloc — fetch, search, filter, favorite, paginate
│       ├── weather/    # WeatherBloc — fetch live weather
│       └── theme/      # ThemeBloc (Cubit) — dark/light toggle
└── presentation/
    ├── router/         # GoRouter with StatefulShellRoute (indexed bottom nav)
    ├── screens/        # HomeScreen, DetailScreen, FavoritesScreen, MapScreen
    ├── theme/          # AppTheme (light + dark) with Poppins font
    └── widgets/        # Reusable: PlaceCard, WeatherCard, ShimmerCard, AppDrawer, etc.
```

**State Management:** BLoC (flutter_bloc ^8.1.3) with Equatable  
**Navigation:** GoRouter ^13.2.0 with `StatefulShellRoute.indexedStack`  
**Networking:** Dio ^5.4.1  
**Caching:** SharedPreferences ^2.2.2  
**Images:** cached_network_image ^3.3.1 + shimmer placeholders  
**Maps:** flutter_map ^6.1.0 + latlong2  
**Notifications:** flutter_local_notifications ^17.0.0  
**Fonts:** Google Fonts (Poppins) via google_fonts ^6.2.1

---

## 📡 APIs Used

| API | Purpose |
|---|---|
| `https://jsonplaceholder.typicode.com/photos?_limit=12` | Provides photo IDs; mapped to Picsum images + static destination metadata |
| `https://api.open-meteo.com/v1/forecast?latitude=...&longitude=...&current_weather=true` | Live weather for each destination |
| `https://tile.openstreetmap.org/{z}/{x}/{y}.png` | Map tiles for flutter_map |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart ≥ 3.0.0

### Run
```bash
# Install dependencies
flutter pub get

# Run on Android (notifications require a real device or emulator)
flutter run

# Run on Chrome (web)
flutter run -d chrome
```

> **Note:** Push notifications only work on Android. On Web or iOS they will silently fail.

---

## 📁 Project Structure (Key Files)

| File | Role |
|---|---|
| `lib/main.dart` | DI setup, BLoC providers, app entry |
| `lib/presentation/router/app_router.dart` | GoRouter with shell branches and complex object passing |
| `lib/logic/blocs/places/places_bloc.dart` | Core state — fetch, search, paginate, favorite (persisted) |
| `lib/data/repositories/place_repository.dart` | Cache-first data strategy |
| `lib/presentation/screens/detail_screen.dart` | Hero, AnimatedSize, AnimatedSwitcher, notifications |
| `lib/presentation/screens/home_screen.dart` | AnimatedOpacity, AnimatedContainer, search debounce |
| `lib/presentation/screens/favorites_screen.dart` | AnimatedList with insert/remove |

