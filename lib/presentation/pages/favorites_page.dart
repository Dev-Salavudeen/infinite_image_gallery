import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../state/favorites_controller.dart';
import '../widgets/error_view.dart';
import '../widgets/image_tile.dart';
import 'image_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesController>();
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 800 ? 4 : width >= 520 ? 3 : 2;

    if (favorites.items.isEmpty) {
      return const ErrorView(
        message: 'No favorites yet. Open an image and tap the heart to save it locally.',
      );
    }

    return MasonryGridView.count(
      padding: const EdgeInsets.all(12),
      crossAxisCount: columns,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: favorites.items.length,
      itemBuilder: (context, index) {
        final image = favorites.items[index];
        return AspectRatio(
          aspectRatio: image.aspectRatio,
          child: ImageTile(
            image: image,
            isFavorite: true,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ImageDetailPage(image: image)),
              );
            },
          ),
        );
      },
    );
  }
}
