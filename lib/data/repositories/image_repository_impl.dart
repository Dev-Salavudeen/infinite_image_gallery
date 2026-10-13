import '../../domain/entities/gallery_image.dart';
import '../../domain/repositories/image_repository.dart';
import '../datasources/pixabay_remote_data_source.dart';

class ImageRepositoryImpl implements ImageRepository {
  ImageRepositoryImpl(this._remote);

  final PixabayRemoteDataSource _remote;

  @override
  Future<PagedImages> search({
    required int page,
    String query = '',
    String category = '',
  }) {
    return _remote.search(page: page, query: query, category: category);
  }
}
