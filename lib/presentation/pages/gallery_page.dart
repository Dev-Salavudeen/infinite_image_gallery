import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../state/favorites_controller.dart';
import '../state/gallery_controller.dart';
import '../widgets/error_view.dart';
import '../widgets/image_tile.dart';
import 'image_detail_page.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GalleryController>().loadInitial();
    });
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 480) {
      context.read<GalleryController>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gallery = context.watch<GalleryController>();
    final favorites = context.watch<FavoritesController>();
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1100
        ? 5
        : width >= 800
        ? 4
        : width >= 520
        ? 3
        : 2;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: SearchBar(
            controller: _searchController,
            hintText: 'Search photos',
            leading: const Icon(Icons.search),
            trailing: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  onPressed: () {
                    _searchController.clear();
                    gallery.onSearchChanged('');
                    setState(() {});
                  },
                  icon: const Icon(Icons.close),
                ),
            ],
            onChanged: (value) {
              gallery.onSearchChanged(value);
              setState(() {});
            },
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              for (final category in pixabayCategories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: gallery.category == category,
                    onSelected: (_) => gallery.setCategory(category),
                  ),
                ),
            ],
          ),
        ),
        Expanded(child: _body(gallery, favorites, columns)),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            AppConfig.attribution,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _body(GalleryController gallery, FavoritesController favorites, int columns) {
    if (gallery.isInitialLoading && gallery.images.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (gallery.errorMessage != null && gallery.images.isEmpty) {
      return ErrorView(message: gallery.errorMessage!, onRetry: gallery.loadInitial);
    }
    if (gallery.images.isEmpty) {
      return const ErrorView(message: 'No images found. Try another search or category.');
    }

    return RefreshIndicator(
      onRefresh: gallery.refresh,
      child: MasonryGridView.count(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        crossAxisCount: columns,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: gallery.images.length + (gallery.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= gallery.images.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final image = gallery.images[index];
          return AspectRatio(
            aspectRatio: image.aspectRatio,
            child: ImageTile(
              image: image,
              isFavorite: favorites.isFavorite(image.id),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ImageDetailPage(image: image)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
