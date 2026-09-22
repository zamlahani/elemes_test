import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/media_item.dart';

class WatchlistService {
  static const _key = 'watchlist_movies';

  static Future<List<MediaItem>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((e) => MediaItem.fromJson(jsonDecode(e))).toList();
  }

  static Future<bool> isSaved(int id) async {
    final all = await getAll();
    return all.any((m) => m.id == id);
  }

  static Future<void> toggle(MediaItem movie) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    final exists = all.any((m) => m.id == movie.id);
    final updated = exists
        ? all.where((m) => m.id != movie.id).toList()
        : [...all, movie];
    await prefs.setStringList(_key, updated.map((m) => jsonEncode(m.toJson())).toList());
  }
}
