import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../services/tmdb_service.dart';

class DetailScreen extends StatelessWidget {
  final MediaItem movie;
  const DetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
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
