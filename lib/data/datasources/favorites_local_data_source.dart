import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/gallery_image.dart';

class FavoritesLocalDataSource {
  FavoritesLocalDataSource(this._box);

  static const boxName = 'favorites';

  final Box<String> _box;

  List<GalleryImage> getAll() {
    return _box.values
        .map((raw) => GalleryImage.fromMap(jsonDecode(raw) as Map<String, dynamic>))
        .toList(growable: false)
        .reversed
        .toList(growable: false);
  }

  bool contains(int id) => _box.containsKey(id.toString());

  Future<void> add(GalleryImage image) {
    return _box.put(image.id.toString(), jsonEncode(image.toMap()));
  }

  Future<void> remove(int id) => _box.delete(id.toString());
}
