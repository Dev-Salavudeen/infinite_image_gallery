import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_image_gallery/models/pixabay_image.dart';

void main() {
  test('ratio falls back when preview size is 0', () {
    final img = PixabayImage(
      id: 1,
      pageUrl: '',
      tags: '',
      previewUrl: '',
      webUrl: '',
      largeUrl: '',
      views: 0,
      downloads: 0,
      likes: 0,
      user: 'x',
      userId: 0,
      width: 0,
      height: 0,
      previewW: 0,
      previewH: 0,
    );
    expect(img.ratio, 1.2);
  });
}
