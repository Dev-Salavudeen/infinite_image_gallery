import 'package:flutter/foundation.dart';

import '../../domain/entities/gallery_image.dart';
import '../../domain/repositories/favorites_repository.dart';

class FavoritesController extends ChangeNotifier {
  FavoritesController(this._repository);

  final FavoritesRepository _repository;
  final List<GalleryImage> items = [];
  final Set<int> _ids = {};

  bool isFavorite(int id) => _ids.contains(id);

  Future<void> load() async {
    items
      ..clear()
      ..addAll(await _repository.getAll());
    _ids
      ..clear()
      ..addAll(items.map((image) => image.id));
    notifyListeners();
  }

  Future<void> toggle(GalleryImage image) async {
    if (isFavorite(image.id)) {
      await _repository.remove(image.id);
    } else {
      await _repository.add(image);
    }
    await load();
  }
}
