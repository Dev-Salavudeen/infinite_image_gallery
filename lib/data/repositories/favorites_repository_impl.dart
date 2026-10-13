import '../../domain/entities/gallery_image.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._local);

  final FavoritesLocalDataSource _local;

  @override
  Future<List<GalleryImage>> getAll() async => _local.getAll();

  @override
  Future<bool> contains(int id) async => _local.contains(id);

  @override
  Future<void> add(GalleryImage image) => _local.add(image);

  @override
  Future<void> remove(int id) => _local.remove(id);
}
