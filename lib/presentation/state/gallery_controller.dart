import 'package:flutter/foundation.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/debouncer.dart';
import '../../domain/entities/gallery_image.dart';
import '../../domain/repositories/image_repository.dart';

class GalleryController extends ChangeNotifier {
  GalleryController(this._repository);

  final ImageRepository _repository;
  final Debouncer _searchDebouncer = Debouncer();

  final List<GalleryImage> images = [];
  String query = '';
  String category = '';
  int _page = 0;
  int _totalHits = 0;
  bool isInitialLoading = false;
  bool isLoadingMore = false;
  bool isRefreshing = false;
  String? errorMessage;

  bool get hasMore => images.length < _totalHits;

  Future<void> loadInitial() async {
    isInitialLoading = true;
    errorMessage = null;
    notifyListeners();
    await _fetch(page: 1, replace: true);
  }

  Future<void> refresh() async {
    if (isRefreshing || isInitialLoading) return;
    isRefreshing = true;
    errorMessage = null;
    notifyListeners();
    await _fetch(page: 1, replace: true);
  }

  Future<void> loadMore() async {
    if (isInitialLoading || isLoadingMore || isRefreshing || !hasMore) return;
    isLoadingMore = true;
    notifyListeners();
    await _fetch(page: _page + 1, replace: false);
  }

  void onSearchChanged(String value) {
    query = value;
    _searchDebouncer.run(loadInitial);
  }

  Future<void> setCategory(String value) async {
    if (category == value) {
      category = '';
    } else {
      category = value;
    }
    await loadInitial();
  }

  Future<void> _fetch({required int page, required bool replace}) async {
    try {
      final result = await _repository.search(
        page: page,
        query: query,
        category: category,
      );
      _page = result.page;
      _totalHits = result.totalHits;
      if (replace) {
        images
          ..clear()
          ..addAll(result.items);
      } else {
        final existing = images.map((image) => image.id).toSet();
        images.addAll(result.items.where((image) => !existing.contains(image.id)));
      }
      errorMessage = null;
    } on AppException catch (error) {
      if (replace && images.isEmpty) {
        errorMessage = error.message;
      }
    } catch (error) {
      if (replace && images.isEmpty) {
        errorMessage = 'Something went wrong: $error';
      }
    } finally {
      isInitialLoading = false;
      isLoadingMore = false;
      isRefreshing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    super.dispose();
  }
}
