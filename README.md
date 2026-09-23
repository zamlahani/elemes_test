# Media Catalog

A Flutter app for browsing movies, TV shows, and people

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
- **Movies / TV Shows / People** sections, each with its own category tabs (Popular, Top Rated, Upcoming, Now Playing for movies; Popular, Top Rated, On The Air, Airing Today for TV shows) and infinite scroll
- **Search** across all media types or filtered to one (Movies/TV/People), with debounced input, recent search history, and infinite scroll
- **Watchlist**: add/remove any movie, TV show, or person from the detail screen, filterable by media type
- Loading states and retry-able error states throughout
- Bottom navigation: Movies / TV Shows / People

## Structure

```
lib/
  config/       TMDB API key & base URLs
  models/       MediaItem (movie/TV/person data) & MediaType
  services/     TMDB API client, watchlist & recent-search persistence
  screens/      Splash, Home (bottom-nav shell), CategoryScreen, Search, Watchlist, Detail
  widgets/      Reusable list tile & error view
```
