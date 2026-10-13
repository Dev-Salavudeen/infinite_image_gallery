import 'dart:io';

import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/errors/app_exception.dart';

class DownloadService {
  DownloadService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<File> downloadToTemp({
    required String url,
    required int imageId,
    void Function(double progress)? onProgress,
  }) async {
    final request = http.Request('GET', Uri.parse(url));
    final response = await _client.send(request);
    if (response.statusCode != 200) {
      throw AppException('Download failed (${response.statusCode}).');
    }

    final total = response.contentLength ?? 0;
    final bytes = <int>[];
    var received = 0;
    await for (final chunk in response.stream) {
      bytes.addAll(chunk);
      received += chunk.length;
      if (total > 0) {
        onProgress?.call(received / total);
      }
    }
    onProgress?.call(1);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/pixabay_$imageId.jpg');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> saveToGallery(File file) async {
    final granted = await Gal.requestAccess();
    if (!granted) {
      throw const AppException(
        'Photo library permission was denied. Enable it in system settings.',
      );
    }
    await Gal.putImage(file.path);
  }

  Future<void> shareFile(File file, {String? text}) {
    return Share.shareXFiles([XFile(file.path)], text: text);
  }
}
