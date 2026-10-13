# Infinite Image Gallery

Flutter assessment app for **Gnxtace Technologies Pvt. Ltd.**: a production-style image gallery that loads photos from the [Pixabay API](https://pixabay.com/api/docs/), supports infinite scroll, image detail, downloads, and local favorites.

## Setup

1. Install [Flutter](https://docs.flutter.dev/get-started/install) 3.24+ (developed on 3.44 / Dart 3.12).
2. Create a free Pixabay account and copy your API key from [pixabay.com/api/docs](https://pixabay.com/api/docs/).
3. From this folder:

```bash
flutter pub get
flutter run --dart-define=PIXABAY_API_KEY=YOUR_KEY
```

VS Code / Cursor: copy `.vscode/launch.json` and replace `YOUR_PIXABAY_API_KEY`.

### Android APK

```bash
flutter build apk --dart-define=PIXABAY_API_KEY=YOUR_KEY
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

**Do not commit your API key.** It is injected at build time with `--dart-define`.

## Architecture

Layers (dependencies point inward):

```
presentation  →  domain  ←  data
     │                         │
  Provider               Pixabay HTTP + Hive
```

| Layer | Responsibility |
| --- | --- |
| `lib/domain` | `GalleryImage` entity, repository contracts |
| `lib/data` | Pixabay HTTP client, Hive favorites store, download/share service |
| `lib/presentation` | Screens, widgets, `ChangeNotifier` controllers |

**State management:** `provider` + `ChangeNotifier`.

- `GalleryController` owns search, category, pagination, refresh, and error state.
- `FavoritesController` owns Hive-backed favorites.
- `ThemeController` persists light / dark / system theme.

UI never talks to HTTP or Hive directly.

## Features

**Required**

- Responsive masonry grid (2–5 columns by width)
- Infinite scroll pagination (`page` + `per_page`)
- Loading, empty, and error states with retry
- Detail screen with description (tags), photographer, likes/views/downloads
- Download to the device photo library, with progress
- Favorites persisted locally (Hive) and a Favorites tab
- Cached network images (`cached_network_image`)

**Bonus**

- Search (debounced)
- Pull-to-refresh
- Pixabay category chips
- Masonry layout
- Hero transition
- Light / dark / system theme
- Share image
- Download progress bar
- Unit tests (JSON parser, pagination) and a widget test

Pixabay attribution is shown on the gallery (“Images provided by Pixabay”).

## Assumptions and limitations

- A personal Pixabay API key is required; the app shows a configuration error if it is missing.
- Pixabay caps API-accessible hits (typically 500 per query). Pagination stops when that cap is reached.
- Safe search is always on; `image_type=photo`.
- Web builds may hit browser CORS limits talking to Pixabay; Android/iOS are the intended demo targets.
- Downloaded files are stored in the system gallery via `gal`. Simulator photo-library permission prompts can differ from physical devices.
- Pixabay asks that API responses be cached for 24 hours in production-scale usage. This demo caches images on disk through `cached_network_image` and avoids extra API calls on scroll-back.

## Tests

```bash
flutter test
```

## Screenshots

Add 2–4 captures here before submission (`screenshots/`):

1. Gallery grid with infinite scroll  
2. Image detail (description + download)  
3. Favorites  
4. Dark theme or error/empty state
