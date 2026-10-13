import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:infinite_image_gallery/providers/fav_provider.dart';
import 'package:infinite_image_gallery/providers/gallery_provider.dart';
import 'package:infinite_image_gallery/screens/home_screen.dart';
import 'package:infinite_image_gallery/theme/app_theme.dart';
import 'package:infinite_image_gallery/widgets/photo_card.dart';
import 'package:provider/provider.dart';

import 'helpers.dart';

void main() {
  late Directory tempDir;
  late Box<String> favBox;
  var boxSeq = 0;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    debugPhotoImageBuilder = (scheme) => ColoredBox(color: scheme.surfaceContainerHighest);
    tempDir = await Directory.systemTemp.createTemp('gallery_hive');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    favBox = await Hive.openBox<String>('favs_${boxSeq++}');
  });

  tearDown(() async {
    await favBox.clear();
    await favBox.close();
  });

  tearDownAll(() {
    debugPhotoImageBuilder = null;
    tempDir.deleteSync(recursive: true);
  });

  Future<void> pumpHome(
    WidgetTester tester, {
    required GalleryProvider gallery,
    FavProvider? favs,
  }) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: gallery),
          ChangeNotifierProvider.value(value: favs ?? FavProvider(favBox)),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: HomeScreen(onToggleTheme: () {}),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('shows explore header, search and category chips', (tester) async {
    final gallery = GalleryProvider(
      FakeApi({1: [testImage(1)]}, totalHits: 1),
    );
    await gallery.firstLoad();

    await pumpHome(tester, gallery: gallery);

    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('GALLERY'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Nature'), findsOneWidget);
    expect(find.text('Anna'), findsWidgets);
  });

  testWidgets('shows error empty state with retry', (tester) async {
    final gallery = GalleryProvider(FakeApi({}, throwOnPage: 1, totalHits: 0));
    await gallery.firstLoad();

    await pumpHome(tester, gallery: gallery);

    expect(find.text('Couldn’t load photographs'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('saved tab shows empty collection copy', (tester) async {
    final gallery = GalleryProvider(
      FakeApi({1: [testImage(1)]}, totalHits: 1),
    );
    await gallery.firstLoad();

    await pumpHome(tester, gallery: gallery);

    await tester.tap(find.byIcon(Icons.favorite_outline_rounded));
    await tester.pump();

    expect(find.text('Favourites'), findsOneWidget);
    expect(find.text('Nothing saved yet'), findsOneWidget);
  });

}
