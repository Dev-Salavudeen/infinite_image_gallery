import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/pixabay_image.dart';

const _kPixabay = 'https://pixabay.com/api/';
const kPerPage = 24;

// dart-define so the key doesn't land in git
const kPixabayKey = String.fromEnvironment('PIXABAY_API_KEY');

class PixabayException implements Exception {
  PixabayException(this.message);
  final String message;
  @override
  String toString() => message;
}

class FetchResult {
  FetchResult({required this.items, required this.totalHits, required this.page});
  final List<PixabayImage> items;
  final int totalHits;
  final int page;
}

class PixabayService {
  PixabayService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<FetchResult> search({
    int page = 1,
    String q = '',
    String category = '',
  }) async {
    if (kPixabayKey.isEmpty) {
      throw PixabayException(
        'Missing API key. Run with --dart-define=PIXABAY_API_KEY=...',
      );
    }

    final params = <String, String>{
      'key': kPixabayKey,
      'page': '$page',
      'per_page': '$kPerPage',
      'safesearch': 'true',
      'image_type': 'photo',
    };
    if (q.trim().isNotEmpty) params['q'] = q.trim();
    if (category.isNotEmpty) params['category'] = category;

    final uri = Uri.parse(_kPixabay).replace(queryParameters: params);

    http.Response res;
    try {
      res = await _client.get(uri).timeout(const Duration(seconds: 20));
    } on SocketException {
      throw PixabayException('No internet connection');
    } catch (e) {
      throw PixabayException('Request failed: $e');
    }

    if (res.statusCode == 429) {
      throw PixabayException('Hit Pixabay rate limit, wait a bit and retry');
    }
    if (res.statusCode != 200) {
      throw PixabayException('Pixabay error ${res.statusCode}');
    }

    return parseResponse(res.body, page);
  }
}

FetchResult parseResponse(String body, int page) {
  final map = jsonDecode(body) as Map<String, dynamic>;
  final raw = map['hits'] as List? ?? [];
  final items = raw
      .whereType<Map<String, dynamic>>()
      .map(PixabayImage.fromJson)
      .toList();
  return FetchResult(
    items: items,
    totalHits: map['totalHits'] as int? ?? items.length,
    page: page,
  );
}
