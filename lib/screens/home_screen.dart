import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../models/pixabay_image.dart';
import '../providers/fav_provider.dart';
import '../providers/gallery_provider.dart';
import '../widgets/photo_card.dart';
import 'detail_screen.dart';

const _cats = <(String, String)>[
  ('', 'All'),
  ('nature', 'Nature'),
  ('animals', 'Animals'),
  ('food', 'Food'),
  ('travel', 'Travel'),
  ('sports', 'Sports'),
  ('people', 'People'),
  ('buildings', 'Architecture'),
  ('computer', 'Tech'),
  ('music', 'Music'),
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
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: _tab == 0 ? _gallery() : _favs(),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(28, 0, 28, 12 + bottomInset),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.4 : 0.1),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.auto_awesome_mosaic_outlined,
                  selectedIcon: Icons.auto_awesome_mosaic_rounded,
                  label: 'Gallery',
                  selected: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                _NavItem(
                  icon: Icons.favorite_outline_rounded,
                  selectedIcon: Icons.favorite_rounded,
                  label: 'Saved',
                  selected: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header({required String kicker, required String title, required String subtitle}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kicker.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        letterSpacing: 1.6,
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(title, style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 6),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onToggleTheme,
            style: IconButton.styleFrom(
              backgroundColor: scheme.surface,
              side: BorderSide(color: scheme.outline.withValues(alpha: 0.7)),
              shape: const CircleBorder(),
            ),
            icon: Icon(
              dark ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
              size: 20,
            ),
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
    final bottomPad = 100.0 + MediaQuery.paddingOf(context).bottom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          kicker: 'Gallery',
          title: 'Explore',
          subtitle: 'Photography courtesy of Pixabay',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search photos, places, moods',
              prefixIcon: const Icon(Icons.search_rounded, size: 22),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        _search.clear();
                        g.setQuery('');
                        setState(() {});
                      },
                    ),
            ),
            onChanged: (v) {
              g.setQuery(v);
              setState(() {});
            },
          ),
        ),
        SizedBox(
          height: 56,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
            scrollDirection: Axis.horizontal,
            itemCount: _cats.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final (value, label) = _cats[i];
              final selected = g.category == value;
              return _CategoryPill(
                label: label,
                selected: selected,
                onTap: () => g.setCategory(value),
              );
            },
          ),
        ),
        Expanded(child: _grid(g, favs, cols, bottomPad)),
      ],
    );
  }

  Widget _favs() {
    final favs = context.watch<FavProvider>();
    final w = MediaQuery.sizeOf(context).width;
    final cols = w > 700 ? 4 : w > 480 ? 3 : 2;
    final bottomPad = 100.0 + MediaQuery.paddingOf(context).bottom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          kicker: 'Collection',
          title: 'Favourites',
          subtitle: favs.items.isEmpty
              ? 'Save pieces you want to keep close'
              : '${favs.items.length} saved ${favs.items.length == 1 ? 'work' : 'works'}',
        ),
        Expanded(
          child: favs.items.isEmpty
              ? _EmptyState(
                  icon: Icons.favorite_outline_rounded,
                  title: 'Nothing saved yet',
                  body: 'Open a photograph and tap the heart\nto keep it in your collection.',
                )
              : MasonryGridView.count(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
                  crossAxisCount: cols,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  itemCount: favs.items.length,
                  itemBuilder: (_, i) {
                    final img = favs.items[i];
                    return PhotoCard(
                      img: img,
                      liked: true,
                      onTap: () => _open(img),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _grid(GalleryProvider g, FavProvider favs, int cols, double bottomPad) {
    if (g.loading && g.photos.isEmpty) {
      return _SkeletonGrid(cols: cols, bottomPad: bottomPad);
    }
    if (g.error != null && g.photos.isEmpty) {
      return _EmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'Couldn’t load photographs',
        body: g.error!,
        action: FilledButton(onPressed: g.firstLoad, child: const Text('Try again')),
      );
    }
    if (g.photos.isEmpty) {
      return const _EmptyState(
        icon: Icons.filter_vintage_outlined,
        title: 'No matches',
        body: 'Try another search or category.',
      );
    }

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: g.reload,
      child: MasonryGridView.count(
        controller: _scroll,
        padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPad),
        crossAxisCount: cols,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        itemCount: g.photos.length + (g.loadingMore || g.error != null ? 1 : 0),
        itemBuilder: (ctx, i) {
          if (i >= g.photos.length) {
            if (g.loadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextButton(
                onPressed: g.loadMoreError ? g.nextPage : g.firstLoad,
                child: Text(
                  g.loadMoreError ? 'Couldn’t load more · Retry' : 'Couldn’t refresh · Retry',
                ),
              ),
            );
          }
          final img = g.photos[i];
          return PhotoCard(
            img: img,
            liked: favs.isFav(img.id),
            onTap: () => _open(img),
          );
        },
      ),
    );
  }

  void _open(PixabayImage img) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => DetailScreen(img: img),
        transitionsBuilder: (_, anim, _, child) {
          return FadeTransition(
            opacity: anim,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? scheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? selectedIcon : icon,
                size: 20,
                color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: scheme.onPrimary,
                              ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outline,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? scheme.onPrimary : scheme.onSurface,
                fontSize: 13,
              ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(icon, size: 30, color: scheme.primary),
            ),
            const SizedBox(height: 20),
            Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid({required this.cols, required this.bottomPad});
  final int cols;
  final double bottomPad;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    const heights = [210.0, 280.0, 240.0, 190.0, 260.0, 220.0];
    return MasonryGridView.count(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPad),
      crossAxisCount: cols,
      mainAxisSpacing: 16,
      crossAxisSpacing: 12,
      itemCount: 8,
      itemBuilder: (_, i) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: heights[i % heights.length],
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 10,
              width: 72,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        );
      },
    );
  }
}
