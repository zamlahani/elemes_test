import 'dart:convert';

// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/media_item.dart';

class TmdbService {
  Future<(List<MediaItem> items, bool hasMore)> fetchList(
    String endpoint, {
    int page = 1,
    Map<String, String>? params,
  }) async {
    final uri = Uri.parse('$tmdbBaseUrl/$endpoint')
        .replace(queryParameters: {'api_key': tmdbApiKey, 'page': '$page', ...?params});
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('TMDB request failed (${response.statusCode})');
    }
    final json = jsonDecode(response.body);
    final results = json['results'] as List;
    final totalPages = json['total_pages'] as int? ?? page;
    return (results.map((e) => MediaItem.fromJson(e)).toList(), page < totalPages);
  }

  static String posterUrl(String? path) => path == null ? '' : '$tmdbImageBaseUrl$path';
}
