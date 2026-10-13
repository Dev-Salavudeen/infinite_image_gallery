import 'package:infinite_image_gallery/models/pixabay_image.dart';
import 'package:infinite_image_gallery/services/pixabay_service.dart';

class FakeApi extends PixabayService {
  FakeApi(
    this.pages, {
    this.totalHits = 3,
    this.throwOnPage,
  });

  final Map<int, List<PixabayImage>> pages;
  final int totalHits;
  final int? throwOnPage;
  int calls = 0;

  @override
  Future<FetchResult> search({
    int page = 1,
    String q = '',
    String category = '',
  }) async {
    calls++;
    if (throwOnPage != null && page == throwOnPage) {
      throw PixabayException('timeout');
    }
    return FetchResult(
      items: pages[page] ?? [],
      totalHits: totalHits,
      page: page,
    );
  }
}

PixabayImage testImage(int id, {String user = 'Anna', String tags = 'forest, trees'}) {
  return PixabayImage(
    id: id,
    pageUrl: '',
    tags: tags,
    previewUrl: 'https://ex.com/$id.jpg',
    webUrl: 'https://ex.com/$id.jpg',
    largeUrl: 'https://ex.com/$id.jpg',
    views: 12,
    downloads: 4,
    likes: 7,
    user: user,
    userId: 1,
    width: 100,
    height: 80,
    previewW: 100,
    previewH: 80,
  );
}
