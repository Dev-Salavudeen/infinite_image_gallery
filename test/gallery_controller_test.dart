import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_image_gallery/providers/gallery_provider.dart';

import 'helpers.dart';

void main() {
  test('loads page 1 then appends page 2', () async {
    final api = FakeApi({
      1: [testImage(1), testImage(2)],
      2: [testImage(3)],
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

  test('keeps photos and flags loadMoreError when page 2 fails', () async {
    final api = FakeApi(
      {
        1: [testImage(1), testImage(2)],
      },
      totalHits: 4,
      throwOnPage: 2,
    );
    final g = GalleryProvider(api);

    await g.firstLoad();
    await g.nextPage();

    expect(g.photos.map((p) => p.id), [1, 2]);
    expect(g.error, isNotNull);
    expect(g.loadMoreError, isTrue);
    expect(g.loadingMore, isFalse);
    expect(g.canLoadMore, isTrue);
  });
}
