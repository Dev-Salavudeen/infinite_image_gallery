import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/pixabay_image.dart';
import '../providers/fav_provider.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.img});
  final PixabayImage img;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  double? _progress;
  bool _working = false;

  PixabayImage get img => widget.img;

  Future<File> _downloadFile() async {
    final req = http.Request('GET', Uri.parse(img.full));
    final res = await http.Client().send(req);
    if (res.statusCode != 200) {
      throw Exception('download failed (${res.statusCode})');
    }
    final total = res.contentLength ?? 0;
    final bytes = <int>[];
    var got = 0;
    await for (final chunk in res.stream) {
      bytes.addAll(chunk);
      got += chunk.length;
      if (total > 0 && mounted) {
        setState(() => _progress = got / total);
      }
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/px_${img.id}.jpg');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> _save() async {
    if (_working) return;
    setState(() {
      _working = true;
      _progress = 0;
    });
    try {
      final file = await _downloadFile();
      final ok = await Gal.requestAccess();
      if (!ok) {
        throw Exception('Need photo library permission');
      }
      await Gal.putImage(file.path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved to gallery')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
          _progress = null;
        });
      }
    }
  }

  Future<void> _share() async {
    if (_working) return;
    setState(() {
      _working = true;
      _progress = 0;
    });
    try {
      final file = await _downloadFile();
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${img.tags} — ${img.user} / Pixabay',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
          _progress = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavProvider>();
    final liked = favs.isFav(img.id);
    final ratio = (img.width > 0 && img.height > 0) ? img.width / img.height : img.ratio;

    return Scaffold(
      appBar: AppBar(
        title: Text(img.user),
        actions: [
          IconButton(
            icon: Icon(liked ? Icons.favorite : Icons.favorite_border),
            onPressed: () => favs.toggle(img),
          ),
        ],
      ),
      body: ListView(
        children: [
          Hero(
            tag: 'p${img.id}',
            child: AspectRatio(
              aspectRatio: ratio,
              child: CachedNetworkImage(
                imageUrl: img.full,
                fit: BoxFit.cover,
                memCacheWidth: 1400,
                placeholder: (_, __) => CachedNetworkImage(
                  imageUrl: img.thumb,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (_progress != null) LinearProgressIndicator(value: _progress == 0 ? null : _progress),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  img.tags.isEmpty ? 'Photo by ${img.user}' : img.tags,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text('by ${img.user}'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Chip(label: Text('${img.likes} likes')),
                    Chip(label: Text('${img.downloads} downloads')),
                    Chip(label: Text('${img.views} views')),
                    Chip(label: Text('${img.width}x${img.height}')),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final t in img.tagList.take(10)) Chip(label: Text(t)),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _working ? null : _save,
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _working ? null : _share,
                        icon: const Icon(Icons.ios_share),
                        label: const Text('Share'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Source: Pixabay',
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
