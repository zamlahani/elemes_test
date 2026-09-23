import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../services/watchlist_service.dart';
import '../widgets/movie_list_tile.dart';
import 'detail_screen.dart';

const _filterLabels = {
  null: 'All',
  MediaType.movie: 'Movies',
  MediaType.tv: 'TV',
  MediaType.person: 'People',
};

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  late Future<List<MediaItem>> _movies;
  MediaType? _filter;

  @override
  void initState() {
    super.initState();
    _movies = WatchlistService.getAll();
  }

  void _reload() => setState(() {
        _movies = WatchlistService.getAll();
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                for (final filter in _filterLabels.keys)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_filterLabels[filter]!),
                      selected: _filter == filter,
                      onSelected: (_) => setState(() => _filter = filter),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<MediaItem>>(
              future: _movies,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = snapshot.data ?? [];
                final movies = _filter == null ? all : all.where((m) => m.mediaType == _filter).toList();
                if (movies.isEmpty) {
                  return const Center(child: Text('No items in watchlist yet'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: movieGridDelegate,
                  itemCount: movies.length,
                  itemBuilder: (context, i) {
                    final movie = movies[i];
                    return MovieListTile(
                      movie: movie,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => DetailScreen(movie: movie)),
                        );
                        _reload();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
