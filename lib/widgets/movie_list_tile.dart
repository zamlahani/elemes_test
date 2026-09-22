import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../services/tmdb_service.dart';

class MovieListTile extends StatelessWidget {
  final MediaItem movie;
  final VoidCallback onTap;
  const MovieListTile({super.key, required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: movie.posterPath == null
          ? const Icon(Icons.movie)
          : Image.network(TmdbService.posterUrl(movie.posterPath), width: 48, fit: BoxFit.cover),
      title: Text(movie.title),
      subtitle: Text(movie.overview, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Text(movie.voteAverage.toStringAsFixed(1)),
      onTap: onTap,
    );
  }
}
