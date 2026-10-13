import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../providers/fav_provider.dart';
import '../providers/gallery_provider.dart';
import '../widgets/photo_card.dart';
import 'detail_screen.dart';

const _cats = [
  'nature',
  'animals',
  'food',
  'travel',
  'sports',
  'people',
  'buildings',
  'computer',
  'music',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onToggleTheme});
  final VoidCallback onToggleTheme;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final _scroll = ScrollController();
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 500) {
        context.read<GalleryProvider>().nextPage();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GalleryProvider>().firstLoad();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_tab == 0 ? 'Explore' : 'Favourites'),
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(dark ? Icons.light_mode : Icons.dark_mode_outlined),
          ),
        ],
      ),
      body: _tab == 0 ? _gallery() : const _FavGrid(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.photo_library_outlined),
            label: 'Gallery',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            label: 'Favourites',
          ),
        ],
      ),
    );
  }

  Widget _gallery() {
    final g = context.watch<GalleryProvider>();
    final favs = context.watch<FavProvider>();
    final w = MediaQuery.sizeOf(context).width;
    final cols = w > 1000
        ? 5
        : w > 700
            ? 4
            : w > 480
                ? 3
                : 2;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: TextField(
            controller: _search,
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _search.clear();
                        g.setQuery('');
                        setState(() {});
                      },
                    ),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) {
              g.setQuery(v);
              setState(() {});
            },
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: _cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final c = _cats[i];
              return FilterChip(
                label: Text(c),
                selected: g.category == c,
                onSelected: (_) => g.setCategory(c),
              );
            },
          ),
        ),
        Expanded(child: _grid(g, favs, cols)),
        const Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Text('Images from Pixabay', style: TextStyle(fontSize: 11)),
        ),
      ],
    );
  }

  Widget _grid(GalleryProvider g, FavProvider favs, int cols) {
    if (g.loading && g.photos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (g.error != null && g.photos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(g.error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: g.firstLoad, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (g.photos.isEmpty) {
      return const Center(child: Text('Nothing found, try another search'));
    }

    return RefreshIndicator(
      onRefresh: g.reload,
      child: MasonryGridView.count(
        controller: _scroll,
        padding: const EdgeInsets.all(10),
        crossAxisCount: cols,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: g.photos.length + (g.loadingMore ? 1 : 0),
        itemBuilder: (ctx, i) {
          if (i >= g.photos.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final img = g.photos[i];
          return AspectRatio(
            aspectRatio: img.ratio,
            child: PhotoCard(
              img: img,
              liked: favs.isFav(img.id),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailScreen(img: img)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _FavGrid extends StatelessWidget {
  const _FavGrid();

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavProvider>();
    if (favs.items.isEmpty) {
      return const Center(
        child: Text(
          'No favourites yet.\nOpen a photo and tap the heart.',
          textAlign: TextAlign.center,
        ),
      );
    }
    final w = MediaQuery.sizeOf(context).width;
    final cols = w > 700 ? 4 : w > 480 ? 3 : 2;
    return MasonryGridView.count(
      padding: const EdgeInsets.all(10),
      crossAxisCount: cols,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: favs.items.length,
      itemBuilder: (_, i) {
        final img = favs.items[i];
        return AspectRatio(
          aspectRatio: img.ratio,
          child: PhotoCard(
            img: img,
            liked: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailScreen(img: img)),
              );
            },
          ),
        );
      },
    );
  }
}
