import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/pixabay_image.dart';

class PhotoCard extends StatelessWidget {
  const PhotoCard({
    super.key,
    required this.img,
    required this.onTap,
    this.liked = false,
  });

  final PixabayImage img;
  final VoidCallback onTap;
  final bool liked;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Hero(
        tag: 'p${img.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: img.thumb,
                fit: BoxFit.cover,
                memCacheWidth: 500,
                placeholder: (_, __) => Container(
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => const ColoredBox(
                  color: Colors.black12,
                  child: Icon(Icons.broken_image_outlined),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(6, 18, 6, 6),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                  child: Text(
                    img.tags.isEmpty ? img.user : img.tags,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
              if (liked)
                const Positioned(
                  right: 6,
                  top: 6,
                  child: Icon(Icons.favorite, color: Colors.pinkAccent, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
