import 'package:flutter/material.dart';

import '../models/media_item.dart';
import 'category_screen.dart';
import 'search_screen.dart';
import 'watchlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _movieTabs = {
    'Popular': 'movie/popular',
    'Top Rated': 'movie/top_rated',
    'Upcoming': 'movie/upcoming',
    'Now Playing': 'movie/now_playing',
  };

  static const _tvTabs = {
    'Popular': 'tv/popular',
    'Top Rated': 'tv/top_rated',
    'On The Air': 'tv/on_the_air',
    'Airing Today': 'tv/airing_today',
  };

  static const _sectionTypes = [MediaType.movie, MediaType.tv, MediaType.person];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => SearchScreen(initialType: _sectionTypes[_index])),
          ),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 20),
                const SizedBox(width: 8),
                Text('Search...', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WatchlistScreen()),
            ),
          ),
        ],
      ),
      body: switch (_index) {
        0 => const CategoryScreen(key: ValueKey('movies'), tabs: _movieTabs),
        1 => const CategoryScreen(key: ValueKey('tv'), tabs: _tvTabs),
        _ => const CategoryScreen(key: ValueKey('people'), singleEndpoint: 'person/popular'),
      },
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Movies'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'TV Shows'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'People'),
        ],
      ),
    );
  }
}
