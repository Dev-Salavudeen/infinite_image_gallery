# Infinite Image Gallery

Flutter assignment for Gnxtace (image gallery with Pixabay).

## Run

Get a key from https://pixabay.com/api/docs/ then:

```
flutter pub get
flutter run --dart-define=PIXABAY_API_KEY=YOUR_KEY
```

APK:

```
flutter build apk --dart-define=PIXABAY_API_KEY=YOUR_KEY
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

Don't commit the key. I wired it through dart-define.

## App

- Home grid, infinite scroll (page/per_page)
- Detail page: tags, photographer, likes/views/downloads
- Download to device gallery (progress bar) + share
- Favourites kept locally with Hive
- Search, category chips, pull to refresh
- Dark mode toggle
- cached_network_image so scrolling isn't janky

State is Provider + ChangeNotifier. API calls live in `lib/services/pixabay_service.dart`, UI in `lib/screens/`.

## Notes

- Pixabay caps results around 500 per query so paging stops there
- safesearch is on
- Mostly built/tested for Android. Web may hit CORS.
- Need storage/photos permission to save images

## Tests

```
flutter test
```

## Screenshots

Drop a few captures in `screenshots/` if you want (home, detail, favourites).
