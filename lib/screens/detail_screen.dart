import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/pixabay_image.dart';
import '../providers/fav_provider.dart';
import '../utils/format.dart';

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
          const SnackBar(content: Text('Saved to your library')),
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
    final scheme = Theme.of(context).colorScheme;
    final ratio = (img.width > 0 && img.height > 0) ? img.width / img.height : img.ratio;
    final title = img.tagList.isNotEmpty ? img.tagList.first : 'Photograph';

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: 'p${img.id}',
                    child: AspectRatio(
                      aspectRatio: ratio,
                      child: CachedNetworkImage(
                        imageUrl: img.full,
                        fit: BoxFit.cover,
                        memCacheWidth: 1400,
                        placeholder: (_, _) => CachedNetworkImage(
                          imageUrl: img.thumb,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  if (_progress != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: LinearProgressIndicator(
                        value: _progress == 0 ? null : _progress,
                        minHeight: 3,
                        color: scheme.primary,
                        backgroundColor: Colors.black26,
                      ),
                    ),
                ],
              ),
              Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title[0].toUpperCase() + title.substring(1),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: scheme.primaryContainer,
                            child: Text(
                              img.user.isEmpty ? '?' : img.user[0].toUpperCase(),
                              style: TextStyle(
                                color: scheme.onPrimaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(img.user, style: Theme.of(context).textTheme.titleSmall),
                                Text(
                                  'Photographer · Pixabay',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: scheme.outline.withValues(alpha: 0.55)),
                        ),
                        child: Row(
                          children: [
                            _Stat(icon: Icons.favorite_rounded, value: compactCount(img.likes), label: 'Likes'),
                            _divider(scheme),
                            _Stat(icon: Icons.download_rounded, value: compactCount(img.downloads), label: 'Saves'),
                            _divider(scheme),
                            _Stat(icon: Icons.visibility_rounded, value: compactCount(img.views), label: 'Views'),
                          ],
                        ),
                      ),
                      if (img.tagList.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        Text(
                          'TAGS',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                letterSpacing: 1.4,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final t in img.tagList.take(10))
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: scheme.outline),
                                ),
                                child: Text(
                                  t,
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: scheme.onSurface,
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 20),
                        child: Text(
                          '${img.width} × ${img.height}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _working ? null : _save,
                              icon: const Icon(Icons.file_download_outlined, size: 20),
                              label: const Text('Download'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _working ? null : _share,
                              icon: const Icon(Icons.ios_share_rounded, size: 18),
                              label: const Text('Share'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    _GlassIcon(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    _GlassIcon(
                      icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      iconColor: liked ? const Color(0xFFFF8A80) : Colors.white,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        favs.toggle(img);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(ColorScheme scheme) {
    return Container(
      width: 1,
      height: 36,
      color: scheme.outline.withValues(alpha: 0.6),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: scheme.primary),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _GlassIcon extends StatelessWidget {
  const _GlassIcon({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: Colors.black.withValues(alpha: 0.28),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 42,
              height: 42,
              child: Icon(icon, size: 18, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}
