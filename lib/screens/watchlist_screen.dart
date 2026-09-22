import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../services/watchlist_service.dart';
import '../widgets/movie_list_tile.dart';
import 'detail_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  late Future<List<MediaItem>> _movies;

  @override
  void initState() {
    super.initState();
    _movies = WatchlistService.getAll();
  }

  void _reload() => setState(() { _movies = WatchlistService.getAll(); });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MediaItem>>(
      future: _movies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final movies = snapshot.data ?? [];
        if (movies.isEmpty) {
          return const Center(child: Text('No movies in watchlist yet'));
        }
        return ListView.builder(
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
    );
  }
}
