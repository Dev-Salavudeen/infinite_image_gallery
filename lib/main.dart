import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/fav_provider.dart';
import 'providers/gallery_provider.dart';
import 'screens/home_screen.dart';
import 'services/pixabay_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final favBox = await Hive.openBox<String>('favs');
  final prefs = await Hive.openBox('prefs');

  runApp(GalleryApp(favBox: favBox, prefs: prefs));
}

class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key, required this.favBox, required this.prefs});

  final Box<String> favBox;
  final Box prefs;

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  late bool _dark = widget.prefs.get('dark') == true;

  void _toggleTheme() {
    setState(() => _dark = !_dark);
    widget.prefs.put('dark', _dark);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GalleryProvider(PixabayService())),
        ChangeNotifierProvider(create: (_) => FavProvider(widget.favBox)),
      ],
      child: MaterialApp(
        title: 'Image Gallery',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF00897B),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: const Color(0xFF00897B),
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
        home: HomeScreen(onToggleTheme: _toggleTheme),
      ),
    );
  }
}
