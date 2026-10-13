# Infinite Image Gallery

Flutter assignment for Gnxtace — a Pixabay image gallery with infinite scroll, downloads and local favourites.

## Run

Get a key from https://pixabay.com/api/docs/ then:

```
flutter pub get
flutter run --dart-define=PIXABAY_API_KEY=YOUR_KEY
```

VS Code / Cursor: put the same `--dart-define` in `.vscode/launch.json` (placeholder only — never commit a real key).

APK:

```
flutter build apk --dart-define=PIXABAY_API_KEY=YOUR_KEY
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Architecture

The UI never talks to HTTP or Hive directly. Screens read/write `ChangeNotifier` providers; those call a thin API service or a local box.

```
lib/
  main.dart                  Hive init, Provider scope, theme
  models/pixabay_image.dart  API hit → app model
  services/pixabay_service.dart   HTTP + JSON parse + errors
  providers/
    gallery_provider.dart    paging, search, category, load errors
    fav_provider.dart        Hive-backed favourites
  screens/
    home_screen.dart         grid + search + saved tab
    detail_screen.dart       metadata, download, share, favourite
  widgets/photo_card.dart
  theme/app_theme.dart
```

**State.** Provider + `ChangeNotifier`. `GalleryProvider` owns the photo list, query debounce (500ms), category, and pagination (`page` / `per_page=24`). `FavProvider` stores each favourite as JSON in a Hive box so it survives restarts.

**Data flow.** Home `firstLoad` / `nextPage` → `PixabayService.search` → `PixabayImage` list → masonry grid. Opening a card pushes `DetailScreen`. Heart on the detail page calls `FavProvider.toggle`. Download streams bytes with a progress bar, then `gal` writes to the device library.

**Images.** `cached_network_image` for thumbs and full-size, with `memCacheWidth` so scrolling stays light. Hero animation between card and detail.

## App

- Home grid, infinite scroll
- Detail: tags, photographer, likes / views / downloads, size
- Download to the device gallery (progress + permission) and share
- Favourites kept locally with Hive
- Search, category chips, pull to refresh
- Light / dark theme
- Retry when a later page fails (existing photos stay on screen)

## Tests

```
flutter test
```

- Unit: JSON parser, pagination, load-more failure, favourite toggle
- Widget: home header/search/chips, API error + retry, empty saved tab

## Assumptions and limits

- Pixabay is the image API (required attribution on screen)
- API key comes from `--dart-define=PIXABAY_API_KEY` so it never has to live in source
- Pixabay caps a query at about 500 hits, so paging stops there
- `safesearch` is on; `image_type=photo`
- Storage / photos permission is required to save images
- Built and tested on iOS simulator and Android; web may hit Pixabay CORS
- Pixabay has no long description field, so tags + photographer + stats are the detail “description”
