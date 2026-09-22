import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../services/tmdb_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<MediaItem>> _popular;

  @override
  void initState() {
    super.initState();
    _popular = TmdbService().fetchList('movie/popular');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popular Movies')),
      body: FutureBuilder<List<MediaItem>>(
        future: _popular,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final movies = snapshot.data!;
          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, i) {
              final movie = movies[i];
              return ListTile(
                leading: movie.posterPath == null
                    ? const Icon(Icons.movie)
                    : Image.network(
                        TmdbService.posterUrl(movie.posterPath),
                        width: 48,
                        fit: BoxFit.cover,
                      ),
                title: Text(movie.title),
                subtitle: Text(
                  movie.overview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(movie.voteAverage.toStringAsFixed(1)),
              );
            },
          );
        },
      ),
    );
  }
}
