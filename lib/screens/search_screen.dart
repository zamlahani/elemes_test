import 'dart:async';

import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../services/recent_search_service.dart';
import '../services/tmdb_service.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  Future<List<MediaItem>>? _results;
  List<String> _recent = [];

  @override
  void initState() {
    super.initState();
    RecentSearchService.getAll().then((v) {
      if (mounted) setState(() => _recent = v);
    });
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() => _results = null);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    if (!mounted) return;
    _controller.text = query;
    await RecentSearchService.add(query);
    if (!mounted) return;
    final recent = await RecentSearchService.getAll();
    if (!mounted) return;
    setState(() {
      _recent = recent;
      _results = TmdbService().fetchList('search/movie', params: {'query': query});
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Search movies...', prefixIcon: Icon(Icons.search)),
            onChanged: _onChanged,
          ),
        ),
        Expanded(
          child: _results == null
              ? _recent.isEmpty
                  ? const Center(child: Text('Type to search movies'))
                  : ListView(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Recent searches', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        for (final query in _recent)
                          ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(query),
                            onTap: () => _runSearch(query),
                          ),
                      ],
                    )
              : FutureBuilder<List<MediaItem>>(
                  future: _results,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final movies = snapshot.data!;
                    if (movies.isEmpty) {
                      return const Center(child: Text('No results'));
                    }
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
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => DetailScreen(movie: movie)),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
