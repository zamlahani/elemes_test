# Movies Catalog

A Flutter app for browsing movies

## Setup

1. `flutter pub get`
2. `flutter run`

## Build APK

```
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Features

- **Splash screen** on launch
- **Popular / Top Rated / Upcoming / Now Playing** movie lists, with infinite scroll
- **Search** movies, with debounced input, recent search history, and infinite scroll
- **Watchlist**: add/remove movies from the detail screen
- Loading states and retry-able error states throughout
- Bottom navigation: Movies / Search / Watchlist

## Structure

```
lib/
  config/       TMDB API key & base URLs
  models/       MediaItem (movie data)
  services/     TMDB API client, watchlist & recent-search persistence
  screens/      Splash, Home (movie tabs), Search, Watchlist, Detail
  widgets/      Reusable list tile & error view
```
