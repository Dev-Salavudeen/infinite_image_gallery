import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_image_gallery/domain/entities/gallery_image.dart';
import 'package:infinite_image_gallery/domain/repositories/image_repository.dart';
import 'package:infinite_image_gallery/presentation/state/gallery_controller.dart';

class _FakeImageRepository implements ImageRepository {
  _FakeImageRepository(this.pages);

  final Map<int, List<GalleryImage>> pages;
  int calls = 0;

  @override
  Future<PagedImages> search({
    required int page,
    String query = '',
    String category = '',
  }) async {
    calls += 1;
    final items = pages[page] ?? const <GalleryImage>[];
    return PagedImages(items: items, totalHits: 3, page: page);
  }
}

GalleryImage _image(int id) {
  return GalleryImage(
    id: id,
    pageUrl: '',
    tags: 'nature, forest',
    previewUrl: 'https://example.com/$id.jpg',
    webformatUrl: 'https://example.com/$id.jpg',
    largeImageUrl: 'https://example.com/$id.jpg',
    views: 1,
    downloads: 1,
    likes: 1,
    comments: 0,
    user: 'Tester',
    userId: 1,
    userImageUrl: '',
    imageWidth: 100,
    imageHeight: 80,
    previewWidth: 100,
    previewHeight: 80,
    type: 'photo',
  );
}

void main() {
  test('loadInitial replaces items and loadMore appends the next page', () async {
    final repository = _FakeImageRepository({
      1: [_image(1), _image(2)],
      2: [_image(3)],
    });
    final controller = GalleryController(repository);

    await controller.loadInitial();
    expect(controller.images.map((image) => image.id), [1, 2]);
    expect(controller.hasMore, isTrue);

    await controller.loadMore();
    expect(controller.images.map((image) => image.id), [1, 2, 3]);
    expect(controller.hasMore, isFalse);
    expect(repository.calls, 2);
  });
}
