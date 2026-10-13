import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_image_gallery/app.dart';
import 'package:infinite_image_gallery/core/config/app_config.dart';
import 'package:infinite_image_gallery/data/services/download_service.dart';
import 'package:infinite_image_gallery/domain/entities/gallery_image.dart';
import 'package:infinite_image_gallery/domain/repositories/favorites_repository.dart';
import 'package:infinite_image_gallery/domain/repositories/image_repository.dart';
import 'package:infinite_image_gallery/presentation/state/theme_controller.dart';

class _EmptyFavorites implements FavoritesRepository {
  @override
  Future<void> add(GalleryImage image) async {}

  @override
  Future<bool> contains(int id) async => false;

  @override
  Future<List<GalleryImage>> getAll() async => [];

  @override
  Future<void> remove(int id) async {}
}

class _EmptyImages implements ImageRepository {
  @override
  Future<PagedImages> search({
    required int page,
    String query = '',
    String category = '',
  }) async {
    return PagedImages(items: const [], totalHits: 0, page: page);
  }
}

void main() {
  testWidgets('renders gallery shell', (tester) async {
    await tester.pumpWidget(
      ImageGalleryApp(
        imageRepository: _EmptyImages(),
        favoritesRepository: _EmptyFavorites(),
        themeController: ThemeController(),
        downloadService: DownloadService(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Gallery'), findsWidgets);
    expect(find.text(AppConfig.attribution), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
