import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:infinite_image_gallery/providers/fav_provider.dart';

import 'helpers.dart';

void main() {
  late Directory tempDir;
  late Box<String> box;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('favs');
    Hive.init(tempDir.path);
    box = await Hive.openBox<String>('favs_${tempDir.path.hashCode}');
  });

  tearDown(() async {
    await box.close();
    tempDir.deleteSync(recursive: true);
  });

  test('toggle adds then removes a favourite', () async {
    final favs = FavProvider(box);
    final img = testImage(7, user: 'Jordan');

    expect(favs.isFav(7), isFalse);
    await favs.toggle(img);
    expect(favs.isFav(7), isTrue);
    expect(favs.items.single.user, 'Jordan');

    await favs.toggle(img);
    expect(favs.isFav(7), isFalse);
    expect(favs.items, isEmpty);
  });
}
