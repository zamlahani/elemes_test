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
    final mediaType = _typeFromEndpoint(endpoint);
    return (results.map((e) => MediaItem.fromJson(e, mediaType: mediaType)).toList(), page < totalPages);
  }

  static MediaType _typeFromEndpoint(String endpoint) {
    if (endpoint.contains('tv')) return MediaType.tv;
    if (endpoint.contains('person')) return MediaType.person;
    return MediaType.movie;
  }

  static String posterUrl(String? path) => path == null ? '' : '$tmdbImageBaseUrl$path';
}
