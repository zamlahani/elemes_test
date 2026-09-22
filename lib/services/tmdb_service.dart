import 'dart:convert';

// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/media_item.dart';

class TmdbService {
  Future<List<MediaItem>> fetchList(String endpoint, {Map<String, String>? params}) async {
    final uri = Uri.parse('$tmdbBaseUrl/$endpoint')
        .replace(queryParameters: {'api_key': tmdbApiKey, ...?params});
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('TMDB request failed (${response.statusCode})');
    }
    final results = jsonDecode(response.body)['results'] as List;
    // debugPrint(const JsonEncoder.withIndent('  ').convert(results));
    return results.map((e) => MediaItem.fromJson(e)).toList();
  }

  static String posterUrl(String? path) => path == null ? '' : '$tmdbImageBaseUrl$path';
}
