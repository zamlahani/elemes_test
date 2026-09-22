import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/media_item.dart';

class TmdbService {
  Future<List<MediaItem>> fetchList(String endpoint) async {
    final uri = Uri.parse('$tmdbBaseUrl/$endpoint?api_key=$tmdbApiKey');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('TMDB request failed (${response.statusCode})');
    }
    final results = jsonDecode(response.body)['results'] as List;
    return results.map((e) => MediaItem.fromJson(e)).toList();
  }

  static String posterUrl(String? path) =>
      path == null ? '' : '$tmdbImageBaseUrl$path';
}
