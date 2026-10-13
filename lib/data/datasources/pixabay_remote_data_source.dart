import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/gallery_image.dart';

class PixabayRemoteDataSource {
  PixabayRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<PagedImages> search({
    required int page,
    String query = '',
    String category = '',
  }) async {
    if (!AppConfig.hasApiKey) {
      throw const ConfigException();
    }

    final params = <String, String>{
      'key': AppConfig.pixabayApiKey,
      'page': '$page',
      'per_page': '${AppConfig.perPage}',
      'safesearch': 'true',
      'image_type': 'photo',
    };
    if (query.trim().isNotEmpty) {
      params['q'] = query.trim();
    }
    if (category.isNotEmpty) {
      params['category'] = category;
    }

    final uri = Uri.parse(AppConfig.pixabayBaseUrl).replace(queryParameters: params);

    late final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 20));
    } on SocketException {
      throw const NetworkException();
    } on HttpException {
      throw const NetworkException();
    } catch (error) {
      throw AppException('Failed to reach Pixabay: $error');
    }

    if (response.statusCode == 429) {
      throw const RateLimitException();
    }
    if (response.statusCode != 200) {
      throw AppException(
        'Pixabay request failed (${response.statusCode}): ${response.body}',
        statusCode: response.statusCode,
      );
    }

    return parsePixabayResponse(response.body, page: page);
  }
}

PagedImages parsePixabayResponse(String body, {required int page}) {
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) {
    throw const AppException('Unexpected Pixabay response.');
  }

  final hits = decoded['hits'];
  if (hits is! List) {
    throw const AppException('Pixabay response is missing image hits.');
  }

  final items = hits
      .whereType<Map<String, dynamic>>()
      .map(GalleryImage.fromMap)
      .toList(growable: false);

  return PagedImages(
    items: items,
    totalHits: decoded['totalHits'] as int? ?? items.length,
    page: page,
  );
}
