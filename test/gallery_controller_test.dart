import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_image_gallery/models/pixabay_image.dart';
import 'package:infinite_image_gallery/providers/gallery_provider.dart';
import 'package:infinite_image_gallery/services/pixabay_service.dart';

class FakeApi extends PixabayService {
  FakeApi(this.pages);
  final Map<int, List<PixabayImage>> pages;
  int calls = 0;

  @override
  Future<FetchResult> search({
    int page = 1,
    String q = '',
    String category = '',
  }) async {
    calls++;
    return FetchResult(
      items: pages[page] ?? [],
      totalHits: 3,
      page: page,
    );
  }
}

PixabayImage img(int id) => PixabayImage(
      id: id,
      pageUrl: '',
      tags: 'trees',
      previewUrl: 'https://ex.com/$id.jpg',
      webUrl: 'https://ex.com/$id.jpg',
      largeUrl: 'https://ex.com/$id.jpg',
      views: 1,
      downloads: 1,
      likes: 1,
      user: 'x',
      userId: 1,
      width: 100,
      height: 80,
      previewW: 100,
      previewH: 80,
    );

void main() {
  test('loads page 1 then appends page 2', () async {
    final api = FakeApi({
      1: [img(1), img(2)],
      2: [img(3)],
    });
    final g = GalleryProvider(api);

    await g.firstLoad();
    expect(g.photos.map((p) => p.id), [1, 2]);
    expect(g.canLoadMore, true);

    await g.nextPage();
    expect(g.photos.map((p) => p.id), [1, 2, 3]);
    expect(g.canLoadMore, false);
    expect(api.calls, 2);
  });
}
