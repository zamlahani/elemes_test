import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchService {
  static const _key = 'recent_searches';
  static const _max = 10;

  static Future<List<String>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> add(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all.remove(query);
    all.insert(0, query);
    await prefs.setStringList(_key, all.take(_max).toList());
  }
}
