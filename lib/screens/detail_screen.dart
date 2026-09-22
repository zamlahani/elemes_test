import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../services/tmdb_service.dart';
import '../services/watchlist_service.dart';

class DetailScreen extends StatefulWidget {
  final MediaItem movie;
  const DetailScreen({super.key, required this.movie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WatchlistService.isSaved(widget.movie.id).then((v) => setState(() => _saved = v));
  }

  Future<void> _toggleWatchlist() async {
    await WatchlistService.toggle(widget.movie);
    setState(() => _saved = !_saved);
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        actions: [
          IconButton(
            icon: Icon(_saved ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _toggleWatchlist,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (movie.posterPath != null)
              Center(child: Image.network(TmdbService.posterUrl(movie.posterPath), height: 300)),
            const SizedBox(height: 16),
            Text('Rating: ${movie.voteAverage.toStringAsFixed(1)}'),
            const SizedBox(height: 8),
            Text(movie.overview),
          ],
        ),
      ),
    );
  }
}
