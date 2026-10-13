import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_image_gallery/services/pixabay_service.dart';

void main() {
  test('parses hits from pixabay json', () {
    const body = '''
{
  "totalHits": 2,
  "hits": [
    {
      "id": 195893,
      "pageURL": "https://pixabay.com/x/",
      "tags": "flower, bloom",
      "previewURL": "https://example.com/p.jpg",
      "previewWidth": 150,
      "previewHeight": 84,
      "webformatURL": "https://example.com/w.jpg",
      "largeImageURL": "https://example.com/l.jpg",
      "views": 10,
      "downloads": 4,
      "likes": 7,
      "user_id": 9,
      "user": "Anna",
      "imageWidth": 4000,
      "imageHeight": 3000
    }
  ]
}
''';

    final page = parseResponse(body, 1);
    expect(page.totalHits, 2);
    expect(page.items.single.user, 'Anna');
    expect(page.items.single.tagList, ['flower', 'bloom']);
    expect(page.items.single.full, 'https://example.com/l.jpg');
  });
}
