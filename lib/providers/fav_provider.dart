import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/pixabay_image.dart';

class FavProvider extends ChangeNotifier {
  FavProvider(this._box) {
    _read();
  }

  final Box<String> _box;
  final List<PixabayImage> items = [];

  bool isFav(int id) => _box.containsKey('$id');

  void _read() {
    items.clear();
    for (final raw in _box.values) {
      items.add(PixabayImage.fromJson(jsonDecode(raw) as Map<String, dynamic>));
    }
    // newest first
    items.sort((a, b) => b.id.compareTo(a.id));
    notifyListeners();
  }

  Future<void> toggle(PixabayImage img) async {
    final key = '${img.id}';
    if (_box.containsKey(key)) {
      await _box.delete(key);
    } else {
      await _box.put(key, jsonEncode(img.toJson()));
    }
    _read();
  }
}
