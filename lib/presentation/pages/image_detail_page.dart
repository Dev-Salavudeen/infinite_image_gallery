import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/errors/app_exception.dart';
import '../../data/services/download_service.dart';
import '../../domain/entities/gallery_image.dart';
import '../state/favorites_controller.dart';

class ImageDetailPage extends StatefulWidget {
  const ImageDetailPage({super.key, required this.image});

  final GalleryImage image;

  @override
  State<ImageDetailPage> createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage> {
  double? _progress;
  bool _busy = false;

  GalleryImage get image => widget.image;

  Future<void> _download({required bool share}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _progress = 0;
    });
    final service = context.read<DownloadService>();
    try {
      final file = await service.downloadToTemp(
        url: image.displayUrl,
        imageId: image.id,
        onProgress: (value) {
          if (mounted) setState(() => _progress = value);
        },
      );
      if (share) {
        await service.shareFile(file, text: '${image.description} — Pixabay / ${image.user}');
      } else {
        await service.saveToGallery(file);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved to photo library')),
          );
        }
      }
    } on AppException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not complete: $error')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _progress = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesController>();
    final favorite = favorites.isFavorite(image.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(image.user),
        actions: [
          IconButton(
            tooltip: favorite ? 'Remove favorite' : 'Save favorite',
            onPressed: () => favorites.toggle(image),
            icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: ListView(
        children: [
          Hero(
            tag: 'image-${image.id}',
            child: AspectRatio(
              aspectRatio: image.imageWidth > 0 && image.imageHeight > 0
                  ? image.imageWidth / image.imageHeight
                  : image.aspectRatio,
              child: CachedNetworkImage(
                imageUrl: image.displayUrl,
                fit: BoxFit.cover,
                memCacheWidth: 1600,
                placeholder: (context, url) => CachedNetworkImage(
                  imageUrl: image.thumbnailUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (_progress != null)
            LinearProgressIndicator(value: _progress == 0 ? null : _progress),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(image.description, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Photographer: ${image.user}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatChip(icon: Icons.favorite_outline, label: '${image.likes} likes'),
                    _StatChip(icon: Icons.download_outlined, label: '${image.downloads} downloads'),
                    _StatChip(icon: Icons.visibility_outlined, label: '${image.views} views'),
                    _StatChip(
                      icon: Icons.aspect_ratio,
                      label: '${image.imageWidth}×${image.imageHeight}',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in image.tagList.take(12)) Chip(label: Text(tag)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _busy ? null : () => _download(share: false),
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _busy ? null : () => _download(share: true),
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Share'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Images provided by Pixabay. Large files are cached locally for smoother browsing.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 16), label: Text(label));
  }
}
