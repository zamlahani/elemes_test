import 'package:cached_network_image/cached_network_image.dart';
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
    final backdrop = movie.backdropPath ?? movie.posterPath;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(movie.title, style: const TextStyle(shadows: [Shadow(blurRadius: 8)])),
              background: backdrop == null
                  ? Container(color: Theme.of(context).colorScheme.surfaceContainerHighest)
                  : CachedNetworkImage(imageUrl: TmdbService.posterUrl(backdrop), fit: BoxFit.cover),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      movie.voteAverage.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _toggleWatchlist,
                  icon: Icon(_saved ? Icons.bookmark : Icons.bookmark_border),
                  label: Text(_saved ? 'Remove from Watchlist' : 'Add to Watchlist'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: _saved ? Theme.of(context).colorScheme.error : null,
                    foregroundColor: _saved ? Theme.of(context).colorScheme.onError : null,
                  ),
                ),
                const SizedBox(height: 24),
                Text('Overview', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(movie.overview, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
