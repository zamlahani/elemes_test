import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/media_item.dart';

class WatchlistService {
  static const _key = 'watchlist_movies';

  static String _entryKey(MediaItem item) => '${item.mediaType.name}-${item.id}';

  static Future<List<MediaItem>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((e) => MediaItem.fromJson(jsonDecode(e))).toList();
  }

  static Future<bool> isSaved(MediaItem item) async {
    final all = await getAll();
    return all.any((m) => _entryKey(m) == _entryKey(item));
  }

  static Future<void> toggle(MediaItem movie) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    final exists = all.any((m) => _entryKey(m) == _entryKey(movie));
    final updated = exists
        ? all.where((m) => _entryKey(m) != _entryKey(movie)).toList()
        : [...all, movie];
    await prefs.setStringList(_key, updated.map((m) => jsonEncode(m.toJson())).toList());
  }
}
