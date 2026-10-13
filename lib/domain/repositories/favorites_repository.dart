import '../entities/gallery_image.dart';

abstract class FavoritesRepository {
  Future<List<GalleryImage>> getAll();
  Future<bool> contains(int id);
  Future<void> add(GalleryImage image);
  Future<void> remove(int id);
}
