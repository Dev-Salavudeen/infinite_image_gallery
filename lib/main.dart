import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/datasources/favorites_local_data_source.dart';
import 'data/datasources/pixabay_remote_data_source.dart';
import 'data/repositories/favorites_repository_impl.dart';
import 'data/repositories/image_repository_impl.dart';
import 'data/services/download_service.dart';
import 'presentation/state/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final favoritesBox = await Hive.openBox<String>(FavoritesLocalDataSource.boxName);
  final settingsBox = await Hive.openBox<String>(ThemeController.boxName);

  runApp(
    ImageGalleryApp(
      imageRepository: ImageRepositoryImpl(PixabayRemoteDataSource()),
      favoritesRepository: FavoritesRepositoryImpl(FavoritesLocalDataSource(favoritesBox)),
      themeController: ThemeController(settingsBox),
      downloadService: DownloadService(),
    ),
  );
}
