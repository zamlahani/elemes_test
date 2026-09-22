import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../services/tmdb_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _tabs = {
    'Popular': 'movie/popular',
    'Top Rated': 'movie/top_rated',
    'Upcoming': 'movie/upcoming',
    'Now Playing': 'movie/now_playing',
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Movies'),
          bottom: TabBar(tabs: _tabs.keys.map((t) => Tab(text: t)).toList()),
        ),
        body: TabBarView(
          children: _tabs.values.map((endpoint) => _MovieList(endpoint: endpoint)).toList(),
        ),
      ),
    );
  }
}

class _MovieList extends StatefulWidget {
  final String endpoint;
  const _MovieList({required this.endpoint});

  @override
  State<_MovieList> createState() => _MovieListState();
}

class _MovieListState extends State<_MovieList> {
  late final Future<List<MediaItem>> _movies = TmdbService().fetchList(widget.endpoint);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MediaItem>>(
      future: _movies,
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
                  : Image.network(TmdbService.posterUrl(movie.posterPath), width: 48, fit: BoxFit.cover),
              title: Text(movie.title),
              subtitle: Text(movie.overview, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: Text(movie.voteAverage.toStringAsFixed(1)),
            );
          },
        );
      },
    );
  }
}
