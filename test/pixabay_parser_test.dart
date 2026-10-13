import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_image_gallery/data/datasources/pixabay_remote_data_source.dart';

void main() {
  test('parses Pixabay JSON into gallery images', () {
    const body = '''
{
  "total": 2,
  "totalHits": 2,
  "hits": [
    {
      "id": 195893,
      "pageURL": "https://pixabay.com/photos/example/",
      "type": "photo",
      "tags": "blossom, bloom, flower",
      "previewURL": "https://example.com/preview.jpg",
      "previewWidth": 150,
      "previewHeight": 84,
      "webformatURL": "https://example.com/web.jpg",
      "largeImageURL": "https://example.com/large.jpg",
      "views": 10,
      "downloads": 4,
      "likes": 7,
      "comments": 1,
      "user_id": 42,
      "user": "Anna",
      "userImageURL": "",
      "imageWidth": 4000,
      "imageHeight": 3000
    }
  ]
}
''';

    final page = parsePixabayResponse(body, page: 1);

    expect(page.totalHits, 2);
    expect(page.items, hasLength(1));
    expect(page.items.first.user, 'Anna');
    expect(page.items.first.tagList, ['blossom', 'bloom', 'flower']);
    expect(page.items.first.displayUrl, 'https://example.com/large.jpg');
  });
}
