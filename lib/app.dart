import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/services/download_service.dart';
import 'domain/repositories/favorites_repository.dart';
import 'domain/repositories/image_repository.dart';
import 'presentation/pages/home_shell.dart';
import 'presentation/state/favorites_controller.dart';
import 'presentation/state/gallery_controller.dart';
import 'presentation/state/theme_controller.dart';

class ImageGalleryApp extends StatelessWidget {
  const ImageGalleryApp({
    super.key,
    required this.imageRepository,
    required this.favoritesRepository,
    required this.themeController,
    required this.downloadService,
  });

  final ImageRepository imageRepository;
  final FavoritesRepository favoritesRepository;
  final ThemeController themeController;
  final DownloadService downloadService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ImageRepository>.value(value: imageRepository),
        Provider<FavoritesRepository>.value(value: favoritesRepository),
        Provider<DownloadService>.value(value: downloadService),
        ChangeNotifierProvider.value(value: themeController),
        ChangeNotifierProvider(create: (_) => GalleryController(imageRepository)),
        ChangeNotifierProvider(
          create: (_) => FavoritesController(favoritesRepository)..load(),
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'Infinite Image Gallery',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: theme.mode,
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}
