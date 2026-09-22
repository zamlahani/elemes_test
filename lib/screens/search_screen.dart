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
  static const _prefetchThreshold = 5;

  final _controller = TextEditingController();
  Timer? _debounce;
  List<String> _recent = [];

  String? _query;
  final List<MediaItem> _movies = [];
  int _page = 1;
  bool _hasMore = true;
  bool _loading = false;
  Object? _error;

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
      setState(() => _query = null);
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
      _query = query;
      _movies.clear();
      _page = 1;
      _hasMore = true;
      _error = null;
    });
    _loadMore();
  }

  Future<void> _loadMore() async {
    final query = _query;
    if (query == null) return;
    setState(() => _loading = true);
    try {
      final (movies, hasMore) = await TmdbService().fetchList('search/movie', page: _page, params: {'query': query});
      if (!mounted || query != _query) return;
      setState(() {
        _movies.addAll(movies);
        _hasMore = hasMore;
        _page++;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || query != _query) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
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
        Expanded(child: _buildResults()),
      ],
    );
  }

  Widget _buildResults() {
    if (_query == null) {
      if (_recent.isEmpty) {
        return const Center(child: Text('Type to search movies'));
      }
      return ListView(
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
      );
    }
    if (_movies.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_movies.isEmpty && _error != null) {
      return Center(child: Text('Error: $_error'));
    }
    if (_movies.isEmpty) {
      return const Center(child: Text('No results'));
    }
    return ListView.builder(
      itemCount: _movies.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= _movies.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (_hasMore && !_loading && i == _movies.length - _prefetchThreshold) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _loadMore());
        }
        final movie = _movies[i];
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
  }
}
