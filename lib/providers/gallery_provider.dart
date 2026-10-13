import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/pixabay_image.dart';
import '../services/pixabay_service.dart';

class GalleryProvider extends ChangeNotifier {
  GalleryProvider(this._api);

  final PixabayService _api;

  final List<PixabayImage> photos = [];
  String query = '';
  String category = '';
  String? error;
  bool loading = false;
  bool loadingMore = false;
  bool loadMoreError = false;

  int _page = 0;
  int _total = 0;
  Timer? _debounce;

  bool get canLoadMore => photos.length < _total;

  Future<void> firstLoad() async {
    loading = true;
    error = null;
    loadMoreError = false;
    notifyListeners();
    await _getPage(1, clear: true);
  }

  Future<void> reload() => _getPage(1, clear: true);

  Future<void> nextPage() async {
    if (loading || loadingMore || !canLoadMore) return;
    loadingMore = true;
    notifyListeners();
    await _getPage(_page + 1, clear: false);
  }

  void setQuery(String value) {
    query = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), firstLoad);
  }

  void setCategory(String value) {
    // tap same chip again to clear
    category = category == value ? '' : value;
    firstLoad();
  }

  Future<void> _getPage(int page, {required bool clear}) async {
    try {
      final result = await _api.search(page: page, q: query, category: category);
      _page = result.page;
      _total = result.totalHits;
      if (clear) {
        photos.clear();
      }
      final seen = photos.map((p) => p.id).toSet();
      for (final p in result.items) {
        if (!seen.contains(p.id)) photos.add(p);
      }
      error = null;
      loadMoreError = false;
    } catch (e) {
      error = e.toString();
      loadMoreError = !clear && photos.isNotEmpty;
    }
    loading = false;
    loadingMore = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
