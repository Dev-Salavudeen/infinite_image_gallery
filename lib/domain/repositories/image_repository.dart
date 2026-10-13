import '../entities/gallery_image.dart';

abstract class ImageRepository {
  Future<PagedImages> search({
    required int page,
    String query,
    String category,
  });
}
